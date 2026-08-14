import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/engine/connectivity_monitor.dart';
import 'package:billing_baba/core/sync/engine/device_identity.dart';
import 'package:billing_baba/core/sync/engine/sync_coordinator.dart';
import 'package:billing_baba/core/sync/engine/sync_engine.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/engine/sync_scheduler.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/network/sync_api.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/crm/data/crm_sync.dart';
import 'package:billing_baba/features/inventory/data/brand_sync.dart';
import 'package:billing_baba/features/inventory/data/category_sync.dart';
import 'package:billing_baba/features/inventory/data/godown_sync.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_alternative_sync.dart';
import 'package:billing_baba/features/inventory/data/item_bom_sync.dart';
import 'package:billing_baba/features/inventory/data/item_supplier_sync.dart';
import 'package:billing_baba/features/inventory/data/item_tier_price_sync.dart';
import 'package:billing_baba/features/inventory/data/item_sync.dart';
import 'package:billing_baba/features/inventory/data/stock_level_sync.dart';
import 'package:billing_baba/features/inventory/data/unit_sync.dart';
import 'package:billing_baba/features/parties/data/party_sync.dart';
import 'package:billing_baba/features/purchases/data/expense_sync.dart';
import 'package:billing_baba/features/purchases/data/purchase_document_sync.dart';
import 'package:billing_baba/features/sales/data/sales_document_sync.dart';
import 'package:billing_baba/features/settings/data/business_settings_sync.dart';
import 'package:billing_baba/features/settings/data/tax_rate_sync.dart';
import 'package:billing_baba/features/tasks/data/todo_sync.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityMonitorProvider = Provider<ConnectivityMonitor>((ref) {
  final monitor = ConnectivityMonitor();
  ref.onDispose(monitor.dispose);
  return monitor;
});

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(ref.watch(appDatabaseProvider));
});

final syncPendingCountProvider = StreamProvider<int>((ref) {
  final storageAsync = ref.watch(storageServiceProvider);
  return storageAsync.when(
    data: (storage) {
      final businessId = storage.read(StorageKeys.lastOpenedBusinessId);
      return ref
          .watch(syncQueueProvider)
          .streamPendingCount(businessId: businessId);
    },
    loading: () => ref.watch(syncQueueProvider).streamPendingCount(),
    error: (_, _) => ref.watch(syncQueueProvider).streamPendingCount(),
  );
});

final syncPendingJobsProvider = StreamProvider<List<SyncJob>>((ref) {
  final storageAsync = ref.watch(storageServiceProvider);
  return storageAsync.when(
    data: (storage) {
      final businessId = storage.read(StorageKeys.lastOpenedBusinessId);
      return ref.watch(syncQueueProvider).watchPending(businessId: businessId);
    },
    loading: () => ref.watch(syncQueueProvider).watchPending(),
    error: (_, _) => ref.watch(syncQueueProvider).watchPending(),
  );
});

final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  final scheduler = SyncScheduler();
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

final syncApiProvider = FutureProvider<SyncApi>((ref) async {
  final apiClient = await ref.watch(apiClientProvider.future);
  return SyncApi(apiClient.dio);
});

final syncDeviceIdentityProvider = FutureProvider<SyncDeviceIdentity>((
  ref,
) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return SyncDeviceIdentity(storage);
});

final syncMetadataStoreProvider = FutureProvider<SyncMetadataStore>((
  ref,
) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return SyncMetadataStore(storage);
});

final syncCoordinatorProvider = FutureProvider<SyncCoordinator>((ref) async {
  final api = await ref.watch(syncApiProvider.future);
  final storage = await ref.watch(storageServiceProvider.future);
  final identity = await ref.watch(syncDeviceIdentityProvider.future);
  final metadata = await ref.watch(syncMetadataStoreProvider.future);
  final db = ref.watch(appDatabaseProvider);
  return SyncCoordinator(
    api: api,
    queue: ref.watch(syncQueueProvider),
    identity: identity,
    metadata: metadata,
    storage: storage,
    categorySync: CategorySync(db),
    brandSync: BrandSync(db),
    partySync: PartySync(db),
    itemSync: ItemSync(db),
    itemSupplierSync: ItemSupplierSync(db),
    itemBomMaterialSync: ItemBomMaterialSync(db),
    itemBomCostSync: ItemBomCostSync(db),
    itemAlternativeSync: ItemAlternativeSync(db),
    itemTierPriceSync: ItemTierPriceSync(db),
    unitSync: UnitSync(db),
    taxRateSync: TaxRateSync(db),
    godownSync: GodownSync(db),
    businessSettingsSync: BusinessSettingsSync(db),
    salesDocumentSync: SalesDocumentSync(db),
    purchaseDocumentSync: PurchaseDocumentSync(db),
    leadSync: LeadSync(db),
    leadActivitySync: LeadActivitySync(db),
    contactSync: ContactSync(db),
    contactActivitySync: ContactActivitySync(db),
    dealSync: DealSync(db),
    expenseSync: ExpenseSync(db),
    expenseCategorySync: ExpenseCategorySync(db),
    stockLevelSync: StockLevelSync(
      InventoryStockLocalDataSource(db),
      metadata,
    ),
    todoSync: TodoSync(db),
  );
});

final syncEngineProvider = FutureProvider<SyncEngine>((ref) async {
  final coordinator = await ref.watch(syncCoordinatorProvider.future);
  final engine = SyncEngine(
    connectivityMonitor: ref.watch(connectivityMonitorProvider),
    scheduler: ref.watch(syncSchedulerProvider),
    coordinator: coordinator,
  );

  ref.onDispose(engine.dispose);

  return engine;
});

final syncStateProvider = StreamProvider<SyncState>((ref) async* {
  final engine = await ref.watch(syncEngineProvider.future);
  yield engine.state;
  yield* engine.stateChanges;
});

final connectivityStatusProvider = StreamProvider<SyncConnectivityStatus>((
  ref,
) async* {
  final monitor = ref.watch(connectivityMonitorProvider);
  yield monitor.status;
  yield* monitor.onStatusChanged;
});
