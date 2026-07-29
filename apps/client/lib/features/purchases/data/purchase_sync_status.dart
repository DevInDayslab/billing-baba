import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';

/// Derives purchase bill sync badge state from SyncQueue jobs for a document.
PurchaseBillSyncState resolvePurchaseBillSyncState({
  required List<SyncJob> jobs,
  required bool isDraft,
  required String invoiceNo,
}) {
  if (jobs.isEmpty) {
    if (isDraft || invoiceNo.startsWith('LOCAL-')) {
      return PurchaseBillSyncState.savedLocally;
    }
    return PurchaseBillSyncState.none;
  }

  if (jobs.any((job) => job.status == SyncQueueStatus.conflict)) {
    return PurchaseBillSyncState.conflict;
  }

  final active = jobs.where(
    (job) =>
        job.status == SyncQueueStatus.pending ||
        job.status == SyncQueueStatus.running,
  );
  if (active.isNotEmpty) {
    return PurchaseBillSyncState.syncing;
  }

  if (isDraft || invoiceNo.startsWith('LOCAL-')) {
    return PurchaseBillSyncState.savedLocally;
  }

  return PurchaseBillSyncState.synced;
}

/// Reconciles local purchase bill state after finalize command conflicts.
class PurchaseSyncRecovery {
  PurchaseSyncRecovery({
    required this._purchaseLocal,
    required this._syncQueue,
  });

  final PurchaseLocalDataSource _purchaseLocal;
  final SyncQueue _syncQueue;

  Future<void> reconcileFinalizeConflict(String documentId) async {
    final document = await _purchaseLocal.getDocument(documentId);
    if (document == null) {
      return;
    }

    await _purchaseLocal.applyFinalizeAck(
      documentId: documentId,
      status: 'finalized',
      documentNumber: document.documentNumber,
      syncVersion: await _purchaseLocal.getHeaderSyncVersion(documentId) ?? 0,
      updatedAt: DateTime.now().toUtc(),
      paidAmount: document.paidAmount,
      paymentMode: document.paymentMode,
    );

    final jobs = await _syncQueue.listJobsForEntity(documentId);
    for (final job in jobs) {
      if (job.status == SyncQueueStatus.conflict &&
          job.kind == SyncQueueKind.command) {
        await _syncQueue.markCompleted(job.id);
      }
    }
  }
}
