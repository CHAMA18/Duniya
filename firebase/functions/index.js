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
      from: from || getConfiguredResendFrom(),
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
        from: from || getConfiguredResendFrom(),
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
    from: from || getConfiguredResendFrom(),
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
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Welcome to Pulse</title>
  <!--[if mso]>
  <noscript><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml></noscript>
  <![endif]-->
  <style>
    @media only screen and (max-width: 620px) {
      .email-container { width: 100% !important; }
      .pad-mobile { padding-left: 24px !important; padding-right: 24px !important; }
    }
  </style>
</head>
<body style="margin:0;padding:0;word-spacing:normal;background-color:#F0F0F5;font-family:'Inter',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <div role="article" aria-roledescription="email" lang="en" style="text-size-adjust:100%;">
    <div style="display:none;font-size:1px;color:#F0F0F5;line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;">
      Welcome to Pulse — your pharmacy and inventory management platform. You're all set to get started.
    </div>

    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color:#F0F0F5;">
      <tr>
        <td align="center" style="padding:40px 16px 60px;">
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="max-width:520px;margin:0 auto;" class="email-container">

            <!-- Header -->
            <tr>
              <td style="padding:0 0 2px;background:linear-gradient(135deg,#7C3AED 0%,#9900FF 40%,#6D28D9 100%);border-radius:20px 20px 0 0;">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>
                    <td style="padding:28px 40px 0;text-align:center;" class="pad-mobile">
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center"><tr>
                        <td style="background:rgba(255,255,255,0.15);border-radius:12px;padding:10px 20px;">
                          <table role="presentation" cellspacing="0" cellpadding="0" border="0"><tr>
                            <td style="vertical-align:middle;"><svg width="28" height="28" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg" style="display:inline-block;vertical-align:middle;"><rect width="28" height="28" rx="6" fill="rgba(255,255,255,0.2)"/><rect x="11" y="5" width="6" height="18" rx="2" fill="white"/><rect x="5" y="11" width="18" height="6" rx="2" fill="white"/></svg></td>
                            <td style="vertical-align:middle;padding-left:10px;"><span style="color:#ffffff;font-size:22px;font-weight:800;letter-spacing:-0.5px;">Pulse</span></td>
                          </tr></table>
                        </td>
                      </tr></table>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:28px 40px 36px;text-align:center;" class="pad-mobile">
                      <h1 style="margin:0;color:#ffffff;font-size:26px;font-weight:800;letter-spacing:-0.5px;line-height:1.3;">Welcome to Pulse</h1>
                      <div style="margin:12px auto 0;background:rgba(255,255,255,0.18);border-radius:8px;padding:8px 20px;display:inline-block;">
                        <span style="color:#ffffff;font-size:15px;font-weight:600;">Modern Pharmacy Intelligence</span>
                      </div>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- Greeting -->
            <tr>
              <td style="background:#ffffff;padding:40px 40px 0;" class="pad-mobile">
                <p style="margin:0;color:#0B1C30;font-size:17px;font-weight:600;">Hi ${displayName},</p>
                <p style="margin:12px 0 0;color:#475569;font-size:15px;line-height:1.7;">Welcome to Pulse — your pharmacy and inventory management platform. You're all set to get started.</p>
                <p style="margin:12px 0 0;color:#475569;font-size:15px;line-height:1.7;">You can log in anytime to manage your pharmacy, track inventory, process sales, and more.</p>
              </td>
            </tr>

            <!-- CTA -->
            <tr>
              <td style="background:#ffffff;padding:32px 40px;" class="pad-mobile">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%"><tr><td align="center">
                  <a href="${portalUrl}" target="_blank" style="display:inline-block;background:linear-gradient(135deg,#7C3AED 0%,#9900FF 50%,#6D28D9 100%);color:#ffffff;font-size:16px;font-weight:700;text-decoration:none;padding:16px 48px;border-radius:14px;box-shadow:0 4px 14px rgba(124,58,237,0.35);">Open Pulse &rarr;</a>
                </td></tr></table>
              </td>
            </tr>

            <!-- Features -->
            <tr>
              <td style="background:#ffffff;padding:0 40px 32px;" class="pad-mobile">
                <p style="margin:0 0 16px;color:#64748B;font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:1px;text-align:center;">What you can do</p>
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background:#FAFBFF;border-radius:12px;border:1px solid #F1F5F9;">
                  <tr><td style="padding:20px 24px;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                      <tr><td width="36" style="vertical-align:top;padding-right:12px;"><span style="font-size:18px;">📊</span></td><td style="vertical-align:top;padding-bottom:12px;"><p style="margin:0;color:#0B1C30;font-size:14px;font-weight:600;">Real-time Dashboard</p><p style="margin:2px 0 0;color:#64748B;font-size:13px;">Track sales, inventory, and performance at a glance</p></td></tr>
                      <tr><td width="36" style="vertical-align:top;padding-right:12px;"><span style="font-size:18px;">💊</span></td><td style="vertical-align:top;padding-bottom:12px;"><p style="margin:0;color:#0B1C30;font-size:14px;font-weight:600;">Inventory Management</p><p style="margin:2px 0 0;color:#64748B;font-size:13px;">Stock tracking, low alerts, and batch expiry monitoring</p></td></tr>
                      <tr><td width="36" style="vertical-align:top;padding-right:12px;"><span style="font-size:18px;">🛒</span></td><td style="vertical-align:top;"><p style="margin:0;color:#0B1C30;font-size:14px;font-weight:600;">Point of Sale</p><p style="margin:2px 0 0;color:#64748B;font-size:13px;">Process sales and manage transactions seamlessly</p></td></tr>
                    </table>
                  </td></tr>
                </table>
              </td>
            </tr>

            <!-- Footer -->
            <tr>
              <td style="background:#ffffff;padding:24px 40px 0;border-top:1px solid #F1F5F9;" class="pad-mobile">
                <p style="margin:0 0 8px;color:#94A3B8;font-size:12px;text-align:center;">Sent with care by the <strong style="color:#7C3AED;">Pulse</strong> team</p>
                <p style="margin:0;color:#CBD5E1;font-size:11px;text-align:center;">Pulse — Modern Pharmacy Intelligence</p>
              </td>
            </tr>

            <!-- Bottom Bar -->
            <tr><td>
              <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background:linear-gradient(135deg,#7C3AED 0%,#9900FF 40%,#6D28D9 100%);border-radius:0 0 20px 20px;">
                <tr><td style="padding:16px 40px;text-align:center;" class="pad-mobile"><p style="margin:0;color:rgba(255,255,255,0.7);font-size:11px;letter-spacing:0.5px;">&copy; 2025 Duniya Healthcare &bull; Powered by Pulse</p></td></tr>
              </table>
            </td></tr>

          </table>
        </td>
      </tr>
    </table>
  </div>
</body>
</html>`;
}

function lowStockTemplate(pharmacyName, productName, currentStock, reorderLevel) {
  const percentage = Math.round((currentStock / reorderLevel) * 100);
  const barColor = percentage <= 25 ? '#DC2626' : percentage <= 50 ? '#F59E0B' : '#EAB308';
  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Low Stock Alert — ${pharmacyName}</title>
  <!--[if mso]>
  <noscript><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml></noscript>
  <![endif]-->
  <style>
    @media only screen and (max-width: 620px) {
      .email-container { width: 100% !important; }
      .pad-mobile { padding-left: 24px !important; padding-right: 24px !important; }
    }
  </style>
</head>
<body style="margin:0;padding:0;word-spacing:normal;background-color:#F0F0F5;font-family:'Inter',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <div role="article" aria-roledescription="email" lang="en" style="text-size-adjust:100%;">
    <!-- Preheader -->
    <div style="display:none;font-size:1px;color:#F0F0F5;line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;">
      Low stock alert: ${productName} at ${pharmacyName} — ${currentStock} remaining (reorder at ${reorderLevel}).
    </div>

    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color:#F0F0F5;">
      <tr>
        <td align="center" style="padding:40px 16px 60px;">
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="max-width:520px;margin:0 auto;" class="email-container">

            <!-- ═══════════ HEADER — Pulse Brand + Alert Badge ═══════════ -->
            <tr>
              <td style="padding:0 0 2px;background:linear-gradient(135deg,#7C3AED 0%,#9900FF 40%,#6D28D9 100%);border-radius:20px 20px 0 0;">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <!-- Pulse Logo -->
                  <tr>
                    <td style="padding:28px 40px 0;text-align:center;" class="pad-mobile">
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center">
                        <tr>
                          <td style="background:rgba(255,255,255,0.15);border-radius:12px;padding:10px 20px;">
                            <table role="presentation" cellspacing="0" cellpadding="0" border="0"><tr>
                              <td style="vertical-align:middle;">
                                <svg width="28" height="28" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg" style="display:inline-block;vertical-align:middle;"><rect width="28" height="28" rx="6" fill="rgba(255,255,255,0.2)"/><rect x="11" y="5" width="6" height="18" rx="2" fill="white"/><rect x="5" y="11" width="18" height="6" rx="2" fill="white"/></svg>
                              </td>
                              <td style="vertical-align:middle;padding-left:10px;">
                                <span style="color:#ffffff;font-family:'Inter',sans-serif;font-size:22px;font-weight:800;letter-spacing:-0.5px;">Pulse</span>
                              </td>
                            </tr></table>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  <!-- Alert Title -->
                  <tr>
                    <td style="padding:28px 40px 36px;text-align:center;" class="pad-mobile">
                      <h1 style="margin:0;color:#ffffff;font-size:26px;font-weight:800;letter-spacing:-0.5px;line-height:1.3;">
                        ⚠️ Low Stock Alert
                      </h1>
                      <div style="margin:12px auto 0;background:rgba(220,38,38,0.3);border-radius:8px;padding:8px 20px;display:inline-block;">
                        <span style="color:#ffffff;font-size:15px;font-weight:600;">${pharmacyName}</span>
                      </div>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ GREETING ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:40px 40px 0;" class="pad-mobile">
                <p style="margin:0;color:#0B1C30;font-size:15px;line-height:1.7;">
                  The following item at <strong style="color:#0B1C30;">${pharmacyName}</strong> is running low and needs attention:
                </p>
              </td>
            </tr>

            <!-- ═══════════ PRODUCT ALERT CARD ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:24px 40px 0;" class="pad-mobile">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="border:1px solid #FEE2E2;border-radius:14px;overflow:hidden;">
                  <!-- Card Header -->
                  <tr>
                    <td style="background:linear-gradient(135deg,#FEF2F2 0%,#FEE2E2 100%);padding:16px 24px;border-bottom:1px solid #FECACA;">
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                          <td style="vertical-align:middle;">
                            <span style="font-size:11px;font-weight:700;color:#DC2626;text-transform:uppercase;letter-spacing:1.2px;">⚠️ Reorder Required</span>
                          </td>
                          <td align="right" style="vertical-align:middle;">
                            <span style="display:inline-block;background:linear-gradient(135deg,#DC2626,#B91C1C);color:#ffffff;font-size:11px;font-weight:700;padding:4px 12px;border-radius:20px;text-transform:uppercase;letter-spacing:0.5px;">Low Stock</span>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  <!-- Card Body -->
                  <tr>
                    <td style="padding:24px;">
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <!-- Product Name -->
                        <tr>
                          <td width="48" style="vertical-align:top;padding-right:16px;">
                            <div style="width:44px;height:44px;background:linear-gradient(135deg,#DC2626,#B91C1C);border-radius:12px;text-align:center;line-height:44px;">
                              <span style="font-size:20px;">💊</span>
                            </div>
                          </td>
                          <td style="vertical-align:top;">
                            <p style="margin:0 0 4px;color:#64748B;font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.8px;">Product</p>
                            <p style="margin:0;color:#0B1C30;font-size:16px;font-weight:700;">${productName}</p>
                          </td>
                        </tr>
                        <tr><td colspan="2" style="padding:16px 0;"><div style="border-top:1px solid #F1F5F9;"></div></td></tr>
                        <!-- Stock Levels -->
                        <tr>
                          <td colspan="2">
                            <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                              <tr>
                                <td width="50%" style="padding-right:8px;">
                                  <div style="background:#FEF2F2;border-radius:10px;padding:14px 16px;text-align:center;">
                                    <p style="margin:0 0 4px;color:#64748B;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.8px;">In Stock</p>
                                    <p style="margin:0;color:#DC2626;font-size:28px;font-weight:800;line-height:1;">${currentStock}</p>
                                  </div>
                                </td>
                                <td width="50%" style="padding-left:8px;">
                                  <div style="background:#F0FDF4;border-radius:10px;padding:14px 16px;text-align:center;">
                                    <p style="margin:0 0 4px;color:#64748B;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.8px;">Reorder At</p>
                                    <p style="margin:0;color:#16A34A;font-size:28px;font-weight:800;line-height:1;">${reorderLevel}</p>
                                  </div>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                        <!-- Stock Progress Bar -->
                        <tr><td colspan="2" style="padding:20px 0 0;">
                          <p style="margin:0 0 8px;color:#64748B;font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.8px;">Stock Level</p>
                          <div style="background:#F1F5F9;border-radius:8px;height:12px;overflow:hidden;">
                            <div style="background:${barColor};width:${Math.min(percentage, 100)}%;height:12px;border-radius:8px;min-width:8px;"></div>
                          </div>
                          <p style="margin:8px 0 0;color:${barColor};font-size:12px;font-weight:600;">${percentage}% of reorder level</p>
                        </td></tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ CTA BUTTON ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:32px 40px;" class="pad-mobile">
                <p style="margin:0 0 20px;color:#475569;font-size:15px;line-height:1.6;text-align:center;">
                  Review your inventory and place a replenishment order:
                </p>
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>
                    <td align="center">
                      <a href="${getConfiguredPortalUrl()}" target="_blank" style="display:inline-block;background:linear-gradient(135deg,#7C3AED 0%,#9900FF 50%,#6D28D9 100%);color:#ffffff;font-family:'Inter',sans-serif;font-size:16px;font-weight:700;text-decoration:none;padding:16px 48px;border-radius:14px;box-shadow:0 4px 14px rgba(124,58,237,0.35);">
                        Open Pulse &rarr;
                      </a>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ TIPS CARD ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:0 40px 32px;" class="pad-mobile">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background:#FAFBFF;border-radius:12px;border:1px solid #F1F5F9;">
                  <tr>
                    <td style="padding:20px 24px;">
                      <p style="margin:0 0 12px;color:#64748B;font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:1px;">💡 Quick Actions</p>
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                          <td width="28" style="vertical-align:top;padding-right:10px;"><span style="font-size:14px;">📋</span></td>
                          <td style="padding-bottom:10px;"><p style="margin:0;color:#0B1C30;font-size:13px;line-height:1.5;">Create a <strong>purchase order</strong> for this product</p></td>
                        </tr>
                        <tr>
                          <td width="28" style="vertical-align:top;padding-right:10px;"><span style="font-size:14px;">🔄</span></td>
                          <td style="padding-bottom:10px;"><p style="margin:0;color:#0B1C30;font-size:13px;line-height:1.5;">Check <strong>stock movements</strong> to identify usage patterns</p></td>
                        </tr>
                        <tr>
                          <td width="28" style="vertical-align:top;padding-right:10px;"><span style="font-size:14px;">🤝</span></td>
                          <td><p style="margin:0;color:#0B1C30;font-size:13px;line-height:1.5;">Request a <strong>Pulse dispatch</strong> from the network</p></td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ FOOTER ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:24px 40px 0;border-top:1px solid #F1F5F9;" class="pad-mobile">
                <p style="margin:0 0 8px;color:#94A3B8;font-size:12px;text-align:center;">Automated alert by <strong style="color:#7C3AED;">Pulse</strong> — Inventory Intelligence</p>
                <p style="margin:0;color:#CBD5E1;font-size:11px;text-align:center;">Pulse — Modern Pharmacy Intelligence</p>
              </td>
            </tr>

            <!-- ═══════════ BOTTOM BAR ═══════════ -->
            <tr>
              <td>
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background:linear-gradient(135deg,#7C3AED 0%,#9900FF 40%,#6D28D9 100%);border-radius:0 0 20px 20px;">
                  <tr>
                    <td style="padding:16px 40px;text-align:center;" class="pad-mobile">
                      <p style="margin:0;color:rgba(255,255,255,0.7);font-size:11px;letter-spacing:0.5px;">
                        &copy; 2025 Duniya Healthcare &bull; Powered by Pulse
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

          </table>
        </td>
      </tr>
    </table>
  </div>
</body>
</html>`;
}

