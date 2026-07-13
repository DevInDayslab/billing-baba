import 'package:drift/drift.dart';

@DataClassName('SaleLocal')
class SalesLocal extends Table {
  TextColumn get id => text()();
  TextColumn get docNumber => text()();
  TextColumn get partyId => text().nullable()();
  RealColumn get totalAmount => real()();
  RealColumn get taxAmount => real()();
  RealColumn get finalAmount => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get savedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get paymentMethod => text()();
  TextColumn get apiResponseJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleLineLocal')
class SalesLineLocal extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(SalesLocal, #id)();
  TextColumn get itemId => text()();
  TextColumn get itemName => text()();
  IntColumn get quantity => integer()();
  RealColumn get rate => real()();
  RealColumn get lineTotal => real()();
  RealColumn get cgstAmount => real()();
  RealColumn get sgstAmount => real()();
  RealColumn get igstAmount => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class HeldBillsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get itemsJson => text()();
  TextColumn get paymentsJson => text().withDefault(const Constant('[]'))();
  TextColumn get customerName => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get heldAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
