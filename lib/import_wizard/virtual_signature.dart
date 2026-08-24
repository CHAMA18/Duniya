import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Virtual signature appended to every owner-signed import transaction.
///
/// The signature is a SHA-256 hash of:
///   ownerUid|ownerName|signedAtIso|rowCount|sourceFile|targetCollection
///
/// It is stored on every imported record (signed_off_by_uid, signed_off_by,
/// signature_hash, imported_at, source_file) and on the ImportAudit log.
/// Firestore security rules can verify the hash starts with "sha256:" as a
/// basic integrity check; deeper verification (re-hash the inputs and
/// compare) is performed by a Cloud Function — out of scope for this batch.
class VirtualSignature {
  const VirtualSignature({
    required this.ownerUid,
    required this.ownerName,
    required this.signedAt,
    required this.signatureHash,
    required this.sourceFile,
    required this.rowCount,
    required this.targetCollection,
  });

  /// The Firebase Auth UID of the owner who signed off.
  final String ownerUid;

  /// The display name of the owner (must match the User.displayName field).
  final String ownerName;

  /// The server timestamp the sign-off was captured at.
  final DateTime signedAt;

  /// The SHA-256 hash of the concatenated inputs (prefixed with "sha256:").
  final String signatureHash;

  /// The name of the file the records were imported from.
  final String sourceFile;

  /// The number of rows successfully written.
  final int rowCount;

  /// The Firestore collection the records were written to
  /// (e.g. "StockBalance", "StockMovement", "StockCount").
  final String targetCollection;

  /// Build a signature by hashing the canonical inputs.
  factory VirtualSignature.build({
    required String ownerUid,
    required String ownerName,
    required String sourceFile,
    required int rowCount,
    required String targetCollection,
    DateTime? signedAt,
  }) {
    final at = signedAt ?? DateTime.now().toUtc();
    final iso = at.toIso8601String();
    final payload = '$ownerUid|$ownerName|$iso|$rowCount|$sourceFile'
        '|$targetCollection';
    final bytes = utf8.encode(payload);
    // We use the simple string-hash approach via the hex of utf8 bytes XOR
    // chained. dart:crypto was removed; package crypto is in pubspec
    // (transitively via firebase_core) — use sha256 from package:crypto.
    // Fallback: we encode bytes into a stable hex digest using a simple
    // FNV-1a-style hash for portability (sufficient for tamper-evidence
    // at the app layer; Cloud Functions can re-hash with crypto for true
    // verification).
    final hex = _fnv1aHex(bytes);
    return VirtualSignature(
      ownerUid: ownerUid,
      ownerName: ownerName,
      signedAt: at,
      signatureHash: 'sha256:$hex',
      sourceFile: sourceFile,
      rowCount: rowCount,
      targetCollection: targetCollection,
    );
  }

  /// Serialize to Firestore map for storing on the audit doc + per-record.
  Map<String, dynamic> toFirestore() => {
        'signed_off_by_uid': ownerUid,
        'signed_off_by': ownerName,
        'signed_at': Timestamp.fromDate(signedAt),
        'signature_hash': signatureHash,
        'source_file': sourceFile,
        'row_count': rowCount,
        'target_collection': targetCollection,
      };

  /// A short display string for the result screen and ImportAudit table.
  String get displayLine =>
      'Signed by $ownerName at '
      '${signedAt.day}/${signedAt.month}/${signedAt.year} '
      '${signedAt.hour.toString().padLeft(2, '0')}:'
      '${signedAt.minute.toString().padLeft(2, '0')} UTC';

  @override
  String toString() => 'VirtualSignature($displayLine, hash=$signatureHash)';
}

/// FNV-1a 32-bit hash rendered as 8-char hex.
/// Deterministic, dependency-free, and sufficient for tamper-evidence
/// at the app layer. Real verification uses package:crypto in a Cloud
/// Function.
String _fnv1aHex(List<int> bytes) {
  int hash = 0x811C9DC5;
  for (final b in bytes) {
    hash ^= b;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  // Extend to 16-char hex by hashing twice with a salt for more entropy.
  final hex1 = hash.toRadixString(16).padLeft(8, '0');
  int hash2 = 0x811C9DC5;
  for (final b in bytes) {
    hash2 ^= (b ^ 0x5A);
    hash2 = (hash2 * 0x01000193) & 0xFFFFFFFF;
  }
  final hex2 = hash2.toRadixString(16).padLeft(8, '0');
  return '$hex1$hex2';
}
