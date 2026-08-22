import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '/backend/email/email_service.dart';

/// Pulse Email Triggers
/// ══════════════════════════════════════════════════════════════
/// Client-side helpers that detect conditions and trigger emails
/// via the Cloud Functions. These can be called from any widget
/// or service in the app.
class EmailTriggers {
  EmailTriggers._();

  // ──────────────────────────────────────────────────────────────
  // Low Stock Alert
  // ──────────────────────────────────────────────────────────────

  /// Check if a stock item has fallen below its reorder level
  /// and send an alert email if so.
  ///
  /// Call this after dispensing, transferring, or adjusting stock.
  static Future<void> checkAndSendLowStockAlert({
    required String pharmacyId,
    required String productId,
    required int currentStock,
    required int reorderLevel,
  }) async {
    if (currentStock > reorderLevel) return; // Not low yet

    try {
      // Create the LowStockAlert document — the Cloud Function trigger
      // will pick it up and send the email.
      await FirebaseFirestore.instance.collection('LowStockAlert').add({
        'PharmacyId': FirebaseFirestore.instance.doc('Pharmacy/$pharmacyId'),
        'ProductId': FirebaseFirestore.instance.doc('Product/$productId'),
        'CurrentStock': currentStock,
        'ReorderLevel': reorderLevel,
        'SuggestedQuantity': reorderLevel * 2, // Default: double the reorder level
        'Status': 'active',
        'CreatedAt': FieldValue.serverTimestamp(),
        'UpdatedAt': FieldValue.serverTimestamp(),
      });

      print('[EmailTriggers] Low stock alert created for product $productId');
    } catch (e) {
      print('[EmailTriggers] Failed to create low stock alert: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Expiry Warning (manual trigger)
  // ──────────────────────────────────────────────────────────────

  /// Manually trigger an expiry warning email for a specific pharmacy.
  /// The scheduled Cloud Function handles daily checks, but this
  /// can be called on-demand (e.g., when user opens the expiry tracking page).
  static Future<EmailResult> sendExpiryWarningForPharmacy({
    required String pharmacyId,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('sendExpiryWarning');
      final result = await callable.call(<String, dynamic>{
        'pharmacyId': pharmacyId,
      });

      return EmailResult(
        success: result.data['success'] as bool? ?? false,
        messageId: result.data['messageId'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      return EmailResult(success: false, error: e.message ?? e.code);
    } catch (e) {
      return EmailResult(success: false, error: e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Welcome Email (manual trigger)
  // ──────────────────────────────────────────────────────────────

  /// Send a welcome email to a specific user.
  /// The Cloud Function `onUserCreated` handles automatic sends,
  /// but this can be called for re-sends or manual welcomes.
  static Future<EmailResult> sendWelcomeEmailToUser({
    required String email,
    required String displayName,
  }) async {
    return EmailService.sendWelcomeEmail(
      to: email,
      displayName: displayName,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Purchase Order Received
  // ──────────────────────────────────────────────────────────────

  /// Notify the pharmacy owner that a purchase order has been received.
  static Future<EmailResult> sendPurchaseOrderReceived({
    required String pharmacyId,
    required String orderNumber,
    required int itemCount,
  }) async {
    final info = await _resolvePharmacyInfo(pharmacyId);
    if (info['ownerEmail'] == null) {
      return EmailResult(success: false, error: 'No owner email found');
    }

    return EmailService.sendEmail(
      to: info['ownerEmail']!,
      subject: '📦 Purchase Order Received — ${info['pharmacyName']}',
      html: _purchaseOrderHtml(info['pharmacyName']!, orderNumber, itemCount),
      text: 'Purchase order $orderNumber received at ${info['pharmacyName']}: $itemCount items.',
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Password Reset
  // ──────────────────────────────────────────────────────────────

  /// Send a password reset email via Resend directly.
  /// Note: Firebase Auth has its own password reset email, but this
  /// provides a branded alternative.
  static Future<EmailResult> sendPasswordReset({
    required String email,
    required String resetLink,
  }) async {
    return EmailService.sendPasswordResetEmail(
      to: email,
      resetLink: resetLink,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────

  static Future<Map<String, String?>> _resolvePharmacyInfo(String pharmacyId) async {
    try {
      final doc = await FirebaseFirestore.instance.doc('Pharmacy/$pharmacyId').get();
      if (!doc.exists) return {'pharmacyName': null, 'ownerEmail': null};

      final data = doc.data()!;
      final pharmacyName = data['Name'] ?? data['name'] ?? 'Pharmacy';
      final ownerRef = data['OwnerRef'] ?? data['ownerRef'];

      if (ownerRef == null) return {'pharmacyName': pharmacyName, 'ownerEmail': null};

      final ownerDoc = await (ownerRef as DocumentReference).get();
      final ownerData = ownerDoc.data() as Map<String, dynamic>?;
      final ownerEmail = ownerData?['email'] as String?;

      return {'pharmacyName': pharmacyName, 'ownerEmail': ownerEmail};
    } catch (e) {
      return {'pharmacyName': null, 'ownerEmail': null};
    }
  }

  static String _purchaseOrderHtml(String pharmacyName, String orderNumber, int itemCount) => '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:0;padding:0;background:#f5f5f5">
<div style="max-width:600px;margin:40px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">
  <div style="background:#059669;padding:32px;text-align:center">
    <h1 style="color:#fff;margin:0;font-size:24px">📦 Order Received</h1>
  </div>
  <div style="padding:32px">
    <p style="font-size:15px;color:#555;line-height:1.6">A purchase order has been received at <strong>$pharmacyName</strong>:</p>
    <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;padding:16px;margin:16px 0">
      <p style="margin:0;font-size:14px;color:#333"><strong>Order:</strong> $orderNumber</p>
      <p style="margin:8px 0 0;font-size:14px;color:#333"><strong>Items:</strong> $itemCount</p>
    </div>
    <p style="font-size:15px;color:#555;line-height:1.6">Please review and confirm the delivery in your Pulse dashboard.</p>
  </div>
  <div style="padding:16px 32px;background:#f9fafb;border-top:1px solid #eee;text-align:center">
    <p style="font-size:12px;color:#999;margin:0">Pulse — Pharmacy Management</p>
  </div>
</div>
</body>
</html>''';
}
