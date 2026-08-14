import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/data/brand_local_source.dart';
import 'package:billing_baba/features/inventory/data/category_local_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_alternative_local_source.dart';
import 'package:billing_baba/features/inventory/data/item_alternative_master_repository.dart';
import 'package:billing_baba/features/inventory/data/item_alternatives_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_alternatives_repository.dart';
import 'package:billing_baba/features/inventory/data/item_local_source.dart';
import 'package:billing_baba/features/inventory/data/models/item_alternative_dto.dart';
import 'package:billing_baba/features/inventory/data/models/item_recommendations_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_alternatives_provider.g.dart';

@Riverpod(keepAlive: true)
Future<ItemAlternativesRepository> itemAlternativesRepository(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final storage = await ref.watch(storageServiceProvider.future);
  final db = ref.watch(appDatabaseProvider);
  final queue = ref.watch(syncQueueProvider);
  final currentBusiness = ref.watch(currentBusinessProvider);

  String? deviceId;
  try {
    final identity = await ref.watch(syncDeviceIdentityProvider.future);
    deviceId = await identity.deviceId();
  } on Object {
    deviceId = null;
  }

  String businessIdReader() {
    final fromProfile =
        currentBusiness?.id.trim() ??
        ref.read(currentBusinessProvider)?.id.trim() ??
        '';
    if (fromProfile.isNotEmpty) return fromProfile;
    return storage.read(StorageKeys.lastOpenedBusinessId)?.trim() ?? '';
  }

  final remote = ItemAlternativesRemoteDataSource(api.dio);
  final master = ItemAlternativeMasterRepository(
    local: ItemAlternativeLocalSource(db),
    syncQueue: queue,
    remote: remote,
    items: ItemLocalSource(db),
    brands: BrandLocalSource(db),
    categories: CategoryLocalSource(db),
    stockLocal: InventoryStockLocalDataSource(db),
    businessIdReader: businessIdReader,
    deviceIdReader: () => deviceId,
  );

  return ItemAlternativesRepository(master: master, remote: remote);
}

@riverpod
class ItemAlternativesNotifier extends _$ItemAlternativesNotifier {
  @override
  Future<List<ItemAlternativeDto>> build(String itemId) async {
    final repository = await ref.watch(
      itemAlternativesRepositoryProvider.future,
    );
    return repository.listAlternatives(itemId);
  }

  Future<void> addAlternative(String alternativeItemId) async {
    try {
      final repository = await ref.read(
        itemAlternativesRepositoryProvider.future,
      );
      await repository.addAlternative(itemId, alternativeItemId);
      ref.invalidateSelf();
    } on InventoryOfflineException {
      rethrow;
    } on InventoryException {
      rethrow;
    }
  }

  Future<void> removeAlternative(String alternativeItemId) async {
    try {
      final repository = await ref.read(
        itemAlternativesRepositoryProvider.future,
      );
      await repository.removeAlternative(itemId, alternativeItemId);
      ref.invalidateSelf();
    } on InventoryOfflineException {
      rethrow;
    } on InventoryException {
      rethrow;
    }
  }

  Future<void> reorder(List<String> orderedIds) async {
    try {
      final repository = await ref.read(
        itemAlternativesRepositoryProvider.future,
      );
      await repository.reorderAlternatives(itemId, orderedIds);
      ref.invalidateSelf();
    } on InventoryOfflineException {
      rethrow;
    } on InventoryException {
      rethrow;
    }
  }
}

@riverpod
Future<ItemRecommendationsDto> itemRecommendations(
  Ref ref,
  String itemId,
) async {
  final repository = await ref.watch(itemAlternativesRepositoryProvider.future);
  return repository.fetchRecommendations(itemId);
}
