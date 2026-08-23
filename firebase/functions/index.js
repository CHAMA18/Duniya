const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios").default;
const crypto = require("crypto");
admin.initializeApp();

// ══════════════════════════════════════════════════════════════
// Resend Email Service
// ══════════════════════════════════════════════════════════════
// API key is stored in Firebase environment config:
//   firebase functions:config:set resend.key="re_xxxxx"
// Never hardcode API keys in source code.

const RESEND_API_URL = "https://api.resend.com";
const DEFAULT_RESEND_FROM = "Pulse <noreply@thestackone.com>";
// Live deployment origin — used as the continueUrl for staff
// invitation password-setup links. (Previously thestackone.com,
// an unreachable domain; email links must land on the live app.)
const DEFAULT_PORTAL_URL = "https://pulse.duniyahealthcare.com/app.html";

// Profile field names evolved from snake_case to camelCase in the Flutter
// client. Keep callable authorization consistent with Firestore rules and
// accept both during the migration.
function getAccountType(user) {
  return String(user?.accountType || user?.account_type || "")
    .trim()
    .toLowerCase();
}

function getInvitationDeliveryStatus(eventType) {
  const statuses = {
    "email.sent": "sent",
    "email.delivered": "delivered",
    "email.delivery_delayed": "delayed",
    "email.bounced": "bounced",
    "email.complained": "complained",
    "email.opened": "opened",
    "email.clicked": "clicked",
  };
  return statuses[eventType] || "sent";
}

function getConfiguredPortalUrl() {
  const configuredUrl = functions.config().app?.url || DEFAULT_PORTAL_URL;
  return configuredUrl.replace(/\/+$/, "");
}

function getConfiguredResendFrom() {
  // Resend validates this configured sender against its approved domain.
  return functions.config().resend?.from || DEFAULT_RESEND_FROM;
}

/**
 * Send an email via Resend.
 *
 * Callable from Flutter:
 *   FirebaseFunctions.instance
n *     .httpsCallable('sendEmail')
 *     .call({ to, subject, html, from, replyTo, text });
 *
 * @param {Object} data - { to, subject, html, from?, replyTo?, text? }
 * @returns {Object} { success, messageId }
 */
exports.sendEmail = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to send email."
      );
    }

    // Validate required fields
    const { to, subject, html, from, replyTo, text } = data;
    if (!to || !subject || (!html && !text)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required fields: to, subject, and html (or text)."
      );
    }

    // Get Resend API key from environment config
    const resendKey = functions.config().resend?.key;
    if (!resendKey) {
      console.error("Resend API key not configured. Run:");
      console.error('  firebase functions:config:set resend.key="re_xxxxx"');
      throw new functions.https.HttpsError(
        "internal",
        "Email service not configured."
      );
    }

    // Build the request payload
    const payload = {
      from: from || "Pulse <noreply@thestackone.com>",
      to: Array.isArray(to) ? to : [to],
      subject,
      ...(html && { html }),
      ...(text && { text }),
      ...(replyTo && { reply_to: Array.isArray(replyTo) ? replyTo : [replyTo] }),
    };

    try {
      const response = await axios.post(`${RESEND_API_URL}/emails`, payload, {
        headers: {
          Authorization: `Bearer ${resendKey}`,
          "Content-Type": "application/json",
        },
      });

      // Log to Firestore for audit trail
      await admin
        .firestore()
        .collection("EmailLogs")
        .add({
          to: payload.to,
          from: payload.from,
          subject: payload.subject,
          messageId: response.data?.id || null,
          status: "sent",
          sentBy: context.auth.uid,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      return {
        success: true,
        messageId: response.data?.id || null,
      };
    } catch (error) {
      const errorMessage =
        error.response?.data?.message || error.message || "Unknown error";
      console.error("Resend email error:", errorMessage);

      // Log failed attempts too
      await admin
        .firestore()
        .collection("EmailLogs")
        .add({
          to: payload.to,
          from: payload.from,
          subject: payload.subject,
          status: "failed",
          error: errorMessage,
          sentBy: context.auth.uid,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      throw new functions.https.HttpsError(
        "internal",
        `Failed to send email: ${errorMessage}`
      );
    }
  });

/**
 * Send a batch of emails via Resend.
 *
 * @param {Object} data - { emails: [{ to, subject, html, from?, text? }] }
 * @returns {Object} { success, results: [{ to, messageId, status }] }
 */
exports.sendBatchEmails = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated."
      );
    }

    const { emails } = data;
    if (!Array.isArray(emails) || emails.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "emails must be a non-empty array."
      );
    }

    if (emails.length > 50) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Maximum 50 emails per batch."
      );
    }

    const resendKey = functions.config().resend?.key;
    if (!resendKey) {
      throw new functions.https.HttpsError(
        "internal",
        "Email service not configured."
      );
    }

    const results = [];

    for (const email of emails) {
      const { to, subject, html, from, text } = email;
      if (!to || !subject || (!html && !text)) {
        results.push({ to, status: "skipped", error: "Missing fields" });
        continue;
      }

      const payload = {
        from: from || "Pulse <noreply@thestackone.com>",
        to: Array.isArray(to) ? to : [to],
        subject,
        ...(html && { html }),
        ...(text && { text }),
      };

      try {
        const response = await axios.post(`${RESEND_API_URL}/emails`, payload, {
          headers: {
            Authorization: `Bearer ${resendKey}`,
            "Content-Type": "application/json",
          },
        });
        results.push({
          to,
          messageId: response.data?.id || null,
          status: "sent",
        });
      } catch (error) {
        results.push({
          to,
          status: "failed",
          error: error.response?.data?.message || error.message,
        });
      }
    }

    return { success: true, results };
  });

// ══════════════════════════════════════════════════════════════
// Email Trigger Functions
// ══════════════════════════════════════════════════════════════

/**
 * Trigger: Send welcome email when a new User document is created.
 * Fires on Firestore write to User/{userId}.
 */
exports.onUserCreated = functions
  .region("us-central1")
  .firestore.document("User/{userId}")
  .onCreate(async (snap, context) => {
    const userData = snap.data();
    const email = userData?.email;
    const displayName = userData?.display_name || "there";

    if (!email) {
      console.log("No email on new user document, skipping welcome email.");
      return null;
    }

    return sendEmailWithResend({
      to: email,
      subject: "Welcome to Pulse",
      html: welcomeTemplate(displayName),
      text: `Welcome to Pulse, ${displayName}!`,
    });
  });

/**
 * Trigger: Send low stock alert email when a new LowStockAlert document
 * is created with Status "active".
 */
exports.onLowStockAlert = functions
  .region("us-central1")
  .firestore.document("LowStockAlert/{alertId}")
  .onCreate(async (snap, context) => {
    const alertData = snap.data();
    const status = alertData?.Status || "";

    if (status !== "active") {
      console.log("LowStockAlert status is not active, skipping.");
      return null;
    }

    const pharmacyId = alertData?.PharmacyId;
    const productId = alertData?.ProductId;
    const currentStock = alertData?.CurrentStock || 0;
    const reorderLevel = alertData?.ReorderLevel || 0;

    if (!pharmacyId || !productId) {
      console.log("Missing pharmacyId or productId, skipping.");
      return null;
    }

    // Resolve pharmacy name and owner email
    const { pharmacyName, ownerEmail } = await resolvePharmacyInfo(
      pharmacyId
    );

    if (!ownerEmail) {
      console.log("No owner email found for pharmacy, skipping.");
      return null;
    }

    // Resolve product name
    const productName = await resolveProductName(productId);

    return sendEmailWithResend({
      to: ownerEmail,
      subject: `⚠️ Low Stock Alert — ${pharmacyName}`,
      html: lowStockTemplate(pharmacyName, productName, currentStock, reorderLevel),
      text: `Low stock: ${productName} at ${pharmacyName} — ${currentStock} remaining (reorder at ${reorderLevel}).`,
    });
  });

