import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final transactionLifecycleServiceProvider =
    Provider<TransactionLifecycleService>((ref) {
  return TransactionLifecycleService(ref);
});

class TransactionLifecycleService {
  TransactionLifecycleService(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  Future<void> deleteTransaction({
    required String entityType,
    required String entityId,
  }) async {
    final businessId = _ref.read(currentBusinessProvider)?.id;
    if (businessId == null) return;

    final now = DateTime.now().toUtc();
    await _tombstoneLocally(
      businessId: businessId,
      entityType: entityType,
      entityId: entityId,
      deletedAt: now,
    );

    final syncQueue = _ref.read(syncQueueProvider);
    await syncQueue.enqueueCommand(
      businessId: businessId,
      command: 'delete_transaction',
      commandId: _uuid.v4(),
      payload: {
        'entity_type': entityType,
        'entity_id': entityId,
      },
      entityType: entityType,
      entityId: entityId,
    );
  }

  Future<void> _tombstoneLocally({
    required String businessId,
    required String entityType,
    required String entityId,
    required DateTime deletedAt,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    switch (entityType) {
      case 'sales_document':
        await (db.update(db.salesDocumentsLocal)
              ..where((t) => t.id.equals(entityId)))
            .write(
          SalesDocumentsLocalCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(deletedAt),
            updatedAt: Value(deletedAt),
          ),
        );
      case 'purchase_document':
        await (db.update(db.purchaseDocumentsLocal)
              ..where((t) => t.id.equals(entityId)))
            .write(
          PurchaseDocumentsLocalCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(deletedAt),
            updatedAt: Value(deletedAt),
          ),
        );
      case 'expense':
        await (db.update(db.expensesLocal)..where((t) => t.id.equals(entityId)))
            .write(
          ExpensesLocalCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(deletedAt),
            updatedAt: Value(deletedAt),
          ),
        );
      case 'other_income':
        await (db.update(db.otherIncomesLocal)
              ..where((t) => t.id.equals(entityId)))
            .write(
          OtherIncomesLocalCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(deletedAt),
            updatedAt: Value(deletedAt),
          ),
        );
      case 'loan_transaction':
        await (db.update(db.loanTransactionsLocal)
              ..where((t) => t.id.equals(entityId)))
            .write(
          LoanTransactionsLocalCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(deletedAt),
            updatedAt: Value(deletedAt),
          ),
        );
      case 'payment':
        break;
    }
  }
}
