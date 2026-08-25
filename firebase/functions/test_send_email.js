/**
 * Pulse — Resend email service end-to-end test.
 *
 * Usage (from firebase/functions/):
 *   node test_send_email.js you@example.com
 *
 * Resolves the Resend API key from, in order:
 *   1. RESEND_API_KEY environment variable
 *   2. .runtimeconfig.json in this directory
 *      (create it with: firebase functions:config:get > .runtimeconfig.json)
 *   3. firebase-functions config (works only inside a deployed function)
 *
 * Resolves the sender from (same sources), `resend.from`, falling back
 * to the same default the cloud functions use.
 */

const fs = require("fs");
const path = require("path");
const axios = require("axios").default;

const RESEND_API_URL = "https://api.resend.com";
const DEFAULT_RESEND_FROM = "Pulse <noreply@thestackone.com>";

function readRuntimeConfig() {
  const p = path.join(__dirname, ".runtimeconfig.json");
  if (fs.existsSync(p)) {
    try {
      return JSON.parse(fs.readFileSync(p, "utf8"));
    } catch (_) {
      return {};
    }
  }
  return {};
}

function resolveConfig() {
  const cfg = readRuntimeConfig();
  const key =
    process.env.RESEND_API_KEY || cfg.resend?.key || "";
  const from =
    process.env.RESEND_FROM || cfg.resend?.from || DEFAULT_RESEND_FROM;
  return { key, from };
}

async function main() {
  const recipient = process.argv[2];
  if (!recipient || !recipient.includes("@")) {
    console.error("Usage: node test_send_email.js you@example.com");
    process.exit(1);
  }

  const { key, from } = resolveConfig();
  if (!key) {
    console.error(
      "No Resend API key found. Either:\n" +
        "  export RESEND_API_KEY=re_xxx\n" +
        "or create .runtimeconfig.json here via:\n" +
        "  firebase functions:config:get > .runtimeconfig.json"
    );
    process.exit(1);
  }

  console.log(`Sending test email to ${recipient}`);
  console.log(`From: ${from}`);
  console.log(`Key: ${key.substring(0, 8)}...`);

  const sentAt = new Date().toISOString();
  const html = `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:linear-gradient(135deg,#9900FF,#7C3AED);padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">✅ Pulse email service is live</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:16px;color:#333">This is an automated test from <strong>Pulse</strong>.</p>
    <ol style="font-size:15px;color:#555;line-height:1.8;padding-left:20px">
      <li>Resend API key configured ✅</li>
      <li>Sending domain verified in Resend ✅</li>
      <li>API accepts the payload ✅</li>
    </ol>
    <p style="font-size:14px;color:#999;margin-top:24px">Sent at ${sentAt}</p>
  </div>
  <div style="padding:16px 32px;background:#f9fafb;border-top:1px solid #eee;text-align:center">
    <p style="font-size:12px;color:#999;margin:0">Pulse — Pharmacy Intelligence</p>
  </div>
</div>
</body>
</html>`;

  try {
    const response = await axios.post(
      `${RESEND_API_URL}/emails`,
      {
        from,
        to: [recipient],
        subject: "✅ Pulse email service test",
        html,
        text: "Pulse email service is live and working!",
      },
      {
        headers: {
          Authorization: `Bearer ${key}`,
          "Content-Type": "application/json",
        },
      }
    );
    console.log("\n✅ Email sent successfully!");
    console.log("Message ID:", response.data?.id);
    console.log("\nIf the email does not arrive within a few minutes:");
    console.log("  1. Check the recipient's spam folder");
    console.log("  2. Verify the sending domain in the Resend dashboard");
    console.log("     (Domains → thestackone.com should be Verified)");
    process.exit(0);
  } catch (error) {
    const message =
      error.response?.data?.message || error.message || "Unknown error";
    console.error("\n❌ Resend API error:", message);
    if (/domain/i.test(message)) {
      console.error(
        "The sending domain is not verified in Resend. Verify it at" +
          " dashboard.resend.com → Domains, or override the sender with" +
          " onboarding@resend.dev for testing."
      );
    }
    process.exit(1);
  }
}

main();
