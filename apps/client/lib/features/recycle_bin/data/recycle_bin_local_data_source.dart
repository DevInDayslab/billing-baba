import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/recycle_bin/models/recycle_bin_item.dart';
import 'package:drift/drift.dart';

const _retentionDays = 90;

class RecycleBinLocalDataSource {
  RecycleBinLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<RecycleBinItem>> listDeleted({required String businessId}) async {
    final cutoff = DateTime.now().toUtc().subtract(
      const Duration(days: _retentionDays),
    );
    final items = <RecycleBinItem>[];

    final sales = await (_db.select(_db.salesDocumentsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.isDeleted.equals(true) &
                t.deletedAt.isBiggerOrEqualValue(cutoff),
          ))
        .get();
    for (final row in sales) {
      if (row.deletedAt == null) continue;
      items.add(
        RecycleBinItem(
          entityType: 'sales_document',
          entityId: row.id,
          label: row.documentNumber ?? row.documentType,
          partyName: null,
          amount: row.totalAmount,
          transactionDate: row.documentDate,
          deletedAt: row.deletedAt!,
          daysRemaining: _daysRemaining(row.deletedAt!),
        ),
      );
    }

    final purchases = await (_db.select(_db.purchaseDocumentsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.isDeleted.equals(true) &
                t.deletedAt.isBiggerOrEqualValue(cutoff),
          ))
        .get();
    for (final row in purchases) {
      if (row.deletedAt == null) continue;
      items.add(
        RecycleBinItem(
          entityType: 'purchase_document',
          entityId: row.id,
          label: row.documentNumber ?? row.documentType,
          amount: row.totalAmount,
          transactionDate: row.documentDate,
          deletedAt: row.deletedAt!,
          daysRemaining: _daysRemaining(row.deletedAt!),
        ),
      );
    }

    final expenses = await (_db.select(_db.expensesLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.isDeleted.equals(true) &
                t.deletedAt.isBiggerOrEqualValue(cutoff),
          ))
        .get();
    for (final row in expenses) {
      if (row.deletedAt == null) continue;
      items.add(
        RecycleBinItem(
          entityType: 'expense',
          entityId: row.id,
          label: row.description ?? 'Expense',
          amount: row.amount,
          transactionDate: row.expenseDate,
          deletedAt: row.deletedAt!,
          daysRemaining: _daysRemaining(row.deletedAt!),
        ),
      );
    }

    items.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
    return items;
  }

  int _daysRemaining(DateTime deletedAt) {
    final expiresAt = deletedAt.add(const Duration(days: _retentionDays));
    final remaining = expiresAt.difference(DateTime.now().toUtc()).inDays;
    return remaining < 0 ? 0 : remaining;
  }
}