/**
 * Scheduled: Check for batches expiring within 30 days and send warnings.
 * Runs daily at 8:00 AM UTC.
 */
exports.dailyExpiryCheck = functions
  .region("us-central1")
  .pubsub.schedule("0 8 * * *")
  .timeZone("UTC")
  .onRun(async (context) => {
    const firestore = admin.firestore();
    const now = new Date();
    const thirtyDaysFromNow = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

    // Query all batches expiring within 30 days
    const batchSnap = await firestore
      .collection("Batch")
      .where("ExpiryDate", ">=", now)
      .where("ExpiryDate", "<=", thirtyDaysFromNow)
      .get();

    if (batchSnap.empty) {
      console.log("No batches expiring within 30 days.");
      return null;
    }

    // Group batches by PharmacyId
    const batchesByPharmacy = {};
    for (const doc of batchSnap.docs) {
      const data = doc.data();
      const pharmacyRef = data.PharmacyId;
      const pharmacyId = pharmacyRef?.id || pharmacyRef?.path?.split("/").pop();
      if (!pharmacyId) continue;

      if (!batchesByPharmacy[pharmacyId]) {
        batchesByPharmacy[pharmacyId] = [];
      }

      const productId = data.ProductId;
      const productName = productId?.id
        ? await resolveProductName(productId)
        : "Unknown Product";

      batchesByPharmacy[pharmacyId].push({
        productName,
        batchNumber: data.BatchNumber || "N/A",
        expiryDate: data.ExpiryDate?.toDate
          ? data.ExpiryDate.toDate().toLocaleDateString()
          : "Unknown",
      });
    }

    // Send one email per pharmacy
    const emails = [];
    for (const [pharmacyId, items] of Object.entries(batchesByPharmacy)) {
      const { pharmacyName, ownerEmail } = await resolvePharmacyInfo(
        pharmacyId
      );
      if (!ownerEmail) continue;

      emails.push(
        sendEmailWithResend({
          to: ownerEmail,
          subject: `⏰ Expiry Warning — ${pharmacyName}`,
          html: expiryWarningTemplate(pharmacyName, items),
          text: `Expiry warning for ${pharmacyName}: ${items.map((i) => `${i.productName} (batch ${i.batchNumber}, expires ${i.expiryDate})`).join(", ")}.`,
        })
      );
    }

    await Promise.allSettled(emails);
    console.log(`Expiry check complete. Sent ${emails.length} emails.`);
    return null;
  });

// ══════════════════════════════════════════════════════════════
// Helper: Resend API caller
// ══════════════════════════════════════════════════════════════

