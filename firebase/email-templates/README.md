# Duniya Email Templates

This directory contains branded email templates for Firebase Authentication.

## Files

| File | Purpose |
|---|---|
| `email_verification.html` | Firebase Authentication → Email Verification template |
| `duniya-logo-200.png` | 200×200 PNG logo to host and reference in the email |

## How to deploy

### 1. Host the logo

Upload `duniya-logo-200.png` to a publicly accessible URL. The simplest option is Firebase Storage:

```bash
# Install Firebase CLI if you don't have it
npm install -g firebase-tools

# Login
firebase login

# Upload the logo (from the Duniya repo root)
firebase storage:upload firebase/email-templates/duniya-logo-200.png \
  --project pharmacy-system-2fb27
```

Then make the file publicly readable in the Firebase Console → Storage, and copy its URL — it will look like:

```
https://firebasestorage.googleapis.com/v0/b/pharmacy-system-2fb27.appspot.com/o/duniya-logo-200.png?alt=media
```

### 2. Update the template

Open `email_verification.html` and replace `LOGO_URL` (two occurrences — one in the `src`, one in the `onerror` fallback is fine to leave as the inline SVG) with your hosted logo URL.

### 3. Paste into Firebase Console

1. Go to **Firebase Console** → your project (`pharmacy-system-2fb27`)
2. **Authentication** → **Templates** → **Email Verification**
3. Click **Customize message**
4. Switch to the **HTML** source view (toggle the `< >` button)
5. Replace the entire template body with the contents of `email_verification.html`
6. Set the **From name** to `Duniya` (the From address stays as the default Firebase auth domain)
7. Set the **Subject** to: `Verify your email — Duniya`
8. Click **Save**

### 4. Test

Trigger a verification email by creating a new user account in the app, or in the Firebase Console → Authentication → Users → click "Send verification email" on any user.

The email should render with:
- A purple gradient header with the Duniya logo + wordmark
- A "Verify your email" heading
- A personalized greeting (`Hi %DISPLAY_NAME%,`)
- A prominent gradient "Verify Email Address" button
- A fallback link in case the button doesn't render
- A feature highlights row (Inventory / Analytics / Compliance)
- A branded footer with the Duniya wordmark

## Brand colors

| Color | Hex | Usage |
|---|---|---|
| Duniya Purple | `#9900FF` | Primary accent, buttons, logo |
| Violet 600 | `#7C3AED` | Gradient end color |
| Soft Lavender | `#F8F5FF` | Page background |
| Lavender border | `#E2D7FB` | Dividers, card borders |
| Ink | `#1A0533` | Headings |
| Gray 600 | `#4B5563` | Body text |
| Gray 500 | `#6B7280` | Secondary text |

## Notes

- The template uses **table-based layout** for maximum email client compatibility (Outlook, Gmail, Apple Mail, etc.)
- All styles are **inline** (no `<style>` tags) — required by most email clients
- The `onerror` attribute on the logo `<img>` provides a built-in SVG fallback so the email always shows the Duniya "D" mark, even if the hosted logo URL fails
- Firebase substitutes `%LINK%` with the actual verification link and `%DISPLAY_NAME%` with the user's display name
- The preheader text (hidden preview snippet shown in inbox) is "Welcome to Duniya — please confirm your email address…"