function expiryWarningTemplate(pharmacyName, items) {
  const rows = items
    .map(
      (i) => `<tr>
        <td style="padding:14px 16px;border-bottom:1px solid #F1F5F9;">
          <p style="margin:0;color:#0B1C30;font-size:14px;font-weight:600;">${i.productName}</p>
        </td>
        <td style="padding:14px 16px;border-bottom:1px solid #F1F5F9;text-align:center;">
          <span style="display:inline-block;background:#F1F5F9;color:#475569;font-size:12px;font-weight:600;padding:3px 10px;border-radius:6px;">${i.batchNumber}</span>
        </td>
        <td style="padding:14px 16px;border-bottom:1px solid #F1F5F9;text-align:center;">
          <span style="color:#DC2626;font-size:14px;font-weight:700;">${i.expiryDate}</span>
        </td>
      </tr>`
    )
    .join("");

  const itemCount = items.length;

  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Expiry Warning — ${pharmacyName}</title>
  <!--[if mso]>
  <noscript><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml></noscript>
  <![endif]-->
  <style>
    @media only screen and (max-width: 620px) {
      .email-container { width: 100% !important; }
      .pad-mobile { padding-left: 24px !important; padding-right: 24px !important; }
      .stack-column { display: block !important; width: 100% !important; }
    }
  </style>
</head>
<body style="margin:0;padding:0;word-spacing:normal;background-color:#F0F0F5;font-family:'Inter',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <div role="article" aria-roledescription="email" lang="en" style="text-size-adjust:100%;">
    <!-- Preheader -->
    <div style="display:none;font-size:1px;color:#F0F0F5;line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;">
      Expiry warning for ${pharmacyName}: ${itemCount} item(s) expiring within 30 days.
    </div>

    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color:#F0F0F5;">
      <tr>
        <td align="center" style="padding:40px 16px 60px;">
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="max-width:520px;margin:0 auto;" class="email-container">

            <!-- ═══════════ HEADER — Pulse Brand + Alert Badge ═══════════ -->
            <tr>
              <td style="padding:0 0 2px;background:linear-gradient(135deg,#7C3AED 0%,#9900FF 40%,#6D28D9 100%);border-radius:20px 20px 0 0;">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <!-- Pulse Logo -->
                  <tr>
                    <td style="padding:28px 40px 0;text-align:center;" class="pad-mobile">
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center">
                        <tr>
                          <td style="background:rgba(255,255,255,0.15);border-radius:12px;padding:10px 20px;">
                            <table role="presentation" cellspacing="0" cellpadding="0" border="0"><tr>
                              <td style="vertical-align:middle;">
                                <svg width="28" height="28" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg" style="display:inline-block;vertical-align:middle;"><rect width="28" height="28" rx="6" fill="rgba(255,255,255,0.2)"/><rect x="11" y="5" width="6" height="18" rx="2" fill="white"/><rect x="5" y="11" width="18" height="6" rx="2" fill="white"/></svg>
                              </td>
                              <td style="vertical-align:middle;padding-left:10px;">
                                <span style="color:#ffffff;font-family:'Inter',sans-serif;font-size:22px;font-weight:800;letter-spacing:-0.5px;">Pulse</span>
                              </td>
                            </tr></table>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  <!-- Alert Title -->
                  <tr>
                    <td style="padding:28px 40px 36px;text-align:center;" class="pad-mobile">
                      <h1 style="margin:0;color:#ffffff;font-size:26px;font-weight:800;letter-spacing:-0.5px;line-height:1.3;">
                        ⏰ Expiry Warning
                      </h1>
                      <div style="margin:12px auto 0;background:rgba(245,158,11,0.3);border-radius:8px;padding:8px 20px;display:inline-block;">
                        <span style="color:#ffffff;font-size:15px;font-weight:600;">${pharmacyName}</span>
                      </div>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ GREETING ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:40px 40px 0;" class="pad-mobile">
                <p style="margin:0;color:#0B1C30;font-size:15px;line-height:1.7;">
                  The following <strong style="color:#0B1C30;">${itemCount} item(s)</strong> at <strong style="color:#0B1C30;">${pharmacyName}</strong> are expiring within 30 days and require immediate attention:
                </p>
              </td>
            </tr>

            <!-- ═══════════ ITEMS TABLE CARD ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:24px 40px 0;" class="pad-mobile">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="border:1px solid #FEF3C7;border-radius:14px;overflow:hidden;">
                  <!-- Card Header -->
                  <tr>
                    <td style="background:linear-gradient(135deg,#FFFBEB 0%,#FEF3C7 100%);padding:16px 24px;border-bottom:1px solid #FDE68A;">
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                          <td style="vertical-align:middle;">
                            <span style="font-size:11px;font-weight:700;color:#D97706;text-transform:uppercase;letter-spacing:1.2px;">⏰ Expiring Soon</span>
                          </td>
                          <td align="right" style="vertical-align:middle;">
                            <span style="display:inline-block;background:linear-gradient(135deg,#F59E0B,#D97706);color:#ffffff;font-size:11px;font-weight:700;padding:4px 12px;border-radius:20px;text-transform:uppercase;letter-spacing:0.5px;">${itemCount} Items</span>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  <!-- Table Header -->
                  <tr>
                    <td style="padding:0 24px;">
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                          <td style="padding:16px 16px 10px;border-bottom:2px solid #F1F5F9;">
                            <p style="margin:0;color:#64748B;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:0.8px;">Product</p>
                          </td>
                          <td style="padding:16px 16px 10px;border-bottom:2px solid #F1F5F9;text-align:center;">
                            <p style="margin:0;color:#64748B;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:0.8px;">Batch</p>
                          </td>
                          <td style="padding:16px 16px 10px;border-bottom:2px solid #F1F5F9;text-align:center;">
                            <p style="margin:0;color:#64748B;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:0.8px;">Expiry Date</p>
                          </td>
                        </tr>
                        ${rows}
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ CTA BUTTON ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:32px 40px;" class="pad-mobile">
                <p style="margin:0 0 20px;color:#475569;font-size:15px;line-height:1.6;text-align:center;">
                  Review these items and take action to prevent losses:
                </p>
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>
                    <td align="center">
                      <a href="${getConfiguredPortalUrl()}" target="_blank" style="display:inline-block;background:linear-gradient(135deg,#7C3AED 0%,#9900FF 50%,#6D28D9 100%);color:#ffffff;font-family:'Inter',sans-serif;font-size:16px;font-weight:700;text-decoration:none;padding:16px 48px;border-radius:14px;box-shadow:0 4px 14px rgba(124,58,237,0.35);">
                        Open Pulse &rarr;
                      </a>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ TIPS CARD ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:0 40px 32px;" class="pad-mobile">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background:#FAFBFF;border-radius:12px;border:1px solid #F1F5F9;">
                  <tr>
                    <td style="padding:20px 24px;">
                      <p style="margin:0 0 12px;color:#64748B;font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:1px;">💡 Quick Actions</p>
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                          <td width="28" style="vertical-align:top;padding-right:10px;"><span style="font-size:14px;">📋</span></td>
                          <td style="padding-bottom:10px;"><p style="margin:0;color:#0B1C30;font-size:13px;line-height:1.5;">Create a <strong>return order</strong> to your supplier</p></td>
                        </tr>
                        <tr>
                          <td width="28" style="vertical-align:top;padding-right:10px;"><span style="font-size:14px;">🔄</span></td>
                          <td style="padding-bottom:10px;"><p style="margin:0;color:#0B1C30;font-size:13px;line-height:1.5;">Mark expired items as <strong>damaged stock</strong></p></td>
                        </tr>
                        <tr>
                          <td width="28" style="vertical-align:top;padding-right:10px;"><span style="font-size:14px;">📊</span></td>
                          <td><p style="margin:0;color:#0B1C30;font-size:13px;line-height:1.5;">Review <strong>expiry tracking</strong> for trends</p></td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ FOOTER ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:24px 40px 0;border-top:1px solid #F1F5F9;" class="pad-mobile">
                <p style="margin:0 0 8px;color:#94A3B8;font-size:12px;text-align:center;">Automated alert by <strong style="color:#7C3AED;">Pulse</strong> — Expiry Intelligence</p>
                <p style="margin:0;color:#CBD5E1;font-size:11px;text-align:center;">Pulse — Modern Pharmacy Intelligence</p>
              </td>
            </tr>

            <!-- ═══════════ BOTTOM BAR ═══════════ -->
            <tr>
              <td>
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background:linear-gradient(135deg,#7C3AED 0%,#9900FF 40%,#6D28D9 100%);border-radius:0 0 20px 20px;">
                  <tr>
                    <td style="padding:16px 40px;text-align:center;" class="pad-mobile">
                      <p style="margin:0;color:rgba(255,255,255,0.7);font-size:11px;letter-spacing:0.5px;">
                        &copy; 2025 Duniya Healthcare &bull; Powered by Pulse
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

          </table>
        </td>
      </tr>
    </table>
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
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="x-apple-disable-message-reformatting">
  <title>You're Invited to Join ${pharmacyName || 'Pulse'}</title>
  <!--[if mso]>
  <noscript>
    <xml>
      <o:OfficeDocumentSettings>
        <o:AllowPNG/>
        <o:PixelsPerInch>96</o:PixelsPerInch>
      </o:OfficeDocumentSettings>
    </xml>
  </noscript>
  <![endif]-->
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');
    @media only screen and (max-width: 620px) {
      .email-container { width: 100% !important; margin: 0 !important; }
      .fluid { max-width: 100% !important; height: auto !important; margin-left: auto !important; margin-right: auto !important; }
      .stack-column, .stack-column-center { display: block !important; width: 100% !important; max-width: 100% !important; direction: ltr !important; }
      .pad-mobile { padding-left: 24px !important; padding-right: 24px !important; }
    }
  </style>
</head>
<body style="margin:0;padding:0;word-spacing:normal;background-color:#F0F0F5;font-family:'Inter',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <div role="article" aria-roledescription="email" aria-label="Pulse Staff Invitation" lang="en" style="text-size-adjust:100%;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;">
    <!-- Preheader (hidden text for inbox preview) -->
    <div style="display:none;font-size:1px;color:#F0F0F5;line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;">
      You've been invited to join ${pharmacyName || 'Pulse'} as ${roleLabel} on Pulse — the modern pharmacy management platform.
    </div>

    <!-- Email Body -->
    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color:#F0F0F5;">
      <tr>
        <td align="center" style="padding:40px 16px 60px;">
          <!--[if mso]>
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="520" align="center"><tr><td>
          <![endif]-->
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="max-width:520px;margin:0 auto;" class="email-container">

            <!-- ═══════════ HEADER — Pulse Brand Bar ═══════════ -->
            <tr>
              <td style="padding:0 0 2px;background:linear-gradient(135deg,#7C3AED 0%,#9900FF 40%,#6D28D9 100%);border-radius:20px 20px 0 0;">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>
                    <td style="padding:28px 40px 0;text-align:center;" class="pad-mobile">
                      <!-- Pulse Logo -->
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center">
                        <tr>
                          <td style="background:rgba(255,255,255,0.15);border-radius:12px;padding:10px 20px;">
                            <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                              <tr>
                                <td style="vertical-align:middle;">
                                  <!-- Pulse icon: pharmacy cross -->
                                  <svg width="28" height="28" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg" style="display:inline-block;vertical-align:middle;">
                                    <rect width="28" height="28" rx="6" fill="rgba(255,255,255,0.2)"/>
                                    <rect x="11" y="5" width="6" height="18" rx="2" fill="white"/>
                                    <rect x="5" y="11" width="18" height="6" rx="2" fill="white"/>
                                  </svg>
                                </td>
                                <td style="vertical-align:middle;padding-left:10px;">
                                  <span style="color:#ffffff;font-family:'Inter',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;font-size:22px;font-weight:800;letter-spacing:-0.5px;">Pulse</span>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:28px 40px 36px;text-align:center;" class="pad-mobile">
                      <h1 style="margin:0;color:#ffffff;font-size:26px;font-weight:800;letter-spacing:-0.5px;line-height:1.3;">
                        You're Invited to Join
                      </h1>
                      <div style="margin:12px auto 0;background:rgba(255,255,255,0.18);border-radius:8px;padding:8px 20px;display:inline-block;">
                        <span style="color:#ffffff;font-size:15px;font-weight:600;letter-spacing:0.3px;">${pharmacyName || 'Your Pharmacy'}</span>
                      </div>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ GREETING ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:40px 40px 0;" class="pad-mobile">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>
                    <td style="padding-bottom:24px;">
                      <p style="margin:0;color:#0B1C30;font-size:17px;font-weight:600;line-height:1.5;">
                        Hi ${name},
                      </p>
                      <p style="margin:12px 0 0;color:#475569;font-size:15px;line-height:1.7;">
                        You've been invited to join <strong style="color:#0B1C30;">${pharmacyName || 'a pharmacy'}</strong> as a <strong style="color:#7C3AED;">${roleLabel}</strong> on Pulse — the modern pharmacy management platform trusted by pharmacies across the network.
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ ROLE & PHARMACY CARD ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:0 40px;" class="pad-mobile">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="border:1px solid #E9E5F5;border-radius:14px;overflow:hidden;">
                  <!-- Card Header -->
                  <tr>
                    <td style="background:linear-gradient(135deg,#F5F3FF 0%,#EDE9FE 100%);padding:16px 24px;border-bottom:1px solid #E9E5F5;">
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                          <td style="vertical-align:middle;">
                            <span style="font-size:11px;font-weight:700;color:#7C3AED;text-transform:uppercase;letter-spacing:1.2px;">Your Assignment</span>
                          </td>
                          <td align="right" style="vertical-align:middle;">
                            <span style="display:inline-block;background:linear-gradient(135deg,#7C3AED,#9900FF);color:#ffffff;font-size:11px;font-weight:700;padding:4px 12px;border-radius:20px;text-transform:uppercase;letter-spacing:0.5px;">${roleLabel}</span>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  <!-- Card Body -->
                  <tr>
                    <td style="padding:24px;">
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                          <td width="48" style="vertical-align:top;padding-right:16px;">
                            <div style="width:44px;height:44px;background:linear-gradient(135deg,#7C3AED,#9900FF);border-radius:12px;text-align:center;line-height:44px;">
                              <span style="font-size:20px;">${roleLabel === 'Owner' ? '👑' : roleLabel === 'Pharmacist' ? '💊' : roleLabel === 'Cashier' ? '💰' : roleLabel === 'Pharmacy Technician' ? '🔬' : roleLabel === 'Stock Controller' ? '📦' : roleLabel === 'Finance/Admin Viewer' ? '📊' : roleLabel === 'Sales Assistant' ? '🛒' : roleLabel === 'Pharmacy Manager' ? '🏥' : '👤'}</span>
                            </div>
                          </td>
                          <td style="vertical-align:top;">
                            <p style="margin:0 0 4px;color:#64748B;font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.8px;">Role</p>
                            <p style="margin:0;color:#0B1C30;font-size:16px;font-weight:700;">${roleLabel}</p>
                          </td>
                        </tr>
                        <tr><td colspan="2" style="padding:16px 0;"><div style="border-top:1px solid #F1F5F9;"></div></td></tr>
                        <tr>
                          <td width="48" style="vertical-align:top;padding-right:16px;">
                            <div style="width:44px;height:44px;background:linear-gradient(135deg,#2563EB,#3B82F6);border-radius:12px;text-align:center;line-height:44px;">
                              <span style="font-size:20px;">🏪</span>
                            </div>
                          </td>
                          <td style="vertical-align:top;">
                            <p style="margin:0 0 4px;color:#64748B;font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.8px;">Pharmacy</p>
                            <p style="margin:0;color:#0B1C30;font-size:16px;font-weight:700;">${pharmacyName || 'Your Pharmacy'}</p>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ CTA BUTTON ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:32px 40px;" class="pad-mobile">
                <p style="margin:0 0 20px;color:#475569;font-size:15px;line-height:1.6;text-align:center;">
                  Tap below to create your account and start using Pulse:
                </p>
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>
                    <td align="center">
                      <!--[if mso]>
                      <v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="${invitationUrl}" style="height:52px;v-text-anchor:middle;width:280px;" arcsize="19%" stroke="f" fillcolor="#7C3AED">
                        <w:anchorlock/>
                        <center style="color:#ffffff;font-family:'Inter',sans-serif;font-size:16px;font-weight:700;">
                          Accept Invitation →
                        </center>
                      </v:roundrect>
                      <![endif]-->
                      <!--[if !mso]><!-->
                      <a href="${invitationUrl}" target="_blank" style="display:inline-block;background:linear-gradient(135deg,#7C3AED 0%,#9900FF 50%,#6D28D9 100%);color:#ffffff;font-family:'Inter',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;font-size:16px;font-weight:700;text-decoration:none;padding:16px 48px;border-radius:14px;letter-spacing:0.3px;text-align:center;box-shadow:0 4px 14px rgba(124,58,237,0.35);transition:all 0.2s ease;">
                        Accept Invitation &rarr;
                      </a>
                      <!--<![endif]-->
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ WHAT YOU CAN DO (Feature Highlights) ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:0 40px 32px;" class="pad-mobile">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>
                    <td style="padding-bottom:16px;">
                      <p style="margin:0;color:#64748B;font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:1px;text-align:center;">What you'll get access to</p>
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background:#FAFBFF;border-radius:12px;border:1px solid #F1F5F9;">
                        <tr>
                          <td style="padding:20px 24px;">
                            <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                              <tr>
                                <td width="36" style="vertical-align:top;padding-right:12px;">
                                  <span style="font-size:18px;">📊</span>
                                </td>
                                <td style="vertical-align:top;padding-bottom:12px;">
                                  <p style="margin:0;color:#0B1C30;font-size:14px;font-weight:600;">Real-time Dashboard</p>
                                  <p style="margin:2px 0 0;color:#64748B;font-size:13px;line-height:1.5;">Track sales, inventory, and performance at a glance</p>
                                </td>
                              </tr>
                              <tr>
                                <td width="36" style="vertical-align:top;padding-right:12px;">
                                  <span style="font-size:18px;">💊</span>
                                </td>
                                <td style="vertical-align:top;padding-bottom:12px;">
                                  <p style="margin:0;color:#0B1C30;font-size:14px;font-weight:600;">Inventory Management</p>
                                  <p style="margin:2px 0 0;color:#64748B;font-size:13px;line-height:1.5;">Stock tracking, low alerts, and batch expiry monitoring</p>
                                </td>
                              </tr>
                              <tr>
                                <td width="36" style="vertical-align:top;padding-right:12px;">
                                  <span style="font-size:18px;">🛒</span>
                                </td>
                                <td style="vertical-align:top;">
                                  <p style="margin:0;color:#0B1C30;font-size:14px;font-weight:600;">Point of Sale</p>
                                  <p style="margin:2px 0 0;color:#64748B;font-size:13px;line-height:1.5;">Process sales and manage transactions seamlessly</p>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ EXPIRY NOTICE ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:0 40px 8px;" class="pad-mobile">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background:#FFFBEB;border-radius:12px;border:1px solid #FDE68A;">
                  <tr>
                    <td style="padding:16px 20px;">
                      <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                          <td width="28" style="vertical-align:top;padding-right:10px;">
                            <span style="font-size:16px;">⏰</span>
                          </td>
                          <td style="vertical-align:top;">
                            <p style="margin:0;color:#92400E;font-size:13px;line-height:1.5;">
                              <strong>This invitation expires in 7 days.</strong> If you didn't expect this invitation, you can safely ignore this email.
                            </p>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ FOOTER ═══════════ -->
            <tr>
              <td style="background:#ffffff;padding:24px 40px 0;border-top:1px solid #F1F5F9;" class="pad-mobile">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>
                    <td align="center">
                      <p style="margin:0 0 8px;color:#94A3B8;font-size:12px;line-height:1.5;">
                        Sent with care by the <strong style="color:#7C3AED;">Pulse</strong> team
                      </p>
                      <p style="margin:0;color:#CBD5E1;font-size:11px;">
                        Pulse &mdash; Modern Pharmacy Intelligence
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- ═══════════ BOTTOM BAR ═══════════ -->
            <tr>
              <td style="padding:0;">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background:linear-gradient(135deg,#7C3AED 0%,#9900FF 40%,#6D28D9 100%);border-radius:0 0 20px 20px;">
                  <tr>
                    <td style="padding:16px 40px;text-align:center;" class="pad-mobile">
                      <p style="margin:0;color:rgba(255,255,255,0.7);font-size:11px;letter-spacing:0.5px;">
                        &copy; 2025 Duniya Healthcare &bull; Powered by Pulse
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

          </table>
          <!--[if mso]>
          </td></tr></table>
          <![endif]-->
        </td>
      </tr>
    </table>
  </div>
</body>
</html>`;

    try {
      const response = await axios.post(
        `${RESEND_API_URL}/emails`,
        {
          from: fromAddress,
          to: [email.toLowerCase().trim()],
          subject: `💎 ${name}, you're invited to join ${pharmacyName || 'Pulse'} as ${roleLabel}`,
          html: emailHtml,
          text: `You're invited to join ${pharmacyName || 'Pulse'} as ${roleLabel} on Pulse.\n\nHi ${name},\n\nYou've been invited to join ${pharmacyName || 'a pharmacy'} as a ${roleLabel} on Pulse — the modern pharmacy management platform.\n\nAccept your invitation: ${invitationUrl}\n\nThis invitation expires in 7 days.`,
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
// server-side so only Pulse Owners can create backdated stock records
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
      throw new functions.https.HttpsError("permission-denied", "Only Pulse Owners can import reconciliation data.");
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

// Pulse network Owners can manage only other Pulse accounts. The
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
      throw new functions.https.HttpsError("permission-denied", "Only Pulse Owners can manage Pulse users.");
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
      throw new functions.https.HttpsError("permission-denied", "Only Pulse Owners can invite Pulse users.");
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
        html: `<!doctype html><html><body style="margin:0;background:#f7f4ff;font-family:Arial,sans-serif;color:#15182b"><div style="max-width:560px;margin:32px auto;background:#fff;border-radius:20px;overflow:hidden;border:1px solid #e8ddff"><div style="padding:32px;background:linear-gradient(135deg,#9900ff,#2563eb);color:#fff"><div style="font-size:28px;font-weight:800">Welcome to Pulse</div><div style="margin-top:8px;font-size:16px;opacity:.9">Your network workspace is ready.</div></div><div style="padding:32px"><p style="font-size:16px;line-height:1.6">Hi ${safeName},</p><p style="font-size:16px;line-height:1.6">You've been invited to Pulse as a <strong>${role === "admin" ? "Owner" : "Staff member"}</strong>. Set a secure password to activate your account.</p><p style="margin:28px 0"><a href="${setupLink}" style="display:inline-block;padding:14px 22px;background:#9900ff;border-radius:10px;color:#fff;font-weight:700;text-decoration:none">Set up your account</a></p><p style="font-size:13px;line-height:1.5;color:#667085">If you were not expecting this invitation, you can safely ignore this email.</p></div></div></body></html>`,
        text: `Hi ${displayName},\n\nYou've been invited to Pulse as ${role === "admin" ? "an Owner" : "a Staff member"}. Set up your account: ${setupLink}`,
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
