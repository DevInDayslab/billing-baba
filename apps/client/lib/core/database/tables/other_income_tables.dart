import 'package:drift/drift.dart';

@DataClassName('IncomeCategoryTableData')
class IncomeCategoriesLocal extends Table {
  @override
  String get tableName => 'income_categories_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get categoryType =>
      text().withDefault(const Constant('indirect'))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('IncomeItemTableData')
class IncomeItemsLocal extends Table {
  @override
  String get tableName => 'income_items_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get hsnSac => text().nullable()();
  TextColumn get price => text().withDefault(const Constant('0'))();
  BoolColumn get priceIsTaxInclusive =>
      boolean().withDefault(const Constant(false))();
  TextColumn get taxRate => text().withDefault(const Constant('0'))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('OtherIncomeTableData')
class OtherIncomesLocal extends Table {
  @override
  String get tableName => 'other_incomes_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get categoryId => text()();
  TextColumn get incomeItemId => text().nullable()();
  TextColumn get amount => text()();
  TextColumn get quantity => text().nullable()();
  TextColumn get taxAmount => text().withDefault(const Constant('0'))();
  TextColumn get taxRate => text().withDefault(const Constant('0'))();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get incomeDate => text()();
  TextColumn get paymentMode => text().nullable()();
  TextColumn get bankAccountId => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get balanceDue => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
