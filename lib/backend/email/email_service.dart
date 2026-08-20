import 'package:cloud_functions/cloud_functions.dart';

/// Pulse Email Service
/// ══════════════════════════════════════════════════════════════
/// Sends emails through Firebase Cloud Functions → Resend API.
/// The Resend API key is stored server-side in Firebase environment config
/// and is NEVER exposed to the client.
///
/// Usage:
///   await EmailService.sendEmail(
///     to: 'user@example.com',
///     subject: 'Welcome to Pulse',
///     html: '<h1>Welcome!</h1><p>...</p>',
///   );
class EmailService {
  EmailService._();

  static FirebaseFunctions get _functions => FirebaseFunctions.instance;

  /// Send a single email.
  ///
  /// [to] — recipient email address(es)
  /// [subject] — email subject line
  /// [html] — HTML body content (use [text] for plain text fallback)
  /// [text] — plain text body (used if [html] is null)
  /// [from] — sender address (defaults to "Pulse <noreply@thestackone.com>")
  /// [replyTo] — reply-to address(es)
  static Future<EmailResult> sendEmail({
    required String to,
    required String subject,
    String? html,
    String? text,
    String? from,
    String? replyTo,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendEmail');
      final result = await callable.call(<String, dynamic>{
        'to': to,
        'subject': subject,
        if (html != null) 'html': html,
        if (text != null) 'text': text,
        if (from != null) 'from': from,
        if (replyTo != null) 'replyTo': replyTo,
      });

      return EmailResult(
        success: result.data['success'] as bool? ?? false,
        messageId: result.data['messageId'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      return EmailResult(
        success: false,
        error: e.message ?? e.code,
      );
    } catch (e) {
      return EmailResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Send a batch of emails (up to 50 per call).
  static Future<BatchEmailResult> sendBatchEmails({
    required List<EmailPayload> emails,
  }) async {
    if (emails.isEmpty) {
      return BatchEmailResult(success: true, results: []);
    }

    if (emails.length > 50) {
      return BatchEmailResult(
        success: false,
        error: 'Maximum 50 emails per batch',
        results: [],
      );
    }

    try {
      final callable = _functions.httpsCallable('sendBatchEmails');
      final result = await callable.call(<String, dynamic>{
        'emails': emails.map((e) => e.toMap()).toList(),
      });

      final results = (result.data['results'] as List<dynamic>?)
              ?.map((r) => EmailResult(
                    success: r['status'] == 'sent',
                    messageId: r['messageId'] as String?,
                    error: r['error'] as String?,
                    to: r['to'] as String?,
                  ))
              .toList() ??
          [];

      return BatchEmailResult(
        success: result.data['success'] as bool? ?? false,
        results: results,
      );
    } on FirebaseFunctionsException catch (e) {
      return BatchEmailResult(
        success: false,
        error: e.message ?? e.code,
        results: [],
      );
    } catch (e) {
      return BatchEmailResult(
        success: false,
        error: e.toString(),
        results: [],
      );
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Convenience methods for common email types
  // ──────────────────────────────────────────────────────────────

  /// Send a welcome email to a new user.
  static Future<EmailResult> sendWelcomeEmail({
    required String to,
    required String displayName,
  }) async {
    return sendEmail(
      to: to,
      subject: 'Welcome to Pulse',
      html: _welcomeHtml(displayName),
      text: 'Welcome to Pulse, $displayName!',
    );
  }

  /// Send a password reset email.
  static Future<EmailResult> sendPasswordResetEmail({
    required String to,
    required String resetLink,
  }) async {
    return sendEmail(
      to: to,
      subject: 'Reset your Pulse password',
      html: _passwordResetHtml(resetLink),
      text: 'Click the link to reset your password: $resetLink',
    );
  }

  /// Send a low stock alert email.
  static Future<EmailResult> sendLowStockAlert({
    required String to,
    required String pharmacyName,
    required List<LowStockItem> items,
  }) async {
    final itemsHtml = items
        .map((item) =>
            '<tr><td style="padding:8px;border-bottom:1px solid #eee">${item.name}</td>'
            '<td style="padding:8px;border-bottom:1px solid #eee;text-align:center">${item.currentStock}</td>'
            '<td style="padding:8px;border-bottom:1px solid #eee;text-align:center;color:#dc2626">${item.minStock}</td></tr>')
        .join();

    return sendEmail(
      to: to,
      subject: '⚠️ Low Stock Alert — $pharmacyName',
      html: _lowStockHtml(pharmacyName, itemsHtml),
      text: 'Low stock alert for $pharmacyName: ${items.map((i) => '${i.name} (${i.currentStock}/${i.minStock})').join(', ')}',
    );
  }

  /// Send an expiry warning email.
  static Future<EmailResult> sendExpiryWarning({
    required String to,
    required String pharmacyName,
    required List<ExpiryItem> items,
  }) async {
    final itemsHtml = items
        .map((item) =>
            '<tr><td style="padding:8px;border-bottom:1px solid #eee">${item.name}</td>'
            '<td style="padding:8px;border-bottom:1px solid #eee;text-align:center">${item.batchNumber}</td>'
            '<td style="padding:8px;border-bottom:1px solid #eee;text-align:center;color:#dc2626">${item.expiryDate}</td></tr>')
        .join();

    return sendEmail(
      to: to,
      subject: '⏰ Expiry Warning — $pharmacyName',
      html: _expiryWarningHtml(pharmacyName, itemsHtml),
      text: 'Expiry warning for $pharmacyName: ${items.map((i) => '${i.name} (batch ${i.batchNumber}, expires ${i.expiryDate})').join(', ')}',
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Email HTML templates
  // ──────────────────────────────────────────────────────────────

  static String _welcomeHtml(String displayName) => '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:#7c3aed;padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">Welcome to Pulse</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:16px;color:#333">Hi $displayName,</p>
    <p style="font-size:15px;color:#555;line-height:1.6">Welcome to Pulse — your pharmacy and inventory management platform. You're all set to get started.</p>
    <p style="font-size:15px;color:#555;line-height:1.6">If you have any questions, our support team is here to help.</p>
    <p style="font-size:15px;color:#555;margin-top:24px">Best regards,<br>The Pulse Team</p>
  </div>
  <div style="padding:16px 32px;background:#f9fafb;border-top:1px solid #eee;text-align:center">
    <p style="font-size:12px;color:#999;margin:0">Pulse — Pharmacy Management</p>
  </div>
</div>
</body>
</html>''';

  static String _passwordResetHtml(String resetLink) => '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:#7c3aed;padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">Password Reset</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:15px;color:#555;line-height:1.6">You requested a password reset for your Pulse account. Click the button below to set a new password:</p>
    <div style="text-align:center;margin:24px 0">
      <a href="$resetLink" style="display:inline-block;padding:14px 32px;background:#7c3aed;color:#fff;text-decoration:none;border-radius:8px;font-weight:600;font-size:15px">Reset Password</a>
    </div>
    <p style="font-size:13px;color:#999;line-height:1.5">This link will expire in 1 hour. If you didn't request this, you can safely ignore this email.</p>
  </div>
  <div style="padding:16px 32px;background:#f9fafb;border-top:1px solid #eee;text-align:center">
    <p style="font-size:12px;color:#999;margin:0">Pulse — Pharmacy Management</p>
  </div>
</div>
</body>
</html>''';

  static String _lowStockHtml(String pharmacyName, String itemsHtml) => '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:#dc2626;padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">⚠️ Low Stock Alert</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:15px;color:#555;line-height:1.6">The following items at <strong>$pharmacyName</strong> are running low:</p>
    <table style="width:100%;border-collapse:collapse;margin:16px 0;font-size:14px">
      <thead><tr style="background:#f9fafb"><th style="padding:8px;text-align:left">Item</th><th style="padding:8px;text-align:center">In Stock</th><th style="padding:8px;text-align:center">Min Required</th></tr></thead>
      <tbody>$itemsHtml</tbody>
    </table>
    <p style="font-size:15px;color:#555;line-height:1.6;margin-top:20px">Please review and replenish as needed.</p>
  </div>
  <div style="padding:16px 32px;background:#f9fafb;border-top:1px solid #eee;text-align:center">
    <p style="font-size:12px;color:#999;margin:0">Pulse — Pharmacy Management</p>
  </div>
</div>
</body>
</html>''';

  static String _expiryWarningHtml(String pharmacyName, String itemsHtml) => '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:#f59e0b;padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">⏰ Expiry Warning</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:15px;color:#555;line-height:1.6">The following items at <strong>$pharmacyName</strong> are expiring soon:</p>
    <table style="width:100%;border-collapse:collapse;margin:16px 0;font-size:14px">
      <thead><tr style="background:#f9fafb"><th style="padding:8px;text-align:left">Item</th><th style="padding:8px;text-align:center">Batch</th><th style="padding:8px;text-align:center">Expiry Date</th></tr></thead>
      <tbody>$itemsHtml</tbody>
    </table>
    <p style="font-size:15px;color:#555;line-height:1.6;margin-top:20px">Please take action to prevent losses from expired stock.</p>
  </div>
  <div style="padding:16px 32px;background:#f9fafb;border-top:1px solid #eee;text-align:center">
    <p style="font-size:12px;color:#999;margin:0">Pulse — Pharmacy Management</p>
  </div>
</div>
</body>
</html>''';
}

// ──────────────────────────────────────────────────────────────
// Models
// ──────────────────────────────────────────────────────────────

class EmailResult {
  final bool success;
  final String? messageId;
  final String? error;
  final String? to;

  const EmailResult({
    required this.success,
    this.messageId,
    this.error,
    this.to,
  });
}

class BatchEmailResult {
  final bool success;
  final List<EmailResult> results;
  final String? error;

  const BatchEmailResult({
    required this.success,
    required this.results,
    this.error,
  });

  int get sentCount => results.where((r) => r.success).length;
  int get failedCount => results.where((r) => !r.success).length;
}

class EmailPayload {
  final String to;
  final String subject;
  final String? html;
  final String? text;
  final String? from;

  const EmailPayload({
    required this.to,
    required this.subject,
    this.html,
    this.text,
    this.from,
  });

  Map<String, dynamic> toMap() => {
        'to': to,
        'subject': subject,
        if (html != null) 'html': html,
        if (text != null) 'text': text,
        if (from != null) 'from': from,
      };
}

class LowStockItem {
  final String name;
  final int currentStock;
  final int minStock;

  const LowStockItem({
    required this.name,
    required this.currentStock,
    required this.minStock,
  });
}

class ExpiryItem {
  final String name;
  final String batchNumber;
  final String expiryDate;

  const ExpiryItem({
    required this.name,
    required this.batchNumber,
    required this.expiryDate,
  });
}
