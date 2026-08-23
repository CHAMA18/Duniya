import 'package:flutter/foundation.dart' show kIsWeb;

/// Shared helpers for Firebase email-action URLs.
///
/// Emails previously routed through the legacy `pharmaaid.page.link`
/// Firebase Dynamic Links domain, which was never whitelisted in the
/// project's authorized domains (and Dynamic Links was shut down by
/// Google in August 2025) — clicking those links showed Firebase's
/// "domain is not authorized" error card.
///
/// All email actions are now sent with `handleCodeInApp: true` and URLs
/// on the deployed app origin, so email links open the app itself and
/// [EmailActionHandler] (lib/auth/email_action_handler.dart) completes
/// the action in-app.
///
/// NOTE: every origin used here must be listed under Firebase Console →
/// Authentication → Settings → Authorized domains.

/// The deployed app origin. Uses the current page origin on https
/// deployments (so any authorized domain works) and falls back to the
/// production custom domain everywhere else.
String emailActionBaseUrl() {
  if (kIsWeb) {
    final origin = Uri.base.origin;
    if (origin.startsWith('https://')) {
      return origin;
    }
  }
  return 'https://pulse.duniyahealthcare.com';
}

/// Destination for email verification links — the login route, where
/// EmailActionHandler picks up the verification oobCode.
String emailVerificationUrl() => '${emailActionBaseUrl()}/loginUni';

/// Destination for password reset links — the set-new-password route,
/// which consumes the oobCode directly.
String passwordResetUrl() => '${emailActionBaseUrl()}/setNewPassword';
