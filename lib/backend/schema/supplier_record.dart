import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/flutter_flow/flutter_flow_util.dart';

import 'index.dart';

/// ═══════════════════════════════════════════════════════════════
///   SupplierRecord
///   ──────────────
///   Network-wide supplier directory entry. One document per
///   supplier across the entire Pulse network — independent of
///   pharmacy, so the same supplier can serve multiple pharmacies
///   without being re-created.
///
///   Collection: Supplier
/// ═══════════════════════════════════════════════════════════════
class SupplierRecord extends FirestoreRecord {
  SupplierRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Name" field. Required.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "ContactName" field. The primary contact at the supplier.
  String? _contactName;
  String? get contactName => _contactName;
  bool hasContactName() => _contactName != null;

  // "Email" field.
  String? _email;
  String? get email => _email;
  bool hasEmail() => _email != null;

  // "Phone" field.
  String? _phone;
  String? get phone => _phone;
  bool hasPhone() => _phone != null;

  // "Address" field. Full street address.
  String? _address;
  String? get address => _address;
  bool hasAddress() => _address != null;

  // "City" field.
  String? _city;
  String? get city => _city;
  bool hasCity() => _city != null;

  // "Country" field.
  String? _country;
  String? get country => _country;
  bool hasCountry() => _country != null;

  // "Category" field. e.g. "Pharmaceuticals", "Medical Devices",
  // "Consumables", "Equipment", "Other".
  String? _category;
  String? get category => _category;
  bool hasCategory() => _category != null;

  // "PaymentTerms" field. e.g. "Net 30", "COD", "Prepaid".
  String? _paymentTerms;
  String? get paymentTerms => _paymentTerms;
  bool hasPaymentTerms() => _paymentTerms != null;

  // "LeadTimeDays" field. Typical delivery lead time in days.
  int? _leadTimeDays;
  int get leadTimeDays => _leadTimeDays ?? 0;
  bool hasLeadTimeDays() => _leadTimeDays != null;

  // "TaxId" field. VAT / TIN / business registration number.
  String? _taxId;
  String? get taxId => _taxId;
  bool hasTaxId() => _taxId != null;

  // "Status" field. "active" | "inactive" | "blacklisted".
  // Default "active". Soft-delete = set to "inactive".
  String? _status;
  String get status => _status ?? 'active';
  bool hasStatus() => _status != null;

  // "Notes" field. Free-form notes / history.
  String? _notes;
  String? get notes => _notes;
  bool hasNotes() => _notes != null;

  // "Website" field.
  String? _website;
  String? get website => _website;
  bool hasWebsite() => _website != null;

  // "BankAccount" field. Bank account details for payment.
  String? _bankAccount;
  String? get bankAccount => _bankAccount;
  bool hasBankAccount() => _bankAccount != null;

  // "CreatedBy" field. The user who created this supplier record.
  DocumentReference? _createdBy;
  DocumentReference? get createdBy => _createdBy;
  bool hasCreatedBy() => _createdBy != null;

  // "CreatedAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "UpdatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  void _initializeFields() {
    _name = snapshotData['Name'] as String?;
    _contactName = snapshotData['ContactName'] as String?;
    _email = snapshotData['Email'] as String?;
    _phone = snapshotData['Phone'] as String?;
    _address = snapshotData['Address'] as String?;
    _city = snapshotData['City'] as String?;
    _country = snapshotData['Country'] as String?;
    _category = snapshotData['Category'] as String?;
    _paymentTerms = snapshotData['PaymentTerms'] as String?;
    _leadTimeDays = castToType<int>(snapshotData['LeadTimeDays']);
    _taxId = snapshotData['TaxId'] as String?;
    _status = snapshotData['Status'] as String?;
    _notes = snapshotData['Notes'] as String?;
    _website = snapshotData['Website'] as String?;
    _bankAccount = snapshotData['BankAccount'] as String?;
    _createdBy = snapshotData['CreatedBy'] as DocumentReference?;
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
    _updatedAt = snapshotData['UpdatedAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Supplier');

  static Stream<SupplierRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SupplierRecord.fromSnapshot(s));

  static Future<SupplierRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SupplierRecord.fromSnapshot(s));

  static SupplierRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SupplierRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SupplierRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SupplierRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SupplierRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SupplierRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSupplierRecordData({
  String? name,
  String? contactName,
  String? email,
  String? phone,
  String? address,
  String? city,
  String? country,
  String? category,
  String? paymentTerms,
  int? leadTimeDays,
  String? taxId,
  String? status,
  String? notes,
  String? website,
  String? bankAccount,
  DocumentReference? createdBy,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Name': name,
      'ContactName': contactName,
      'Email': email,
      'Phone': phone,
      'Address': address,
      'City': city,
      'Country': country,
      'Category': category,
      'PaymentTerms': paymentTerms,
      'LeadTimeDays': leadTimeDays,
      'TaxId': taxId,
      'Status': status,
      'Notes': notes,
      'Website': website,
      'BankAccount': bankAccount,
      'CreatedBy': createdBy,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class SupplierRecordDocumentEquality
    implements Equality<SupplierRecord> {
  const SupplierRecordDocumentEquality();

  @override
  bool equals(SupplierRecord? e1, SupplierRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.contactName == e2?.contactName &&
        e1?.email == e2?.email &&
        e1?.phone == e2?.phone &&
        e1?.address == e2?.address &&
        e1?.city == e2?.city &&
        e1?.country == e2?.country &&
        e1?.category == e2?.category &&
        e1?.paymentTerms == e2?.paymentTerms &&
        e1?.leadTimeDays == e2?.leadTimeDays &&
        e1?.taxId == e2?.taxId &&
        e1?.status == e2?.status &&
        e1?.notes == e2?.notes &&
        e1?.website == e2?.website &&
        e1?.bankAccount == e2?.bankAccount &&
        e1?.createdBy == e2?.createdBy &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(SupplierRecord? e) => const ListEquality().hash([
        e?.name,
        e?.contactName,
        e?.email,
        e?.phone,
        e?.address,
        e?.city,
        e?.country,
        e?.category,
        e?.paymentTerms,
        e?.leadTimeDays,
        e?.taxId,
        e?.status,
        e?.notes,
        e?.website,
        e?.bankAccount,
        e?.createdBy,
        e?.createdAt,
        e?.updatedAt,
      ]);

  @override
  bool isValidKey(Object? o) => o is SupplierRecord;
}
