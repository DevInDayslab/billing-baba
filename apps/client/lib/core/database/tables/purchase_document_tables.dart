import 'package:drift/drift.dart';

@DataClassName('PurchaseDocumentLocalData')
class PurchaseDocumentsLocal extends Table {
  @override
  String get tableName => 'purchase_documents_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get documentType => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get documentNumber => text().nullable()();
  TextColumn get documentSeries => text()();
  TextColumn get partyId => text()();
  BoolColumn get isGstFormal => boolean().withDefault(const Constant(false))();
  TextColumn get partyStateCode => text().nullable()();
  TextColumn get subtotal => text().withDefault(const Constant('0'))();
  TextColumn get discountTotal => text().withDefault(const Constant('0'))();
  TextColumn get taxAmount => text().withDefault(const Constant('0'))();
  TextColumn get totalAmount => text().withDefault(const Constant('0'))();
  TextColumn get documentDate => text()();
  TextColumn get convertedFromId => text().nullable()();
  TextColumn get supplierInvoiceNumber => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get godownId => text().nullable()();
  TextColumn get paidAmount => text().withDefault(const Constant('0'))();
  TextColumn get paymentMode => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PurchaseDocumentLineLocalData')
class PurchaseDocumentLinesLocal extends Table {
  @override
  String get tableName => 'purchase_document_lines_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get purchaseDocumentId => text()();
  TextColumn get itemId => text()();
  TextColumn get quantity => text()();
  TextColumn get unit => text()();
  TextColumn get unitPrice => text()();
  TextColumn get discountAmount => text().withDefault(const Constant('0'))();
  TextColumn get taxType => text().withDefault(const Constant('none'))();
  TextColumn get taxRate => text().withDefault(const Constant('0'))();
  TextColumn get cgstAmount => text().withDefault(const Constant('0'))();
  TextColumn get sgstAmount => text().withDefault(const Constant('0'))();
  TextColumn get igstAmount => text().withDefault(const Constant('0'))();
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