async function sendEmailWithResend({ to, subject, html, text, from }) {
  const resendKey = functions.config().resend?.key;
  if (!resendKey) {
    console.error("Resend API key not configured.");
    return null;
  }

  const payload = {
    from: from || "Pulse <noreply@thestackone.com>",
    to: Array.isArray(to) ? to : [to],
    subject,
    ...(html && { html }),
    ...(text && { text }),
  };

  try {
    const response = await axios.post("https://api.resend.com/emails", payload, {
      headers: {
        Authorization: `Bearer ${resendKey}`,
        "Content-Type": "application/json",
      },
    });

    // Log to Firestore
    await firestore.collection("EmailLogs").add({
      to: payload.to,
      from: payload.from,
      subject: payload.subject,
      messageId: response.data?.id || null,
      status: "sent",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return response.data;
  } catch (error) {
    const errorMessage = error.response?.data?.message || error.message;
    console.error(`Email send failed to ${to}:`, errorMessage);

    await firestore.collection("EmailLogs").add({
      to: payload.to,
      from: payload.from,
      subject: payload.subject,
      status: "failed",
      error: errorMessage,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return null;
  }
}

const firestore = admin.firestore();

// ══════════════════════════════════════════════════════════════
// Helper: Resolve pharmacy info
// ══════════════════════════════════════════════════════════════

async function resolvePharmacyInfo(pharmacyIdOrRef) {
  try {
    let pharmacyDoc;
    if (typeof pharmacyIdOrRef === "string") {
      pharmacyDoc = await firestore.doc(`Pharmacy/${pharmacyIdOrRef}`).get();
    } else if (pharmacyIdOrRef?.path) {
      pharmacyDoc = await pharmacyIdOrRef.get();
    } else {
      return { pharmacyName: "Unknown Pharmacy", ownerEmail: null };
    }

    if (!pharmacyDoc.exists) {
      return { pharmacyName: "Unknown Pharmacy", ownerEmail: null };
    }

    const data = pharmacyDoc.data();
    const pharmacyName = data?.Name || data?.name || "Pharmacy";
    const ownerRef = data?.OwnerRef || data?.ownerRef;

    if (!ownerRef) {
      return { pharmacyName, ownerEmail: null };
    }

    // Resolve owner email from User collection
    let ownerDoc;
    if (ownerRef.get) {
      ownerDoc = await ownerRef.get();
    } else {
      ownerDoc = await firestore.doc(ownerRef.path || `User/${ownerRef}`).get();
    }

    const ownerEmail = ownerDoc?.data()?.email || null;
    return { pharmacyName, ownerEmail };
  } catch (error) {
    console.error("Error resolving pharmacy info:", error.message);
    return { pharmacyName: "Unknown Pharmacy", ownerEmail: null };
  }
}

async function resolveProductName(productIdOrRef) {
  try {
    let productDoc;
    if (typeof productIdOrRef === "string") {
      productDoc = await firestore.doc(`Product/${productIdOrRef}`).get();
    } else if (productIdOrRef?.path) {
      productDoc = await productIdOrRef.get();
    } else {
      return "Unknown Product";
    }

    return productDoc?.data()?.Name || productDoc?.data()?.name || "Unknown Product";
  } catch (error) {
    return "Unknown Product";
  }
}

// ══════════════════════════════════════════════════════════════
// Email Templates
// ══════════════════════════════════════════════════════════════

function welcomeTemplate(displayName) {
  const portalUrl = getConfiguredPortalUrl();
  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:linear-gradient(135deg,#9900FF,#7C3AED);padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">Welcome to Pulse</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:16px;color:#333">Hi ${displayName},</p>
    <p style="font-size:15px;color:#555;line-height:1.6">Welcome to Pulse — your pharmacy and inventory management platform. You're all set to get started.</p>
    <p style="font-size:15px;color:#555;line-height:1.6">You can log in anytime to manage your pharmacy, track inventory, process sales, and more.</p>
    <table width="100%" cellpadding="0" cellspacing="0" style="margin:24px 0"><tr><td align="center">
      <a href="${portalUrl}" style="display:inline-block;padding:14px 32px;background:linear-gradient(135deg,#9900FF,#7C3AED);color:#fff;font-size:15px;font-weight:600;text-decoration:none;border-radius:10px">Open Pulse →</a>
    </td></tr></table>
    <p style="font-size:15px;color:#555;line-height:1.6">If you have any questions, our support team is here to help.</p>
    <p style="font-size:15px;color:#555;margin-top:24px">Best regards,<br>The Pulse Team</p>
  </div>
  <div style="padding:16px 32px;background:#f9fafb;border-top:1px solid #eee;text-align:center">
    <p style="font-size:12px;color:#999;margin:0">Pulse — Pharmacy Management</p>
  </div>
</div>
</body>
</html>`;
}

function lowStockTemplate(pharmacyName, productName, currentStock, reorderLevel) {
  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:#dc2626;padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">⚠️ Low Stock Alert</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:15px;color:#555;line-height:1.6">The following item at <strong>${pharmacyName}</strong> is running low:</p>
    <table style="width:100%;border-collapse:collapse;margin:16px 0;font-size:14px">
      <thead><tr style="background:#f9fafb"><th style="padding:8px;text-align:left">Item</th><th style="padding:8px;text-align:center">In Stock</th><th style="padding:8px;text-align:center">Reorder Level</th></tr></thead>
      <tbody><tr><td style="padding:8px;border-bottom:1px solid #eee">${productName}</td><td style="padding:8px;border-bottom:1px solid #eee;text-align:center">${currentStock}</td><td style="padding:8px;border-bottom:1px solid #eee;text-align:center;color:#dc2626">${reorderLevel}</td></tr></tbody>
    </table>
    <p style="font-size:15px;color:#555;line-height:1.6;margin-top:20px">Please review and replenish as needed.</p>
  </div>
  <div style="padding:16px 32px;background:#f9fafb;border-top:1px solid #eee;text-align:center">
    <p style="font-size:12px;color:#999;margin:0">Pulse — Pharmacy Management</p>
  </div>
</div>
</body>
</html>`;
}

function expiryWarningTemplate(pharmacyName, items) {
  const rows = items
    .map(
      (i) => `<tr><td style="padding:8px;border-bottom:1px solid #eee">${i.productName}</td><td style="padding:8px;border-bottom:1px solid #eee;text-align:center">${i.batchNumber}</td><td style="padding:8px;border-bottom:1px solid #eee;text-align:center;color:#dc2626">${i.expiryDate}</td></tr>`
    )
    .join("");

  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:#f59e0b;padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">⏰ Expiry Warning</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:15px;color:#555;line-height:1.6">The following items at <strong>${pharmacyName}</strong> are expiring within 30 days:</p>
    <table style="width:100%;border-collapse:collapse;margin:16px 0;font-size:14px">
      <thead><tr style="background:#f9fafb"><th style="padding:8px;text-align:left">Item</th><th style="padding:8px;text-align:center">Batch</th><th style="padding:8px;text-align:center">Expiry Date</th></tr></thead>
      <tbody>${rows}</tbody>
    </table>
    <p style="font-size:15px;color:#555;line-height:1.6;margin-top:20px">Please take action to prevent losses from expired stock.</p>
  </div>
  <div style="padding:16px 32px;background:#f9fafb;border-top:1px solid #eee;text-align:center">
    <p style="font-size:12px;color:#999;margin:0">Pulse — Pharmacy Management</p>
  </div>
</div>
</body>
</html>`;
}

// ══════════════════════════════════════════════════════════════
// Resend Webhook Handler
// ══════════════════════════════════════════════════════════════
// Receives delivery events from Resend and stores them in Firestore.
// Configure the webhook URL in Resend dashboard:
//   https://us-central1-pharmacy-system-2fb27.cloudfunctions.net/onResendWebhook
//
// Events tracked:
//   email.sent, email.delivered, email.delivery_delayed,
//   email.bounced, email.complained, email.opened, email.clicked

exports.onResendWebhook = functions
  .region("us-central1")
  .https.onRequest(async (req, res) => {
    // Only accept POST
    if (req.method !== "POST") {
      res.status(405).send("Method not allowed");
      return;
    }

    // Reject unverified requests. Delivery state is security-sensitive because
    // it appears in the HR portal and must only originate from Resend.
    const svixSecret = functions.config().resend?.webhook_secret;
    if (!svixSecret) {
      console.error("Resend webhook secret is not configured.");
      res.status(503).send("Webhook verification is not configured");
      return;
    }
    try {
      const { Webhook } = require("svix");
      const wh = new Webhook(svixSecret);
      wh.verify(
        JSON.stringify(req.body),
        {
          "svix-id": req.headers["svix-id"],
          "svix-timestamp": req.headers["svix-timestamp"],
          "svix-signature": req.headers["svix-signature"],
        }
      );
    } catch (err) {
      console.error("Webhook signature verification failed:", err.message);
      res.status(401).send("Invalid signature");
      return;
    }

    const firestore = admin.firestore();
    const event = req.body;
    const eventType = event.type || "unknown";
    const emailData = event.data || {};

    console.log(`[Webhook] Received: ${eventType}`, JSON.stringify(emailData, null, 2));

    // Store the event in Firestore
    try {
      const deliveryRef = firestore.collection("EmailDelivery").doc();

      const eventData = {
        eventType,
        messageId: emailData.email_id || emailData.messageId || null,
        from: emailData.from || null,
        to: emailData.to || null,
        subject: emailData.subject || null,

        // Event-specific fields
        ...(emailData.created_at && { createdAt: new Date(emailData.created_at) }),
        ...(emailData.created && { createdAt: new Date(emailData.created) }),

        // Bounce/complaint details
        ...(emailData.bounce && {
          bounceType: emailData.bounce.type || null,
          bounceMessage: emailData.bounce.message || null,
        }),

        // Click details
        ...(emailData.click && {
          clickUrl: emailData.click.url || null,
          clickIp: emailData.click.ip || null,
          clickUserAgent: emailData.click.userAgent || null,
        }),

        // Open details
        ...(emailData.open && {
          openIp: emailData.open.ip || null,
          openUserAgent: emailData.open.userAgent || null,
        }),

        // Raw payload for debugging
        rawPayload: event,

        // Timestamps
        receivedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await deliveryRef.set(eventData);

      // Also update the original EmailLogs entry if we can match by messageId
      if (emailData.email_id || emailData.messageId) {
        const messageId = emailData.email_id || emailData.messageId;
        const logsQuery = await firestore
          .collection("EmailLogs")
          .where("messageId", "==", messageId)
          .limit(1)
          .get();

        if (!logsQuery.empty) {
          const logDoc = logsQuery.docs[0];
          await logDoc.ref.update({
            lastStatus: eventType,
            lastStatusAt: admin.firestore.FieldValue.serverTimestamp(),
            deliveryRef: deliveryRef.path,
          });
        }

        const invitationQuery = await firestore
          .collection("StaffInvitations")
          .where("resendMessageId", "==", messageId)
          .limit(1)
          .get();
        if (!invitationQuery.empty) {
          const invitationDoc = invitationQuery.docs[0];
          const invitation = invitationDoc.data();
          const deliveryStatus = getInvitationDeliveryStatus(eventType);
          await invitationDoc.ref.update({
            deliveryStatus,
            deliveryStatusAt: admin.firestore.FieldValue.serverTimestamp(),
            lastDeliveryEvent: eventType,
          });

          // Keep completed invitations terminal if a late delivery event arrives.
          if (invitation.status !== "accepted" && invitation.staffId) {
            await firestore.collection("Staff").doc(invitation.staffId).set(
              {
                invitationStatus: deliveryStatus,
                invitationUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              { merge: true }
            );
          }
        }
      }

      console.log(`[Webhook] Stored ${eventType} event: ${deliveryRef.id}`);
      res.status(200).json({ received: true, eventId: deliveryRef.id });
    } catch (error) {
      console.error("[Webhook] Error storing event:", error.message);
      res.status(500).json({ error: error.message });
    }
  });

// ══════════════════════════════════════════════════════════════
// Staff Invitation Email
// ══════════════════════════════════════════════════════════════
// Sends a staff invitation email via Resend when a staff member
// is added. Creates a StaffInvitation document with a secure
// token that the invitee uses to create their account.

/**
 * Send a staff invitation email.
 *
 * Callable from Flutter:
 *   FirebaseFunctions.instance
 *     .httpsCallable('sendStaffInvitation')
 *     .call({ staffId, email, name, role, pharmacyName, pharmacyId });
 *
 * @param {Object} data - { staffId, email, name, role, pharmacyName, pharmacyId }
 * @returns {Object} { success, invitationId }
 */
exports.sendStaffInvitation = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated."
      );
    }

    const { staffId, email, name, role, pharmacyName, pharmacyId } = data;

    if (!staffId || !email || !name || !role) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "staffId, email, name, and role are required."
      );
    }

    const firestore = admin.firestore();
    const normalizedEmail = email.toLowerCase().trim();
    const staffRef = firestore.collection("Staff").doc(staffId);
    const staffSnapshot = await staffRef.get();
    if (!staffSnapshot.exists) {
      throw new functions.https.HttpsError("not-found", "Staff record not found.");
    }

    const staff = staffSnapshot.data();
    if (staff.OwnerRef?.id !== context.auth.uid) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "You can only invite staff in your own pharmacy workspace."
      );
    }
    if ((staff.Email || "").toLowerCase().trim() !== normalizedEmail) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "The invitation email must match the staff record."
      );
    }

    // Generate a secure random token for the invitation
    const crypto = require("crypto");
    const token = crypto.randomBytes(32).toString("hex");
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7-day expiry

    const fromAddress = getConfiguredResendFrom();
    const portalUrl = getConfiguredPortalUrl();

    // Create the invitation before calling Resend so failed delivery attempts
    // still have a visible, auditable state in the HR portal.
    const invitationRef = await firestore.collection("StaffInvitations").add({
      email: normalizedEmail,
      name: name,
      role: role,
      pharmacyName: pharmacyName || "",
      pharmacyId: pharmacyId || null,
      staffId: staffId || null,
      inviterUid: context.auth.uid,
      token: token,
      status: "pending",
      deliveryStatus: "sending",
      from: fromAddress,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: expiresAt,
    });
    await staffRef.update({
      invitationId: invitationRef.id,
      invitationStatus: "sending",
      invitationUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Build the invitation URL
    const invitationUrl = `${portalUrl}/#/accept-invitation?token=${token}&email=${encodeURIComponent(normalizedEmail)}`;

    // Role display label
    const roleLabel = role;

    // Send the invitation email via Resend
    const resendKey = functions.config().resend?.key;
    if (!resendKey) {
      console.error("[StaffInvitation] Resend API key not configured.");
      await invitationRef.update({
        deliveryStatus: "failed",
        failureReason: "Email service is not configured.",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      await staffRef.update({
        invitationStatus: "failed",
        invitationUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      throw new functions.https.HttpsError(
        "internal",
        "Email service not configured."
      );
    }

    const emailHtml = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background-color:#F8F9FF;font-family:'Inter',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#F8F9FF;padding:40px 20px;">
    <tr><td align="center">
      <table width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.06);">
        <!-- Header -->
        <tr>
          <td style="padding:32px 32px 24px;text-align:center;background:linear-gradient(135deg,#9900FF,#1D4ED8);">
            <h1 style="margin:0;color:#ffffff;font-size:22px;font-weight:700;letter-spacing:-0.3px;">You're Invited to Join</h1>
            <p style="margin:8px 0 0;color:rgba(255,255,255,0.85);font-size:14px;">${pharmacyName || 'Your Pharmacy'}</p>
          </td>
        </tr>
        <!-- Body -->
        <tr>
          <td style="padding:32px;">
            <p style="margin:0 0 16px;color:#0B1C30;font-size:15px;line-height:1.6;">Hi <strong>${name}</strong>,</p>
            <p style="margin:0 0 16px;color:#0B1C30;font-size:15px;line-height:1.6;">
              You've been invited to join <strong>${pharmacyName || 'a pharmacy'}</strong> as a <strong>${roleLabel}</strong> on Pulse — a modern pharmacy management platform.
            </p>
            <p style="margin:0 0 16px;color:#0B1C30;font-size:15px;line-height:1.6;">
              Click the button below to create your account and get started:
            </p>
            <!-- CTA Button -->
            <table width="100%" cellpadding="0" cellspacing="0" style="margin:24px 0;">
              <tr>
                <td align="center">
                  <a href="${invitationUrl}" style="display:inline-block;padding:14px 32px;background:linear-gradient(135deg,#9900FF,#7C3AED);color:#ffffff;font-size:15px;font-weight:600;text-decoration:none;border-radius:10px;letter-spacing:0.2px;">
                    Accept Invitation →
                  </a>
                </td>
              </tr>
            </table>
            <!-- Role Card -->
            <table width="100%" cellpadding="0" cellspacing="0" style="margin:16px 0;">
              <tr>
                <td style="padding:16px;background:#F8F9FF;border-radius:12px;border:1px solid #E2E8F0;">
                  <table width="100%" cellpadding="0" cellspacing="0">
                    <tr>
                      <td style="color:#64748B;font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.8px;padding-bottom:8px;">Assigned Role</td>
                    </tr>
                    <tr>
                      <td style="color:#0B1C30;font-size:16px;font-weight:700;">${roleLabel}</td>
                    </tr>
                    <tr>
                      <td style="padding-top:8px;color:#64748B;font-size:13px;">Pharmacy: ${pharmacyName || 'N/A'}</td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
            <p style="margin:16px 0 0;color:#64748B;font-size:13px;line-height:1.5;">
              This invitation expires in 7 days. If you didn't expect this invitation, you can safely ignore this email.
            </p>
          </td>
        </tr>
        <!-- Footer -->
        <tr>
          <td style="padding:16px 32px 24px;text-align:center;border-top:1px solid #F1F5F9;">
            <p style="margin:0;color:#94A3B8;font-size:11px;">
              © 2025 Pulse · Powered by Resend
            </p>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;

    try {
      const response = await axios.post(
        `${RESEND_API_URL}/emails`,
        {
          from: fromAddress,
          to: [email.toLowerCase().trim()],
          subject: `You're invited to join ${pharmacyName || 'Pulse'} as ${roleLabel}`,
          html: emailHtml,
        },
        {
          headers: {
            Authorization: `Bearer ${resendKey}`,
            "Content-Type": "application/json",
          },
        }
      );

      const messageId = response.data?.id;

      // Update invitation with message ID
      await invitationRef.update({
        resendMessageId: messageId || null,
        deliveryStatus: "sent",
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      await staffRef.update({
        invitationStatus: "sent",
        invitationSentAt: admin.firestore.FieldValue.serverTimestamp(),
        invitationUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Log to EmailLogs for audit trail
      await firestore.collection("EmailLogs").add({
        from: fromAddress,
        to: [email.toLowerCase().trim()],
        subject: `You're invited to join ${pharmacyName || 'Pulse'} as ${roleLabel}`,
        messageId: messageId,
        type: "staff_invitation",
        staffInvitationRef: invitationRef.path,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`[StaffInvitation] Email sent to ${email}: ${messageId}`);
      return { success: true, invitationId: invitationRef.id, messageId };
    } catch (error) {
      const errorMessage =
        error.response?.data?.message || error.message || "Unable to send invitation.";
      console.error(`[StaffInvitation] Failed to send email to ${email}:`, errorMessage);
      await invitationRef.update({
        deliveryStatus: "failed",
        failureReason: errorMessage,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      await staffRef.update({
        invitationStatus: "failed",
        invitationUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      throw new functions.https.HttpsError(
        "internal",
        "Unable to send the invitation email."
      );
    }
  });

// Completes acceptance server-side because client writes to Staff are denied.
exports.completeStaffInvitation = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    if (!context.auth || !context.auth.token.email) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Sign in to accept this invitation."
      );
    }
    const invitationId = data.invitationId;
    if (!invitationId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "invitationId is required."
      );
    }

    const firestore = admin.firestore();
    const invitationRef = firestore.collection("StaffInvitations").doc(invitationId);
    await firestore.runTransaction(async (transaction) => {
      const invitationSnapshot = await transaction.get(invitationRef);
      if (!invitationSnapshot.exists) {
        throw new functions.https.HttpsError("not-found", "Invitation not found.");
      }

      const invitation = invitationSnapshot.data();
      if (invitation.status !== "pending") {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "This invitation is no longer active."
        );
      }
      if (invitation.email !== context.auth.token.email.toLowerCase()) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "This invitation belongs to another email address."
        );
      }
      if (invitation.expiresAt?.toDate && invitation.expiresAt.toDate() < new Date()) {
        throw new functions.https.HttpsError(
          "deadline-exceeded",
          "This invitation has expired."
        );
      }

      transaction.update(invitationRef, {
        status: "accepted",
        deliveryStatus: "accepted",
        acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
        acceptedByUid: context.auth.uid,
      });
      if (invitation.staffId) {
        transaction.set(
          firestore.collection("Staff").doc(invitation.staffId),
          {
            UserRef: firestore.collection("User").doc(context.auth.uid),
            invitationStatus: "accepted",
            invitationUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
            status: "active",
          },
          { merge: true }
        );
      }
    });

    return { success: true };
  });

// ══════════════════════════════════════════════════════════════
// Staff Invitation Token Verification (HTTP endpoint)
// ══════════════════════════════════════════════════════════════
// Callable from Flutter to verify an invitation token and get details.

/**
 * Verify a staff invitation token.
 *
 * @param {Object} data - { token, email }
 * @returns {Object} { valid, name, role, pharmacyName, pharmacyId, email }
 */
exports.verifyStaffInvitation = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    const { token, email } = data;

    if (!token || !email) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "token and email are required."
      );
    }

    const firestore = admin.firestore();
    const query = await firestore
      .collection("StaffInvitations")
      .where("token", "==", token)
      .where("email", "==", email.toLowerCase().trim())
      .where("status", "==", "pending")
      .limit(1)
      .get();

    if (query.empty) {
      return { valid: false, reason: "Invitation not found or already used." };
    }

    const doc = query.docs[0];
    const inv = doc.data();

    // Check expiry
    const expiresAt = inv.expiresAt?.toDate ? inv.expiresAt.toDate() : null;
    if (expiresAt && expiresAt < new Date()) {
      return { valid: false, reason: "This invitation has expired." };
    }

    return {
      valid: true,
      name: inv.name,
      role: inv.role,
      pharmacyName: inv.pharmacyName || "",
      pharmacyId: inv.pharmacyId || null,
      email: inv.email,
      invitationId: doc.id,
    };
  });

// Dispatch stock from Pulse to an approved pharmacy. Client-side writes to a
// pharmacy workspace are intentionally forbidden by Firestore rules, so this
// callable validates the platform user and destination before writing there.
exports.dispatchGoodsToPharmacy = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Sign in to dispatch goods."
      );
    }

    const { pharmacyPath, deliveryNoteNumber, deliveryDate, items } = data || {};
    if (!pharmacyPath || !deliveryNoteNumber || !Array.isArray(items) || !items.length) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "A destination pharmacy, delivery note, and at least one item are required."
      );
    }

    const firestore = admin.firestore();
    const callerSnapshot = await firestore.collection("User").doc(context.auth.uid).get();
    const caller = callerSnapshot.data() || {};
    if (getAccountType(caller) !== "pulse") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only Pulse accounts can dispatch goods to pharmacies."
      );
    }

    if (!/^User\/[^/]+\/Pharmacy\/[^/]+$/.test(pharmacyPath)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "The destination pharmacy reference is invalid."
      );
    }
    const pharmacyRef = firestore.doc(pharmacyPath);
    const pharmacySnapshot = await pharmacyRef.get();
    const pharmacy = pharmacySnapshot.data() || {};
    if (!pharmacySnapshot.exists || pharmacy.NetworkStatus !== "active" || !pharmacy.UserID) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Goods can only be dispatched to an approved active pharmacy."
      );
    }

    const normalizedItems = items.map((item) => {
      const quantityDelivered = Number(item.quantityDelivered);
      if (!/^ProductMaster\/[^/]+$/.test(String(item.productPath || "")) ||
          !Number.isInteger(quantityDelivered) || quantityDelivered <= 0 ||
          (item.quantityReceived != null &&
            (!Number.isInteger(Number(item.quantityReceived)) ||
              Number(item.quantityReceived) < 0))) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Each dispatched item needs a product and valid quantities."
        );
      }
      return {
        productId: firestore.doc(item.productPath),
        quantityDelivered,
        batchNumber: String(item.batchNumber || "").trim(),
        discrepancy: String(item.discrepancy || "").trim(),
        expiryDate: item.expiryDate ? admin.firestore.Timestamp.fromMillis(Number(item.expiryDate)) : null,
      };
    });

    const destinationOwnerRef = pharmacy.UserID;
    const receiptRef = destinationOwnerRef.collection("GoodsReceived").doc();
    const now = admin.firestore.FieldValue.serverTimestamp();
    const dispatchDate = deliveryDate
      ? admin.firestore.Timestamp.fromMillis(Number(deliveryDate))
      : admin.firestore.Timestamp.now();
    const batch = firestore.batch();
    batch.set(receiptRef, {
      DeliveryNoteNumber: String(deliveryNoteNumber).trim(),
      OutletId: pharmacyRef,
      ReceivedById: null,
      DeliveryDate: dispatchDate,
      // A Pulse dispatch is visible to the destination immediately, but it is
      // not received (or added to stock) until that pharmacy confirms it.
      ReceivedDate: null,
      Status: "PENDING",
      DispatchSource: "Pulse",
      CreatedAt: now,
      UpdatedAt: now,
    });

    for (const item of normalizedItems) {
      const itemRef = receiptRef.collection("GoodsReceivedItem").doc();
      batch.set(itemRef, {
        ProductId: item.productId,
        QuantityDelivered: item.quantityDelivered,
        QuantityReceived: 0,
        BatchNumber: item.batchNumber || null,
        ExpiryDate: item.expiryDate,
        Discrepancy: item.discrepancy || null,
      });
    }

    await batch.commit();
    return { success: true, receiptId: receiptRef.id, pharmacyName: pharmacy.Name || "" };
  });

