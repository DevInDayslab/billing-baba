import 'package:drift/drift.dart';

@DataClassName('SalesDocumentLocalData')
class SalesDocumentsLocal extends Table {
  @override
  String get tableName => 'sales_documents_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get documentType => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get documentNumber => text().nullable()();
  TextColumn get documentSeries => text()();
  TextColumn get partyId => text().nullable()();
  BoolColumn get isGstFormal => boolean().withDefault(const Constant(false))();
  TextColumn get partyStateCode => text().nullable()();
  TextColumn get subtotal => text().withDefault(const Constant('0'))();
  TextColumn get discountTotal => text().withDefault(const Constant('0'))();
  TextColumn get taxAmount => text().withDefault(const Constant('0'))();
  TextColumn get tcsSectionId => text().nullable()();
  TextColumn get tcsRate => text().nullable()();
  TextColumn get tcsBaseAmount => text().withDefault(const Constant('0'))();
  TextColumn get tcsAmount => text().withDefault(const Constant('0'))();
  TextColumn get totalAmount => text().withDefault(const Constant('0'))();
  TextColumn get paidAmount => text().withDefault(const Constant('0'))();
  TextColumn get paymentMode => text().nullable()();
  TextColumn get documentDate => text()();
  TextColumn get convertedFromId => text().nullable()();
  TextColumn get originalDocumentId => text().nullable()();
  TextColumn get originalDocumentNumber => text().nullable()();
  TextColumn get originalDocumentDate => text().nullable()();
  TextColumn get supplyType =>
      text().withDefault(const Constant('domestic'))();
  TextColumn get notes => text().nullable()();
  TextColumn get godownId => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SalesDocumentLineLocalData')
class SalesDocumentLinesLocal extends Table {
  @override
  String get tableName => 'sales_document_lines_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get salesDocumentId => text()();
  TextColumn get itemId => text()();
  TextColumn get quantity => text()();
  TextColumn get unit => text()();
  TextColumn get unitPrice => text()();
  TextColumn get marketPrice => text().nullable()();
  TextColumn get discountAmount => text().withDefault(const Constant('0'))();
  TextColumn get taxType => text().withDefault(const Constant('none'))();
  TextColumn get taxRate => text().withDefault(const Constant('0'))();
  TextColumn get cgstAmount => text().withDefault(const Constant('0'))();
  TextColumn get sgstAmount => text().withDefault(const Constant('0'))();
  TextColumn get igstAmount => text().withDefault(const Constant('0'))();
  TextColumn get cessRate => text().withDefault(const Constant('0'))();
  TextColumn get cessAmount => text().withDefault(const Constant('0'))();
  TextColumn get lineTotal => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LocalDocumentCounterData')
class LocalDocumentCounters extends Table {
  @override
  String get tableName => 'local_document_counters';

  TextColumn get businessId => text()();
  TextColumn get documentSeries => text()();
  IntColumn get nextNumber => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {businessId, documentSeries};
}
