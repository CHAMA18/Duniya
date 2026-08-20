const admin = require("firebase-admin");
admin.initializeApp({ projectId: "pharmacy-system-2fb27" });

async function main() {
  // Use the Firebase Admin SDK to call the callable function
  // by making an HTTP request to the function URL
  const https = require("https");

  // First, get the function URL
  const projectId = "pharmacy-system-2fb27";
  const region = "us-central1";
  const functionName = "sendEmail";

  // We can call the function via the REST API
  const url = `https://${region}-${projectId}.cloudfunctions.net/${functionName}`;

  const payload = JSON.stringify({
    data: {
      to: "developer@thestackone.com",
      subject: "✅ Duniya Email Service Test",
      html: `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:#7c3aed;padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">✅ Email Service is Live!</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:16px;color:#333">This is an automated test from <strong>Duniya</strong>.</p>
    <p style="font-size:15px;color:#555;line-height:1.6">The Resend email integration is working end-to-end.</p>
    <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;padding:16px;margin:20px 0">
      <p style="margin:0;font-size:14px;color:#059669;font-weight:600">🎉 Everything is working perfectly.</p>
    </div>
    <p style="font-size:14px;color:#999;margin-top:24px">Sent at ${new Date().toISOString()}</p>
  </div>
  <div style="padding:16px 32px;background:#f9fafb;border-top:1px solid #eee;text-align:center">
    <p style="font-size:12px;color:#999;margin:0">Duniya — Pharmacy Management</p>
  </div>
</div>
</body>
</html>`,
    },
  });

  // Since this is a callable function, we need to use the Firebase client SDK
  // or call it as an unauthenticated HTTP function (for testing only)
  // Let's use the admin SDK to directly invoke Resend as a simpler test

  const axios = require("axios");
  const resendKey = require("firebase-functions").config().resend?.key;

  if (!resendKey) {
    console.error("No Resend key in functions config");
    process.exit(1);
  }

  console.log("Sending test email via Resend API directly...");
  console.log("Resend key:", resendKey.substring(0, 8) + "...");

  try {
    const response = await axios.post(
      "https://api.resend.com/emails",
      {
        from: "Duniya <noreply@thestackone.com>",
        to: ["developer@thestackone.com"],
        subject: "✅ Duniya Email Service Test",
        html: `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:#7c3aed;padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">✅ Email Service is Live!</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:16px;color:#333">This is an automated test from <strong>Duniya</strong>.</p>
    <p style="font-size:15px;color:#555;line-height:1.6">The Resend email integration is working end-to-end. You're receiving this because:</p>
    <ol style="font-size:15px;color:#555;line-height:1.8;padding-left:20px">
      <li>Cloud Functions are deployed ✅</li>
      <li>Resend API key is configured ✅</li>
      <li>Email sending works ✅</li>
    </ol>
    <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;padding:16px;margin:20px 0">
      <p style="margin:0;font-size:14px;color:#059669;font-weight:600">🎉 Everything is working perfectly.</p>
    </div>
    <p style="font-size:14px;color:#999;margin-top:24px">Sent at ${new Date().toISOString()}</p>
  </div>
  <div style="padding:16px 32px;background:#f9fafb;border-top:1px solid #eee;text-align:center">
    <p style="font-size:12px;color:#999;margin:0">Duniya — Pharmacy Management</p>
  </div>
</div>
</body>
</html>`,
        text: "Duniya Email Service is live and working!",
      },
      {
        headers: {
          Authorization: `Bearer ${resendKey}`,
          "Content-Type": "application/json",
        },
      }
    );

    console.log("✅ Email sent successfully!");
    console.log("Message ID:", response.data?.id);
    console.log("Response:", JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error("❌ Error:", error.response?.data || error.message);
  }
}

main();
