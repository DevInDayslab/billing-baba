import 'dart:convert';

import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/other_income/models/dto/other_income_dto.dart';
import 'package:drift/drift.dart';

/// Drift-backed local store for expenses and categories.
class OtherIncomeLocalDataSource {
  OtherIncomeLocalDataSource(this._db);

  final AppDatabase _db;

  static ({int count, double total}) _emptyAggregate() => (count: 0, total: 0);

  Future<Map<String, ({int count, double total})>> _categoryAggregates(
    String businessId,
  ) async {
    final rows =
        await (_db.select(_db.otherIncomesLocal)..where(
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
        await (_db.select(_db.otherIncomesLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();

    final aggregates = <String, ({int count, double total})>{};
    for (final row in rows) {
      final itemId = row.incomeItemId;
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

  Future<List<IncomeCategoryDto>> listCategories(String businessId) async {
    final aggregates = await _categoryAggregates(businessId);
    final rows =
        await (_db.select(_db.incomeCategoriesLocal)
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

  Future<List<OtherIncomeDto>> listOtherIncomes(
    String businessId, {
    String? categoryId,
  }) async {
    final query = _db.select(_db.otherIncomesLocal)
      ..where(
        (t) => t.businessId.equals(businessId) & t.isDeleted.equals(false),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.incomeDate)]);
    final rows = await query.get();
    final categories = {
      for (final c in await listCategories(businessId)) c.id: c.name,
    };
    return rows
        .where((r) => categoryId == null || r.categoryId == categoryId)
        .map((r) => _expenseToDto(r, categories[r.categoryId]))
        .toList();
  }

  Future<OtherIncomeDto?> getOtherIncome(String id) async {
    final row = await (_db.select(
      _db.otherIncomesLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null || row.isDeleted) return null;
    final category = await (_db.select(
      _db.incomeCategoriesLocal,
    )..where((t) => t.id.equals(row.categoryId))).getSingleOrNull();
    return _expenseToDto(row, category?.name);
  }

  Future<List<IncomeItemDto>> listIncomeItems(String businessId) async {
    final aggregates = await _expenseItemAggregates(businessId);
    final rows =
        await (_db.select(_db.incomeItemsLocal)
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

  Future<IncomeItemDto?> getIncomeItem(String id) async {
    final row = await (_db.select(
      _db.incomeItemsLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null || row.isDeleted) return null;
    final aggregates = await _expenseItemAggregates(row.businessId);
    return _expenseItemToDto(row, aggregates[row.id]);
  }

  Future<IncomeCategoryDto?> getCategory(String id) async {
    final row = await (_db.select(
      _db.incomeCategoriesLocal,
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
        .into(_db.incomeCategoriesLocal)
        .insertOnConflictUpdate(
          IncomeCategoriesLocalCompanion.insert(
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

  Future<void> upsertOtherIncomeItem({
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
        .into(_db.incomeItemsLocal)
        .insertOnConflictUpdate(
          IncomeItemsLocalCompanion.insert(
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

  Future<void> upsertOtherIncomeItemFromDto(
    String businessId,
    IncomeItemDto dto,
  ) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated = DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertOtherIncomeItem(
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

  Future<void> softDeleteOtherIncomeItem(String id, DateTime deletedAt) async {
    await (_db.update(
      _db.incomeItemsLocal,
    )..where((t) => t.id.equals(id))).write(
      IncomeItemsLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  Future<void> upsertOtherIncome({
    required String id,
    required String businessId,
    required String categoryId,
    required String amount,
    required String incomeDate,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? incomeItemId,
    String? description,
    String? bankAccountId,
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
        .into(_db.otherIncomesLocal)
        .insertOnConflictUpdate(
          OtherIncomesLocalCompanion.insert(
            id: id,
            businessId: businessId,
            categoryId: categoryId,
            incomeItemId: Value(incomeItemId),
            amount: amount,
            incomeDate: incomeDate,
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            description: Value(description),
            notes: Value(notes),
            referenceNumber: Value(referenceNumber),
            taxAmount: Value(taxAmount ?? '0'),
            taxRate: Value(taxRate ?? '0'),
            paymentMode: Value(paymentMode),
            bankAccountId: Value(bankAccountId),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> upsertCategoryFromDto(
    String businessId,
    IncomeCategoryDto dto,
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

  Future<void> upsertOtherIncomeFromDto(String businessId, OtherIncomeDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated = DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertOtherIncome(
      id: dto.id,
      businessId: businessId,
      categoryId: dto.categoryId,
      incomeItemId: dto.incomeItemId,
      amount: dto.amount,
      bankAccountId: dto.bankAccountId,
      incomeDate: dto.incomeDate,
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

  Future<void> softDeleteOtherIncome(String id, DateTime deletedAt) async {
    await (_db.update(_db.otherIncomesLocal)..where((t) => t.id.equals(id))).write(
      OtherIncomesLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  Future<void> softDeleteCategory(String id, DateTime deletedAt) async {
    await (_db.update(
      _db.incomeCategoriesLocal,
    )..where((t) => t.id.equals(id))).write(
      IncomeCategoriesLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  IncomeCategoryDto _categoryToDto(
    IncomeCategoryTableData row, [
    ({int count, double total})? aggregate,
  ]) {
    final stats = aggregate ?? _emptyAggregate();
    return IncomeCategoryDto(
      id: row.id,
      name: row.name,
      categoryType: row.categoryType,
      isSystem: row.isSystem,
      incomeCount: stats.count,
      totalAmount: stats.total.toStringAsFixed(4),
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }

  IncomeItemDto _expenseItemToDto(
    IncomeItemTableData row, [
    ({int count, double total})? aggregate,
  ]) {
    final stats = aggregate ?? _emptyAggregate();
    return IncomeItemDto(
      id: row.id,
      name: row.name,
      hsnSac: row.hsnSac,
      price: row.price,
      priceIsTaxInclusive: row.priceIsTaxInclusive,
      taxRate: row.taxRate,
      incomeCount: stats.count,
      totalAmount: stats.total.toStringAsFixed(4),
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }

  OtherIncomeDto _expenseToDto(OtherIncomeTableData row, String? categoryName) {
    return OtherIncomeDto(
      id: row.id,
      categoryId: row.categoryId,
      categoryName: categoryName,
      incomeItemId: row.incomeItemId,
      amount: row.amount,
      bankAccountId: row.bankAccountId,
      incomeDate: row.incomeDate,
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
