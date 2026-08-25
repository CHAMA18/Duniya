# Resend Email Configuration

Pulse sends all transactional email through **[Resend](https://resend.com)**
via Firebase Cloud Functions. The API key lives server-side in Firebase
environment config and is never shipped to the browser.

## Architecture

```
Flutter client (EmailService)
   └─► Firebase callable functions        firebase/functions/index.js
         ├─ sendEmail            single email
         ├─ sendBatchEmails      up to 50 per call
         ├─ sendStaffInvitation  staff invitations (writes StaffInvitations)
         └─ createPulseUser      network user invitations
              └─► Resend API     https://api.resend.com (Bearer key)
```

Every send (success or failure) is written to the `EmailLogs` Firestore
collection for auditing.

## Configuration

The functions read three config keys:

| Key | Required | Default | Purpose |
| --- | --- | --- | --- |
| `resend.key` | **yes** | — | Resend API key (`re_...`) from dashboard.resend.com → API Keys |
| `resend.from` | no | `Pulse <noreply@thestackone.com>` | Sender address override — must be on a **verified domain** in Resend |
| `app.url` | no | `https://pulse.duniyahealthcare.com/app.html` | Portal URL used in staff-invitation password-setup links |

### Setting the config

Use the helper script (wraps the firebase CLI):

```bash
./setup-resend.sh set-key  re_xxxxxxxxxxxx
./setup-resend.sh set-from 'Pulse <noreply@yourdomain.com>'   # optional
./setup-resend.sh set-url  'https://pulse.duniyahealthcare.com'  # optional
./setup-resend.sh deploy
```

Or call the CLI directly:

```bash
firebase functions:config:set resend.key="re_xxxxxxxxxxxx"
firebase deploy --only functions
```

### Verifying the domain in Resend

The default sender `noreply@thestackone.com` requires **thestackone.com**
to be verified in the Resend dashboard:

1. Sign in at dashboard.resend.com → **Domains**
2. `thestackone.com` should show **Verified**
3. If not, add the displayed DNS records (SPF/DKIM) at the domain's DNS
   provider and wait for verification

To move to a different domain later: verify it in Resend, then
`./setup-resend.sh set-from 'Pulse <noreply@newdomain.com>'` and redeploy.

## Testing

Send a test email from your machine:

```bash
cd firebase/functions && npm install
node test_send_email.js you@example.com
```

The script resolves the key from `RESEND_API_KEY` or a local
`.runtimeconfig.json` (`firebase functions:config:get > .runtimeconfig.json`).

In-app: **Settings → Email Test** (staff/admin) sends each template type
through the real callable function.

## What Pulse sends

| Email | Trigger | Recipient |
| --- | --- | --- |
| Email verification | New registration | The new user |
| Password reset | "Forgot password" | The account owner |
| Staff invitation | User Management invite | The invitee |
| Pharmacy approved / rejected | Network onboarding decision | The applicant |
| Low stock alert | Products under threshold | Configured recipients |
| Expiry warning | Batches entering warning window | Configured recipients |

All email links open the live app (`pulse.duniyahealthcare.com`):
verification links confirm in-app, reset links open the Set-a-New-Password
screen, invitation links let the invitee set a password, and approval
emails link straight to the app.

## Troubleshooting

- **"Email service not configured"** — `resend.key` is not set; run
  `./setup-resend.sh show` and set it.
- **Resend 403 "domain not verified"** — the `from` address is on an
  unverified domain; verify it in Resend or override `resend.from`
  (for quick tests Resend allows `onboarding@resend.dev`).
- **Emails in spam** — check SPF/DKIM records for the sending domain in
  the Resend dashboard.
- **"I never got the email"** — check the `EmailLogs` Firestore
  collection for the send status, then the recipient's spam folder.
- Firebase legacy `functions.config()` values are viewable with
  `firebase functions:config:get` and migrate to param-based secrets
  (`firebase functions:secrets`) whenever the functions runtime is
  upgraded to Firebase Functions v2.
