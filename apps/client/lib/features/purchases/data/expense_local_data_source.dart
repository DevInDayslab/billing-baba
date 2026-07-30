import 'dart:convert';

import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:drift/drift.dart';

/// Drift-backed local store for expenses and categories.
class ExpenseLocalDataSource {
  ExpenseLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<ExpenseCategoryDto>> listCategories(String businessId) async {
    final rows = await (_db.select(_db.expenseCategoriesLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(_categoryToDto).toList();
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
    final row = await (_db.select(_db.expensesLocal)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null || row.isDeleted) return null;
    final category = await (_db.select(_db.expenseCategoriesLocal)
          ..where((t) => t.id.equals(row.categoryId)))
        .getSingleOrNull();
    return _expenseToDto(row, category?.name);
  }

  Future<ExpenseCategoryDto?> getCategory(String id) async {
    final row = await (_db.select(_db.expenseCategoriesLocal)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null || row.isDeleted) return null;
    return _categoryToDto(row);
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
    return _db.into(_db.expenseCategoriesLocal).insertOnConflictUpdate(
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

  Future<void> upsertExpense({
    required String id,
    required String businessId,
    required String categoryId,
    required String amount,
    required String expenseDate,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
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
    return _db.into(_db.expensesLocal).insertOnConflictUpdate(
          ExpensesLocalCompanion.insert(
            id: id,
            businessId: businessId,
            categoryId: categoryId,
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

  Future<void> upsertCategoryFromDto(String businessId, ExpenseCategoryDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated =
        DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
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
    final updated =
        DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertExpense(
      id: dto.id,
      businessId: businessId,
      categoryId: dto.categoryId,
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
    await (_db.update(_db.expenseCategoriesLocal)
          ..where((t) => t.id.equals(id)))
        .write(
      ExpenseCategoriesLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  ExpenseCategoryDto _categoryToDto(ExpenseCategoryTableData row) {
    return ExpenseCategoryDto(
      id: row.id,
      name: row.name,
      categoryType: row.categoryType,
      isSystem: row.isSystem,
      expenseCount: 0,
      totalAmount: '0',
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }

  ExpenseDto _expenseToDto(ExpenseTableData row, String? categoryName) {
    return ExpenseDto(
      id: row.id,
      categoryId: row.categoryId,
      categoryName: categoryName,
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
