const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getFunctions, httpsCallable } = require("firebase-admin/functions");

// Initialize with default credentials (uses logged-in user)
initializeApp({
  projectId: "pharmacy-system-2fb27",
});

async function main() {
  const functions = getFunctions();
  const sendEmail = httpsCallable(functions, "sendEmail");

  try {
    console.log("Sending test email to developer@thestackone.com...");
    const result = await sendEmail({
      to: "developer@thestackone.com",
      subject: "✅ Duniya Email Service Test",
      html: `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:#7c3aed;padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">✅ Email Service is Live!</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:16px;color:#333">This is an automated test from <strong>Duniya</strong>.</p>
    <p style="font-size:15px;color:#555;line-height:1.6">The Resend email integration is working end-to-end. You're receiving this because the Cloud Function successfully:</p>
    <ol style="font-size:15px;color:#555;line-height:1.8;padding-left:20px">
      <li>Received the request via Firebase Callable Function</li>
      <li>Read the Resend API key from Firebase environment config</li>
      <li>Sent the email through Resend's API</li>
      <li>Logged the result to Firestore EmailLogs collection</li>
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
    });

    console.log("✅ Success!");
    console.log("Result:", JSON.stringify(result.data, null, 2));
  } catch (error) {
    console.error("❌ Error:", error.message);
    if (error.details) {
      console.error("Details:", error.details);
    }
  }
}

main();