// The receiving pharmacy confirms a pending Pulse dispatch. Keeping this
// server-side prevents clients from crediting stock before a real receipt.
exports.confirmPulseDispatch = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Sign in to confirm a dispatch.");
    }

    const { receiptPath, items, discrepancies } = data || {};
    const expectedPrefix = `User/${context.auth.uid}/GoodsReceived/`;
    if (!String(receiptPath || "").startsWith(expectedPrefix) ||
        String(receiptPath).split("/").length !== 4 || !Array.isArray(items) || !items.length) {
      throw new functions.https.HttpsError("invalid-argument", "The pending dispatch is invalid.");
    }

    const firestore = admin.firestore();
    const receiptRef = firestore.doc(receiptPath);
    const receiptSnapshot = await receiptRef.get();
    if (!receiptSnapshot.exists || receiptSnapshot.get("DispatchSource") !== "Pulse") {
      throw new functions.https.HttpsError("not-found", "The Pulse dispatch was not found.");
    }
    if (receiptSnapshot.get("Status") !== "PENDING") {
      throw new functions.https.HttpsError("failed-precondition", "This dispatch has already been processed.");
    }

    const receipt = receiptSnapshot.data();
    const itemSnapshots = await receiptRef.collection("GoodsReceivedItem").get();
    const itemByPath = new Map(itemSnapshots.docs.map((doc) => [doc.ref.path, doc]));
    if (items.length !== itemByPath.size) {
      throw new functions.https.HttpsError("invalid-argument", "Every dispatched item must be confirmed.");
    }

    const normalizedItems = items.map((item) => {
      const itemSnapshot = itemByPath.get(String(item.itemPath || ""));
      const quantityReceived = Number(item.quantityReceived);
      const discrepancy = String(item.discrepancy || "").trim();
      if (!itemSnapshot || !Number.isInteger(quantityReceived) || quantityReceived < 0) {
        throw new functions.https.HttpsError("invalid-argument", "One or more confirmed quantities are invalid.");
      }
      return { itemSnapshot, quantityReceived, discrepancy };
    });

    const overallDiscrepancies = String(discrepancies || "").trim();
    const hasDiscrepancy = overallDiscrepancies || normalizedItems.some(({ itemSnapshot, quantityReceived, discrepancy }) =>
      quantityReceived !== Number(itemSnapshot.get("QuantityDelivered")) || discrepancy);
    const now = admin.firestore.FieldValue.serverTimestamp();
    const batch = firestore.batch();
    batch.update(receiptRef, {
      Status: hasDiscrepancy ? "DISCREPANCY" : "CONFIRMED",
      ReceivedDate: now,
      ReceivedById: firestore.collection("User").doc(context.auth.uid),
      Discrepancies: overallDiscrepancies || null,
      UpdatedAt: now,
    });

    // ── Auto-increase pharmacy stock for every confirmed item ──
    // Requirement: confirming a goods receipt must increase the stock
    // at the pharmacy. Stock docs live under the receiving owner and
    // are matched to products by name; missing stock docs are created.
    const ownerRef = firestore.collection("User").doc(context.auth.uid);
    const productIds = [
      ...new Set(
        normalizedItems
          .map(({ itemSnapshot }) => (itemSnapshot.get("ProductId") || {}).id)
          .filter(Boolean)
      ),
    ];
    const productSnapshots = productIds.length
      ? await firestore.getAll(
          ...productIds.map((id) => firestore.collection("ProductMaster").doc(id))
        )
      : [];
    const productNameById = new Map(
      productSnapshots.map((snap) => [snap.id, String((snap.data() || {}).Name || "").trim()])
    );

    const stockSnapshot = await ownerRef.collection("Stock").get();
    const stockRefByName = new Map();
    stockSnapshot.forEach((doc) => {
      const name = String((doc.data() || {}).Name || "").trim().toLowerCase();
      if (name && !stockRefByName.has(name)) stockRefByName.set(name, doc.ref);
    });

    for (const { itemSnapshot, quantityReceived, discrepancy } of normalizedItems) {
      batch.update(itemSnapshot.ref, {
        QuantityReceived: quantityReceived,
        Discrepancy: discrepancy || null,
      });
      const productRef = itemSnapshot.get("ProductId");
      const movementRef = ownerRef.collection("StockMovement").doc();
      batch.set(movementRef, {
        ProductId: productRef,
        OutletId: receipt.OutletId,
        Quantity: quantityReceived,
        MovementType: "RECEIVED",
        Reason: "PULSE_DISPATCH",
        MovementReference: receipt.DeliveryNoteNumber || "",
        RecordedById: ownerRef,
        CreatedAt: now,
      });

      // Apply the stock increase (existing doc incremented, new doc created).
      const productName = productNameById.get((productRef || {}).id) || "";
      if (quantityReceived > 0 && productName) {
        const key = productName.toLowerCase();
        const existingStockRef = stockRefByName.get(key);
        if (existingStockRef) {
          batch.update(existingStockRef, {
            Quantity: admin.firestore.FieldValue.increment(quantityReceived),
            UpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          const newStockRef = ownerRef.collection("Stock").doc();
          stockRefByName.set(key, newStockRef);
          batch.set(newStockRef, {
            Name: productName,
            ProductRef: productRef,
            Quantity: quantityReceived,
            Price: 0,
            CostOfGoods: 0,
            LimitNotice: 0,
            CreatedAt: admin.firestore.FieldValue.serverTimestamp(),
            UpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
            ImportSource: "PULSE_DISPATCH",
          });
        }
      }
    }

    await batch.commit();
    return { success: true, status: hasDiscrepancy ? "DISCREPANCY" : "CONFIRMED" };
  });

