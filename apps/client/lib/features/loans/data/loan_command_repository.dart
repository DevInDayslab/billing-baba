import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/loans/data/loan_account_local_source.dart';
import 'package:billing_baba/features/loans/data/loan_sync.dart';
import 'package:billing_baba/features/loans/models/loan_models.dart';
import 'package:uuid/uuid.dart';

const _loanAccountsEntity = 'loan_accounts';
const _loanTransactionsEntity = 'loan_transactions';

class LoanCommandRepository {
  LoanCommandRepository({
    required AppDatabase db,
    required SyncQueue syncQueue,
    required String Function() businessIdReader,
    String? Function()? deviceIdReader,
  })  : _db = db,
        _syncQueue = syncQueue,
        _businessIdReader = businessIdReader,
        _deviceIdReader = deviceIdReader,
        _accountSync = LoanAccountSync(db),
        _transactionSync = LoanTransactionSync(db),
        _accounts = LoanAccountLocalSource(db);

  final AppDatabase _db;
  final SyncQueue _syncQueue;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;
  final LoanAccountSync _accountSync;
  final LoanTransactionSync _transactionSync;
  final LoanAccountLocalSource _accounts;
  final _uuid = const Uuid();

  String _requireBusinessId() {
    final id = _businessIdReader();
    if (id.isEmpty) {
      throw StateError('No active business');
    }
    return id;
  }

  Future<LoanAccountDto> createAccount(Map<String, dynamic> body) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final payload = Map<String, dynamic>.from(body);

    await _accountSync.applyChange(
      businessId: businessId,
      entityId: id,
      syncVersion: 0,
      updatedAt: now,
      isDeleted: false,
      deviceId: _deviceIdReader?.call(),
      payload: payload,
    );

    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _loanAccountsEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: payload,
      clientUpdatedAt: now,
    );

    final saved = await _accounts.getById(id);
    if (saved == null) {
      throw StateError('Failed to persist loan account locally');
    }
    return saved;
  }

  Future<LoanAccountDto> updateAccount(
    String id,
    Map<String, dynamic> body,
  ) async {
    final businessId = _requireBusinessId();
    final existing = await _accounts.getById(id);
    final now = DateTime.now().toUtc();
    final payload = Map<String, dynamic>.from(body);

    await _accountSync.applyChange(
      businessId: businessId,
      entityId: id,
      syncVersion: 0,
      updatedAt: now,
      isDeleted: false,
      deviceId: _deviceIdReader?.call(),
      payload: {
        ...?existing?.toSyncPayload(),
        ...payload,
      },
    );

    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _loanAccountsEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: payload,
      clientUpdatedAt: now,
    );

    return (await _accounts.getById(id))!;
  }

  Future<LoanTransactionDto> createTransaction(
    Map<String, dynamic> body,
  ) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final payload = Map<String, dynamic>.from(body);

    await _transactionSync.applyChange(
      businessId: businessId,
      entityId: id,
      syncVersion: 0,
      updatedAt: now,
      isDeleted: false,
      deviceId: _deviceIdReader?.call(),
      payload: payload,
    );

    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _loanTransactionsEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: payload,
      clientUpdatedAt: now,
    );

    final row = await (_db.select(_db.loanTransactionsLocal)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      throw StateError('Failed to persist loan transaction locally');
    }
    return LoanTransactionDto(
      id: row.id,
      loanAccountId: row.loanAccountId,
      transactionType: row.transactionType,
      transactionDate: row.transactionDate,
      principalAmount: row.principalAmount,
      interestAmount: row.interestAmount,
      chargesAmount: row.chargesAmount,
      bankAccountId: row.bankAccountId,
      description: row.description,
      referenceNumber: row.referenceNumber,
    );
  }
}
