import 'package:drift/drift.dart';

@DataClassName('ExpenseCategoryTableData')
class ExpenseCategoriesLocal extends Table {
  @override
  String get tableName => 'expense_categories_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get categoryType => text().withDefault(const Constant('direct'))();
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

@DataClassName('ExpenseItemTableData')
class ExpenseItemsLocal extends Table {
  @override
  String get tableName => 'expense_items_local';

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

@DataClassName('ExpenseTableData')
class ExpensesLocal extends Table {
  @override
  String get tableName => 'expenses_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get categoryId => text()();
  TextColumn get expenseItemId => text().nullable()();
  TextColumn get partyId => text().nullable()();
  TextColumn get amount => text()();
  TextColumn get taxAmount => text().withDefault(const Constant('0'))();
  TextColumn get taxRate => text().withDefault(const Constant('0'))();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get expenseDate => text()();
  TextColumn get paymentMode => text().nullable()();
  TextColumn get bankAccountId => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