// Imports a verified historical pharmacy reconciliation. This is deliberately
// server-side so only Pulse administrators can create backdated stock records
// in an explicitly selected, approved pharmacy workspace.
exports.importHistoricalReconciliation = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Sign in to import a reconciliation.");
    }

    const firestore = admin.firestore();
    const callerRef = firestore.collection("User").doc(context.auth.uid);
    const callerSnapshot = await callerRef.get();
    const caller = callerSnapshot.data() || {};
    const callerRole = String(caller.role || "").trim().toLowerCase();
    const isPulseAdmin = getAccountType(caller) === "pulse" &&
      ["admin", "owner", "duniya_admin", "duniyaadmin"].includes(callerRole);
    if (!isPulseAdmin) {
      throw new functions.https.HttpsError("permission-denied", "Only Pulse administrators can import reconciliation data.");
    }

    const pharmacyPath = String(data?.pharmacyPath || "").trim();
    const reconciliationDateMs = Number(data?.reconciliationDate);
    const sourceFileName = String(data?.sourceFileName || "").trim();
    const records = Array.isArray(data?.records) ? data.records : [];
    if (!/^User\/[^/]+\/Pharmacy\/[^/]+$/.test(pharmacyPath) || !Number.isFinite(reconciliationDateMs) || records.length === 0 || records.length > 400) {
      throw new functions.https.HttpsError("invalid-argument", "A pharmacy, reconciliation date, and 1-400 reconciliation lines are required.");
    }

    const pharmacyRef = firestore.doc(pharmacyPath);
    const pharmacySnapshot = await pharmacyRef.get();
    const pharmacy = pharmacySnapshot.data() || {};
    const ownerRef = pharmacy.UserID;
    const pharmacyName = String(pharmacy.Name || "").trim();
    if (!pharmacySnapshot.exists || !ownerRef || !pharmacyName || pharmacy.deleted === true ||
      String(pharmacy.NetworkStatus || "").toLowerCase() !== "active") {
      throw new functions.https.HttpsError("failed-precondition", "Select an approved active pharmacy for this reconciliation.");
    }

    const normalizedRecords = records.map((record, index) => {
      const name = String(record?.name || "").trim();
      const description = String(record?.description || "").trim();
      const openingStock = Number(record?.openingStock || 0);
      const stockSupplied = Number(record?.stockSupplied || 0);
      const totalAvailable = Number(record?.totalAvailable || 0);
      const physicalCount = Number(record?.physicalCount || 0);
      const unitsDispensed = Number(record?.unitsDispensed || 0);
      const unitCost = Number(record?.unitCost || 0);
      if (!name || [openingStock, stockSupplied, totalAvailable, physicalCount, unitsDispensed, unitCost]
        .every(Number.isFinite) === false || [openingStock, stockSupplied, totalAvailable, physicalCount, unitsDispensed]
        .some((value) => !Number.isInteger(value) || value < 0) || unitCost < 0 ||
        totalAvailable !== openingStock + stockSupplied || unitsDispensed !== totalAvailable - physicalCount) {
        throw new functions.https.HttpsError("invalid-argument", `Invalid reconciliation line ${index + 1}.`);
      }
      return { name, description, openingStock, stockSupplied, totalAvailable, physicalCount, unitsDispensed, unitCost };
    });

    const date = admin.firestore.Timestamp.fromMillis(reconciliationDateMs);
    const reconciliationKey = new Date(reconciliationDateMs).toISOString().slice(0, 10);
    const stockCountRef = ownerRef.collection("StockCount").doc(`reconciliation-${reconciliationKey}`);
    const sourceLabel = `Historical reconciliation: ${sourceFileName || pharmacyName}`;
    const writes = [];

    writes.push({ ref: stockCountRef, data: {
      OutletId: pharmacyRef,
      CountedById: callerRef,
      CountDate: date,
      Status: "IMPORTED_RECONCILIATION",
      Notes: `${sourceLabel}. Imported by Pulse on ${new Date().toISOString()}.`,
      CreatedAt: date,
      UpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }});

    for (const record of normalizedRecords) {
      const productKey = `${record.name}|${record.description}`.toLowerCase();
      const productHash = crypto.createHash("sha256").update(productKey).digest("hex").slice(0, 20);
      const productRef = firestore.collection("ProductMaster").doc(`recon-${productHash}`);
      const stockRef = ownerRef.collection("Stock").doc(`recon-${productHash}`);
      const itemRef = stockCountRef.collection("StockCountItem").doc(`recon-${productHash}`);
      writes.push({ ref: productRef, data: {
        Name: record.name,
        PackSize: record.description || null,
        UnitOfMeasure: record.description || null,
        SKU: `SOS-${productHash.toUpperCase()}`,
        CostPrice: record.unitCost,
        IsActive: true,
        CreatedAt: date,
        UpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        ImportSource: sourceLabel,
      }});
      writes.push({ ref: stockRef, data: {
        Name: record.name,
        Description: record.description || null,
        Quantity: record.physicalCount,
        Price: record.unitCost,
        CostOfGoods: record.unitCost,
        Pharmacy: pharmacyName,
        UserId: ownerRef,
        InitialQuantity: record.totalAvailable,
        LimitNotice: 0,
        ImportSource: sourceLabel,
        ReconciliationDate: date,
      }});
      writes.push({ ref: itemRef, data: {
        ProductId: productRef,
        SystemQuantity: record.totalAvailable,
        CountedQuantity: record.physicalCount,
        Variance: -record.unitsDispensed,
        Explanation: `Imported from ${reconciliationKey} reconciliation.`,
      }});
      if (record.totalAvailable > 0) {
        writes.push({ ref: ownerRef.collection("StockMovement").doc(`recon-received-${reconciliationKey}-${productHash}`), data: {
          ProductId: productRef, OutletId: pharmacyRef, Quantity: record.totalAvailable,
          MovementType: "RECEIVED", Reason: "HISTORICAL_RECONCILIATION_BASELINE",
          MovementReference: stockCountRef.path, RecordedById: callerRef, CreatedAt: date,
        }});
      }
      if (record.unitsDispensed > 0) {
        writes.push({ ref: ownerRef.collection("StockMovement").doc(`recon-sold-${reconciliationKey}-${productHash}`), data: {
          ProductId: productRef, OutletId: pharmacyRef, Quantity: record.unitsDispensed,
          MovementType: "SOLD", Reason: "HISTORICAL_RECONCILIATION_DISPENSED",
          MovementReference: stockCountRef.path, RecordedById: callerRef, CreatedAt: date,
        }});
      }
    }

    for (let start = 0; start < writes.length; start += 450) {
      const batch = firestore.batch();
      for (const write of writes.slice(start, start + 450)) batch.set(write.ref, write.data, { merge: true });
      await batch.commit();
    }
    await firestore.collection("AuditLogs").add({
      action: "historical_reconciliation_imported", actorId: context.auth.uid,
      pharmacyRef, pharmacyName, reconciliationDate: date, sourceFileName: sourceFileName || null,
      productLines: normalizedRecords.length, createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: true, pharmacyPath: pharmacyRef.path, productLines: normalizedRecords.length, stockCountPath: stockCountRef.path };
  });

