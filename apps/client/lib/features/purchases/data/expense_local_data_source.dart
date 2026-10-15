import 'dart:convert';

import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:drift/drift.dart';

/// Drift-backed local store for expenses and categories.
class ExpenseLocalDataSource {
  ExpenseLocalDataSource(this._db);

  final AppDatabase _db;

  static ({int count, double total}) _emptyAggregate() => (count: 0, total: 0);

  Future<Map<String, ({int count, double total})>> _categoryAggregates(
    String businessId,
  ) async {
    final rows =
        await (_db.select(_db.expensesLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();

    final aggregates = <String, ({int count, double total})>{};
    for (final row in rows) {
      final amount = double.tryParse(row.amount) ?? 0;
      final existing = aggregates[row.categoryId] ?? _emptyAggregate();
      aggregates[row.categoryId] = (
        count: existing.count + 1,
        total: existing.total + amount,
      );
    }
    return aggregates;
  }

  Future<Map<String, ({int count, double total})>> _expenseItemAggregates(
    String businessId,
  ) async {
    final rows =
        await (_db.select(_db.expensesLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();

    final aggregates = <String, ({int count, double total})>{};
    for (final row in rows) {
      final itemId = row.expenseItemId;
      if (itemId == null || itemId.isEmpty) continue;
      final amount = double.tryParse(row.amount) ?? 0;
      final existing = aggregates[itemId] ?? _emptyAggregate();
      aggregates[itemId] = (
        count: existing.count + 1,
        total: existing.total + amount,
      );
    }
    return aggregates;
  }

  Future<List<ExpenseCategoryDto>> listCategories(String businessId) async {
    final aggregates = await _categoryAggregates(businessId);
    final rows =
        await (_db.select(_db.expenseCategoriesLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) & t.isDeleted.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .get();
    return rows
        .map((row) => _categoryToDto(row, aggregates[row.id]))
        .toList();
  }

  Future<List<ExpenseDto>> listExpenses(
    String businessId, {
    String? categoryId,
  }) async {
    final query = _db.select(_db.expensesLocal)
      ..where(
        (t) => t.businessId.equals(businessId) & t.isDeleted.equals(false),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.expenseDate)]);
    final rows = await query.get();
    final categories = {
      for (final c in await listCategories(businessId)) c.id: c.name,
    };
    return rows
        .where((r) => categoryId == null || r.categoryId == categoryId)
        .map((r) => _expenseToDto(r, categories[r.categoryId]))
        .toList();
  }

  Future<ExpenseDto?> getExpense(String id) async {
    final row = await (_db.select(
      _db.expensesLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null || row.isDeleted) return null;
    final category = await (_db.select(
      _db.expenseCategoriesLocal,
    )..where((t) => t.id.equals(row.categoryId))).getSingleOrNull();
    return _expenseToDto(row, category?.name);
  }

  Future<List<ExpenseItemDto>> listExpenseItems(String businessId) async {
    final aggregates = await _expenseItemAggregates(businessId);
    final rows =
        await (_db.select(_db.expenseItemsLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) & t.isDeleted.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .get();
    return rows
        .map((row) => _expenseItemToDto(row, aggregates[row.id]))
        .toList();
  }

  Future<ExpenseItemDto?> getExpenseItem(String id) async {
    final row = await (_db.select(
      _db.expenseItemsLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null || row.isDeleted) return null;
    final aggregates = await _expenseItemAggregates(row.businessId);
    return _expenseItemToDto(row, aggregates[row.id]);
  }

  Future<ExpenseCategoryDto?> getCategory(String id) async {
    final row = await (_db.select(
      _db.expenseCategoriesLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null || row.isDeleted) return null;
    final aggregates = await _categoryAggregates(row.businessId);
    return _categoryToDto(row, aggregates[row.id]);
  }

  Future<void> upsertCategory({
    required String id,
    required String businessId,
    required String name,
    required String categoryType,
    required bool isSystem,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? deviceId,
    bool isDeleted = false,
    DateTime? deletedAt,
  }) {
    return _db
        .into(_db.expenseCategoriesLocal)
        .insertOnConflictUpdate(
          ExpenseCategoriesLocalCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            categoryType: Value(categoryType),
            isSystem: Value(isSystem),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> upsertExpenseItem({
    required String id,
    required String businessId,
    required String name,
    String? hsnSac,
    required String price,
    required bool priceIsTaxInclusive,
    required String taxRate,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? deviceId,
    bool isDeleted = false,
    DateTime? deletedAt,
  }) {
    return _db
        .into(_db.expenseItemsLocal)
        .insertOnConflictUpdate(
          ExpenseItemsLocalCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            hsnSac: Value(hsnSac),
            price: Value(price),
            priceIsTaxInclusive: Value(priceIsTaxInclusive),
            taxRate: Value(taxRate),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> upsertExpenseItemFromDto(
    String businessId,
    ExpenseItemDto dto,
  ) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated = DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertExpenseItem(
      id: dto.id,
      businessId: businessId,
      name: dto.name,
      hsnSac: dto.hsnSac,
      price: dto.price,
      priceIsTaxInclusive: dto.priceIsTaxInclusive,
      taxRate: dto.taxRate,
      syncVersion: 0,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Future<void> softDeleteExpenseItem(String id, DateTime deletedAt) async {
    await (_db.update(
      _db.expenseItemsLocal,
    )..where((t) => t.id.equals(id))).write(
      ExpenseItemsLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  Future<void> upsertExpense({
    required String id,
    required String businessId,
    required String categoryId,
    required String amount,
    required String expenseDate,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? expenseItemId,
    String? partyId,
    String? description,
    String? notes,
    String? referenceNumber,
    String? taxAmount,
    String? taxRate,
    String? paymentMode,
    String? deviceId,
    bool isDeleted = false,
    DateTime? deletedAt,
  }) {
    return _db
        .into(_db.expensesLocal)
        .insertOnConflictUpdate(
          ExpensesLocalCompanion.insert(
            id: id,
            businessId: businessId,
            categoryId: categoryId,
            expenseItemId: Value(expenseItemId),
            partyId: Value(partyId),
            amount: amount,
            expenseDate: expenseDate,
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            description: Value(description),
            notes: Value(notes),
            referenceNumber: Value(referenceNumber),
            taxAmount: Value(taxAmount ?? '0'),
            taxRate: Value(taxRate ?? '0'),
            paymentMode: Value(paymentMode),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> upsertCategoryFromDto(
    String businessId,
    ExpenseCategoryDto dto,
  ) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated = DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertCategory(
      id: dto.id,
      businessId: businessId,
      name: dto.name,
      categoryType: dto.categoryType,
      isSystem: dto.isSystem,
      syncVersion: 0,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Future<void> upsertExpenseFromDto(String businessId, ExpenseDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated = DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertExpense(
      id: dto.id,
      businessId: businessId,
      categoryId: dto.categoryId,
      expenseItemId: dto.expenseItemId,
      partyId: dto.partyId,
      amount: dto.amount,
      expenseDate: dto.expenseDate,
      description: dto.description,
      notes: dto.notes,
      referenceNumber: dto.referenceNumber,
      taxAmount: dto.taxAmount,
      taxRate: dto.taxRate,
      paymentMode: dto.paymentMode,
      syncVersion: 0,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Future<void> softDeleteExpense(String id, DateTime deletedAt) async {
    await (_db.update(_db.expensesLocal)..where((t) => t.id.equals(id))).write(
      ExpensesLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  Future<void> softDeleteCategory(String id, DateTime deletedAt) async {
    await (_db.update(
      _db.expenseCategoriesLocal,
    )..where((t) => t.id.equals(id))).write(
      ExpenseCategoriesLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  ExpenseCategoryDto _categoryToDto(
    ExpenseCategoryTableData row, [
    ({int count, double total})? aggregate,
  ]) {
    final stats = aggregate ?? _emptyAggregate();
    return ExpenseCategoryDto(
      id: row.id,
      name: row.name,
      categoryType: row.categoryType,
      isSystem: row.isSystem,
      expenseCount: stats.count,
      totalAmount: stats.total.toStringAsFixed(4),
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }

  ExpenseItemDto _expenseItemToDto(
    ExpenseItemTableData row, [
    ({int count, double total})? aggregate,
  ]) {
    final stats = aggregate ?? _emptyAggregate();
    return ExpenseItemDto(
      id: row.id,
      name: row.name,
      hsnSac: row.hsnSac,
      price: row.price,
      priceIsTaxInclusive: row.priceIsTaxInclusive,
      taxRate: row.taxRate,
      expenseCount: stats.count,
      totalAmount: stats.total.toStringAsFixed(4),
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }

  ExpenseDto _expenseToDto(ExpenseTableData row, String? categoryName) {
    return ExpenseDto(
      id: row.id,
      categoryId: row.categoryId,
      categoryName: categoryName,
      expenseItemId: row.expenseItemId,
      partyId: row.partyId,
      amount: row.amount,
      expenseDate: row.expenseDate,
      description: row.description,
      notes: row.notes,
      referenceNumber: row.referenceNumber,
      taxAmount: row.taxAmount,
      taxRate: row.taxRate,
      paymentMode: row.paymentMode,
      attachments: const [],
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }

  String encodeAttachments(List<String> attachments) => jsonEncode(attachments);
}
