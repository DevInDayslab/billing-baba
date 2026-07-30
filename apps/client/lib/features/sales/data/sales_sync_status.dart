import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';

/// Derives invoice sync badge state from SyncQueue jobs for a document.
SaleInvoiceSyncState resolveSaleInvoiceSyncState({
  required List<SyncJob> jobs,
  required bool isDraft,
  required String invoiceNo,
}) {
  if (jobs.isEmpty) {
    if (isDraft || invoiceNo.startsWith('LOCAL-')) {
      return SaleInvoiceSyncState.savedLocally;
    }
    return SaleInvoiceSyncState.none;
  }

  if (jobs.any((job) => job.status == SyncQueueStatus.conflict)) {
    return SaleInvoiceSyncState.conflict;
  }

  final active = jobs.where(
    (job) =>
        job.status == SyncQueueStatus.pending ||
        job.status == SyncQueueStatus.running,
  );
  if (active.isNotEmpty) {
    return SaleInvoiceSyncState.syncing;
  }

  if (isDraft || invoiceNo.startsWith('LOCAL-')) {
    return SaleInvoiceSyncState.savedLocally;
  }

  return SaleInvoiceSyncState.synced;
}

/// Reconciles local tax invoice state after finalize command conflicts.
class SalesSyncRecovery {
  SalesSyncRecovery({
    required this._salesLocal,
    required this._syncQueue,
  });

  final SalesLocalDataSource _salesLocal;
  final SyncQueue _syncQueue;

  Future<void> reconcileFinalizeConflict(String documentId) async {
    final document = await _salesLocal.getDocument(documentId);
    if (document == null) {
      return;
    }

    await _salesLocal.applyFinalizeAck(
      documentId: documentId,
      status: 'finalized',
      documentNumber: document.documentNumber,
      syncVersion: await _salesLocal.getHeaderSyncVersion(documentId) ?? 0,
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