// Pulse network administrators can manage only other Pulse accounts. The
// callable boundary prevents browser clients from changing roles or suspending
// accounts by writing directly to Firestore.
exports.managePulseUser = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Sign in to manage users.");
    }

    const firestore = admin.firestore();
    const callerSnapshot = await firestore.collection("User").doc(context.auth.uid).get();
    const caller = callerSnapshot.data() || {};
    const callerRole = String(caller.role || "").trim().toLowerCase();
    const isPulseAdmin = getAccountType(caller) === "pulse" &&
      ["admin", "owner", "duniya_admin", "duniyaadmin"].includes(callerRole);
    if (!isPulseAdmin) {
      throw new functions.https.HttpsError("permission-denied", "Only Pulse network administrators can manage Pulse users.");
    }

    const userId = String(data?.userId || "").trim();
    const action = String(data?.action || "").trim();
    if (!userId || !["setRole", "setStatus"].includes(action)) {
      throw new functions.https.HttpsError("invalid-argument", "A user and supported management action are required.");
    }
    if (userId === context.auth.uid) {
      throw new functions.https.HttpsError("failed-precondition", "You cannot change your own access from this screen.");
    }

    const targetRef = firestore.collection("User").doc(userId);
    const targetSnapshot = await targetRef.get();
    const target = targetSnapshot.data() || {};
    if (!targetSnapshot.exists || getAccountType(target) !== "pulse") {
      throw new functions.https.HttpsError("not-found", "The selected account is not a Pulse user.");
    }

    if (action === "setRole") {
      const role = String(data?.role || "").trim().toLowerCase();
      if (!['admin', 'staff'].includes(role)) {
        throw new functions.https.HttpsError("invalid-argument", "Pulse users can be assigned Admin or Staff roles.");
      }
      await targetRef.update({ role: role === "admin" ? "Admin" : "Staff", updated_at: admin.firestore.FieldValue.serverTimestamp() });
    } else {
      const suspended = Boolean(data?.suspended);
      await admin.auth().updateUser(userId, { disabled: suspended });
      await targetRef.update({ account_status: suspended ? "suspended" : "active", updated_at: admin.firestore.FieldValue.serverTimestamp() });
    }

    await firestore.collection("AuditLogs").add({
      actorId: context.auth.uid,
      actorEmail: caller.email || "",
      actorName: caller.display_name || "",
      scopeId: "Pulse",
      eventName: `pulse_user_${action}`,
      parameters: { targetUserId: userId, action },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      clientCreatedAt: admin.firestore.Timestamp.now(),
    });
    return { success: true };
  });

