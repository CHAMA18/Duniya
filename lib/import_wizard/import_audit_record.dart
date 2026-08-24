import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore model for the `ImportAudit` collection. One document is
/// written per completed import transaction.
///
/// Fields:
///   - targetCollection: 'StockBalance' | 'StockMovement' | 'StockCount'
///   - sourceFile: 'august_balances.csv'
///   - rowCount: 47
///   - rowsOk / rowsWarned / rowsFailed: status breakdown
///   - signedOffByUid: Firebase Auth UID of the owner
///   - signedOffByName: display name captured at sign-off
///   - signedAt: UTC timestamp
///   - signatureHash: 'sha256:abcdef1234567890'
///   - status: 'completed' | 'failed' | 'rolled_back'
///   - notes: optional freeform text
class ImportAuditRecord {
  const ImportAuditRecord({
    required this.reference,
    required this.targetCollection,
    required this.sourceFile,
    required this.rowCount,
    required this.rowsOk,
    required this.rowsWarned,
    required this.rowsFailed,
    required this.signedOffByUid,
    required this.signedOffByName,
    required this.signedAt,
    required this.signatureHash,
    required this.status,
    this.notes,
  });

  final DocumentReference reference;
  final String targetCollection;
  final String sourceFile;
  final int rowCount;
  final int rowsOk;
  final int rowsWarned;
  final int rowsFailed;
  final String signedOffByUid;
  final String signedOffByName;
  final DateTime signedAt;
  final String signatureHash;
  final String status;
  final String? notes;

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('ImportAudit');

  static DocumentReference createDoc() =>
      FirebaseFirestore.instance.collection('ImportAudit').doc();

  Map<String, dynamic> toFirestore() => {
        'target_collection': targetCollection,
        'source_file': sourceFile,
        'row_count': rowCount,
        'rows_ok': rowsOk,
        'rows_warned': rowsWarned,
        'rows_failed': rowsFailed,
        'signed_off_by_uid': signedOffByUid,
        'signed_off_by': signedOffByName,
        'signed_at': Timestamp.fromDate(signedAt),
        'signature_hash': signatureHash,
        'status': status,
        if (notes != null) 'notes': notes,
      };

  factory ImportAuditRecord.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ImportAuditRecord(
      reference: snapshot.reference,
      targetCollection: data['target_collection'] as String? ?? '',
      sourceFile: data['source_file'] as String? ?? '',
      rowCount: (data['row_count'] as num?)?.toInt() ?? 0,
      rowsOk: (data['rows_ok'] as num?)?.toInt() ?? 0,
      rowsWarned: (data['rows_warned'] as num?)?.toInt() ?? 0,
      rowsFailed: (data['rows_failed'] as num?)?.toInt() ?? 0,
      signedOffByUid: data['signed_off_by_uid'] as String? ?? '',
      signedOffByName: data['signed_off_by'] as String? ?? '',
      signedAt: (data['signed_at'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      signatureHash: data['signature_hash'] as String? ?? '',
      status: data['status'] as String? ?? 'unknown',
      notes: data['notes'] as String?,
    );
  }
}
