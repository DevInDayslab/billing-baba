import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/command_sync/application/command_ack_applier.dart';
import 'package:billing_baba/features/command_sync/application/command_aware_sync_engine.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_runner.dart';
import 'package:billing_baba/features/documents/data/local_document_number_service.dart';
import 'package:billing_baba/features/purchases/data/purchase_bill_command_repository.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_return_command_repository.dart';
import 'package:billing_baba/features/purchases/data/purchase_sync_status.dart';
import 'package:billing_baba/features/sales/data/sales_invoice_command_repository.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_return_command_repository.dart';
import 'package:billing_baba/features/sales/data/sales_sync_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localDocumentNumberServiceProvider =
    Provider<LocalDocumentNumberService>((ref) {
  return LocalDocumentNumberService(ref.watch(appDatabaseProvider));
});

final salesInvoiceCommandRepositoryProvider =
    FutureProvider<SalesInvoiceCommandRepository>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final db = ref.watch(appDatabaseProvider);
  return SalesInvoiceCommandRepository(
    local: SalesLocalDataSource(db),
    syncQueue: ref.watch(syncQueueProvider),
    numbering: ref.watch(localDocumentNumberServiceProvider),
    businessIdReader: () => storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
    deviceIdReader: () => storage.read(StorageKeys.syncDeviceId),
  );
});

final purchaseBillCommandRepositoryProvider =
    FutureProvider<PurchaseBillCommandRepository>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final db = ref.watch(appDatabaseProvider);
  return PurchaseBillCommandRepository(
    local: PurchaseLocalDataSource(db),
    syncQueue: ref.watch(syncQueueProvider),
    numbering: ref.watch(localDocumentNumberServiceProvider),
    businessIdReader: () => storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
    deviceIdReader: () => storage.read(StorageKeys.syncDeviceId),
  );
});

final salesReturnCommandRepositoryProvider =
    FutureProvider<SalesReturnCommandRepository>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final db = ref.watch(appDatabaseProvider);
  return SalesReturnCommandRepository(
    local: SalesLocalDataSource(db),
    syncQueue: ref.watch(syncQueueProvider),
    numbering: ref.watch(localDocumentNumberServiceProvider),
    businessIdReader: () => storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
    deviceIdReader: () => storage.read(StorageKeys.syncDeviceId),
  );
});

final purchaseReturnCommandRepositoryProvider =
    FutureProvider<PurchaseReturnCommandRepository>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final db = ref.watch(appDatabaseProvider);
  return PurchaseReturnCommandRepository(
    local: PurchaseLocalDataSource(db),
    syncQueue: ref.watch(syncQueueProvider),
    numbering: ref.watch(localDocumentNumberServiceProvider),
    businessIdReader: () => storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
    deviceIdReader: () => storage.read(StorageKeys.syncDeviceId),
  );
});

final commandSyncRunnerProvider =
    FutureProvider<CommandSyncRunner>((ref) async {
  final api = await ref.watch(syncApiProvider.future);
  final identity = await ref.watch(syncDeviceIdentityProvider.future);
  final db = ref.watch(appDatabaseProvider);
  final salesRecovery = SalesSyncRecovery(
    salesLocal: SalesLocalDataSource(db),
    syncQueue: ref.watch(syncQueueProvider),
  );
  final purchaseRecovery = PurchaseSyncRecovery(
    purchaseLocal: PurchaseLocalDataSource(db),
    syncQueue: ref.watch(syncQueueProvider),
  );
  return CommandSyncRunner(
    api: api,
    queue: ref.watch(syncQueueProvider),
    identity: identity,
    ackApplier: CommandAckApplier(db: db),
    onCommandConflict: (job, code) async {
      if (code == 'DOCUMENT_ALREADY_FINALIZED' &&
          job.entityType == 'sales_documents' &&
          job.entityId != null) {
        await salesRecovery.reconcileFinalizeConflict(job.entityId!);
      }
      if (code == 'DOCUMENT_ALREADY_FINALIZED' &&
          job.entityType == 'purchase_documents' &&
          job.entityId != null) {
        await purchaseRecovery.reconcileFinalizeConflict(job.entityId!);
      }
    },
  );
});

final commandAwareSyncEngineProvider =
    FutureProvider<CommandAwareSyncEngine>((ref) async {
  final engine = await ref.watch(syncEngineProvider.future);
  final commandRunner = await ref.watch(commandSyncRunnerProvider.future);
  return CommandAwareSyncEngine(
    engine: engine,
    commandRunner: commandRunner,
  );
});