// Creates a Pulse-only account and sends a password-setup invitation. Keeping
// the operation callable ensures browser clients never create privileged users
// or choose their account type directly in Firestore.
exports.invitePulseUser = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Sign in to invite Pulse users.");
    }

    const firestore = admin.firestore();
    const callerSnapshot = await firestore.collection("User").doc(context.auth.uid).get();
    const caller = callerSnapshot.data() || {};
    const callerRole = String(caller.role || "").trim().toLowerCase();
    const isPulseAdmin = getAccountType(caller) === "pulse" &&
      ["admin", "owner", "duniya_admin", "duniyaadmin"].includes(callerRole);
    if (!isPulseAdmin) {
      throw new functions.https.HttpsError("permission-denied", "Only Pulse network administrators can invite Pulse users.");
    }

    const displayName = String(data?.displayName || "").trim().replace(/\s+/g, " ");
    const email = String(data?.email || "").trim().toLowerCase();
    const role = String(data?.role || "staff").trim().toLowerCase();
    if (displayName.length < 2 || displayName.length > 100) {
      throw new functions.https.HttpsError("invalid-argument", "Enter the user's full name.");
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      throw new functions.https.HttpsError("invalid-argument", "Enter a valid email address.");
    }
    if (!["admin", "staff"].includes(role)) {
      throw new functions.https.HttpsError("invalid-argument", "Choose either the Admin or Staff role.");
    }
    if (!functions.config().resend?.key) {
      throw new functions.https.HttpsError("failed-precondition", "The Pulse email service is not configured.");
    }

    try {
      await admin.auth().getUserByEmail(email);
      throw new functions.https.HttpsError("already-exists", "An account already exists for this email address.");
    } catch (error) {
      if (error instanceof functions.https.HttpsError) throw error;
      if (error.code !== "auth/user-not-found") throw error;
    }

    const user = await admin.auth().createUser({
      email,
      displayName,
      // A cryptographically-random secret prevents sign-in until the invitee
      // chooses a password through the invitation link.
      password: crypto.randomBytes(32).toString("base64url"),
    });
    const userRef = firestore.collection("User").doc(user.uid);
    const now = admin.firestore.FieldValue.serverTimestamp();
    await userRef.set({
      uid: user.uid,
      email,
      display_name: displayName,
      role: role === "admin" ? "Admin" : "Staff",
      account_type: "Pulse",
      approved_by_duniya: true,
      account_status: "invited",
      invitation_status: "sending",
      invited_by: firestore.collection("User").doc(context.auth.uid),
      created_time: now,
      updated_at: now,
    }, { merge: true });

    try {
      const setupLink = await admin.auth().generatePasswordResetLink(email, {
        url: getConfiguredPortalUrl(),
        handleCodeInApp: false,
      });
      const safeName = displayName.replace(/[&<>"']/g, (character) => ({
        "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#039;",
      }[character]));
      const response = await axios.post(`${RESEND_API_URL}/emails`, {
        from: getConfiguredResendFrom(),
        to: [email],
        subject: "You're invited to Pulse",
        html: `<!doctype html><html><body style="margin:0;background:#f7f4ff;font-family:Arial,sans-serif;color:#15182b"><div style="max-width:560px;margin:32px auto;background:#fff;border-radius:20px;overflow:hidden;border:1px solid #e8ddff"><div style="padding:32px;background:linear-gradient(135deg,#9900ff,#2563eb);color:#fff"><div style="font-size:28px;font-weight:800">Welcome to Pulse</div><div style="margin-top:8px;font-size:16px;opacity:.9">Your network workspace is ready.</div></div><div style="padding:32px"><p style="font-size:16px;line-height:1.6">Hi ${safeName},</p><p style="font-size:16px;line-height:1.6">You've been invited to Pulse as a <strong>${role === "admin" ? "Network Administrator" : "Network Staff member"}</strong>. Set a secure password to activate your account.</p><p style="margin:28px 0"><a href="${setupLink}" style="display:inline-block;padding:14px 22px;background:#9900ff;border-radius:10px;color:#fff;font-weight:700;text-decoration:none">Set up your account</a></p><p style="font-size:13px;line-height:1.5;color:#667085">If you were not expecting this invitation, you can safely ignore this email.</p></div></div></body></html>`,
        text: `Hi ${displayName},\n\nYou've been invited to Pulse as ${role === "admin" ? "a Network Administrator" : "a Network Staff member"}. Set up your account: ${setupLink}`,
      }, {
        headers: { Authorization: `Bearer ${functions.config().resend.key}`, "Content-Type": "application/json" },
      });
      await userRef.update({
        invitation_status: "sent",
        invitation_sent_at: now,
        resend_message_id: response.data?.id || null,
        updated_at: now,
      });
    } catch (error) {
      console.error("Unable to deliver Pulse invitation:", error);
      await userRef.update({ invitation_status: "failed", updated_at: now });
      throw new functions.https.HttpsError("internal", "The account was created, but the invitation could not be delivered.");
    }

    await firestore.collection("AuditLogs").add({
      actorId: context.auth.uid,
      actorEmail: caller.email || "",
      actorName: caller.display_name || "",
      scopeId: "Pulse",
      eventName: "pulse_user_invited",
      parameters: { targetUserId: user.uid, email, role },
      createdAt: now,
      clientCreatedAt: admin.firestore.Timestamp.now(),
    });
    return { success: true, userId: user.uid };
  });

// ══════════════════════════════════════════════════════════════
// Existing Functions
// ══════════════════════════════════════════════════════════════

exports.onUserDeleted = functions
  .region("us-central1")
  .auth.user()
  .onDelete(async (user) => {
    let firestore = admin.firestore();
    let userRef = firestore.doc("User/" + user.uid);
    await firestore.collection("User").doc(user.uid).delete();
  });
