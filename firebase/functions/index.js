const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios").default;
admin.initializeApp();

// ══════════════════════════════════════════════════════════════
// Resend Email Service
// ══════════════════════════════════════════════════════════════
// API key is stored in Firebase environment config:
//   firebase functions:config:set resend.key="re_xxxxx"
// Never hardcode API keys in source code.

const RESEND_API_URL = "https://api.resend.com";

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
  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:#7c3aed;padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">Welcome to Pulse</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:16px;color:#333">Hi ${displayName},</p>
    <p style="font-size:15px;color:#555;line-height:1.6">Welcome to Pulse — your pharmacy and inventory management platform. You're all set to get started.</p>
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

    // Verify webhook signature if Svix secret is configured
    const svixSecret = functions.config().resend?.webhook_secret;
    if (svixSecret) {
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
    }

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

    if (!email || !name || !role) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "email, name, and role are required."
      );
    }

    const firestore = admin.firestore();

    // Generate a secure random token for the invitation
    const crypto = require("crypto");
    const token = crypto.randomBytes(32).toString("hex");
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7-day expiry

    // Create the invitation document
    const invitationRef = await firestore.collection("StaffInvitations").add({
      email: email.toLowerCase().trim(),
      name: name,
      role: role,
      pharmacyName: pharmacyName || "",
      pharmacyId: pharmacyId || null,
      staffId: staffId || null,
      inviterUid: context.auth.uid,
      token: token,
      status: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: expiresAt,
    });

    // Build the invitation URL
    const appUrl = `https://thestackone.com/app.html`;
    const invitationUrl = `${appUrl}/#/accept-invitation?token=${token}&email=${encodeURIComponent(email)}`;

    // Role display label
    const roleLabel = role;

    // Send the invitation email via Resend
    const resendKey = functions.config().resend?.key;
    if (!resendKey) {
      console.error("[StaffInvitation] Resend API key not configured.");
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
              © 2025 Pulse by StackOne · Powered by Resend
            </p>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;

    const fromAddress = "Pulse <noreply@thestackone.com>";

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
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
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
      console.error(`[StaffInvitation] Failed to send email to ${email}:`, error.message);
      throw new functions.https.HttpsError(
        "internal",
        `Failed to send invitation email: ${error.message}`
      );
    }
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
