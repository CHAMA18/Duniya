# Fixing the "domain (pharmaaid.page.link) is not authorized" Error

## What happened

When users clicked links in emails sent by the app (email verification,
password reset, staff invitations), they landed on a Firebase error page:

> **Error encountered**
> This domain (pharmaaid.page.link) is not authorized to run this
> operation. If you are the app developer, add it to the OAuth redirect
> domains list in the Firebase console -> Auth section -> Sign in method
> tab.

**Root cause:** the Firebase Auth email templates were configured (in the
old "PharmaAid" era of this project) with a **custom action URL** on the
`pharmaaid.page.link` domain — a Firebase Dynamic Links domain that

1. was never added to the project's **Authorized domains** list, and
2. is dead anyway — Google shut down Firebase Dynamic Links on
   **25 August 2025**.

Every email link pointed at that domain, so every click showed the error.

## What the code fix already does (deployed with this commit)

- **Email verification** and **password reset** emails are now sent with
  `ActionCodeSettings(handleCodeInApp: true)` pointing at the live app
  (`pulse.duniyahealthcare.com`, or whatever HTTPS origin the app is
  served from). Email links now open **the app itself**, completely
  bypassing the broken template domain.
- A new `EmailActionHandler` consumes the links in-app:
  - verification links → the email is verified automatically, with a
    green confirmation banner, then the user lands on the login page
  - reset links → a new **Set a New Password** screen
    (`/setNewPassword`) lets the user choose and apply a new password
    directly
- The staff-invitation cloud function's default portal URL was updated
  from the unreachable `thestackone.com` to the live app (requires a
  functions redeploy: `firebase deploy --only functions`).

## What YOU must do in the Firebase Console (one-time, ~2 minutes)

Firebase project: **pharmacy-system-2fb27**
(https://console.firebase.google.com/project/pharmacy-system-2fb27)

### 1. Add the deployed domains to Authorized domains

**Authentication → Settings → Authorized domains → Add domain**, add:

```
pulse.duniyahealthcare.com
duniya-web.onrender.com
```

(Add any other domain you serve the app from. Without this, Firebase
rejects the new email links with the same "unauthorized domain" error —
this list is the actual allow-list the error message refers to.)

### 2. Remove the dead custom action URL from email templates

**Authentication → Templates** — for each of:

- **Email address verification**
- **Password reset**
- **Email address change** (if present)

open the template → **Customize action URL** (pencil icon in the
"Action URL" / "Custom action URL" row) → **delete the
`https://pharmaaid.page.link/...` URL and save empty** so Firebase falls
back to its default handler. (The app now supplies its own action URL
per email, but templates must not force the dead domain for other flows
like staff invitations sent from cloud functions.)

### 3. Redeploy cloud functions (uses the new portal URL)

```bash
cd firebase/functions
firebase deploy --only functions
```

## Testing after the console changes

1. Register a new account → check the inbox → the verification email's
   button should now open `pulse.duniyahealthcare.com/...` (not
   `pharmaaid.page.link`) and show a green "Email verified" banner.
2. Use "Forgot password" on the login page → the email should open the
   **Set a New Password** screen → set a password → sign in.
