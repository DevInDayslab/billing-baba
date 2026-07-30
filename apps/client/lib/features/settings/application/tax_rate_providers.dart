import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/settings/data/tax_rate_local_source.dart';
import 'package:billing_baba/features/settings/data/tax_rate_master_repository.dart';
import 'package:billing_baba/features/settings/models/tax_rate_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_rate_providers.g.dart';

final taxRateMasterRepositoryProvider =
    FutureProvider<TaxRateMasterRepository>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final db = ref.watch(appDatabaseProvider);
  final queue = ref.watch(syncQueueProvider);
  String? deviceId;
  try {
    final identity = await ref.watch(syncDeviceIdentityProvider.future);
    deviceId = await identity.deviceId();
  } on Object {
    deviceId = null;
  }
  return TaxRateMasterRepository(
    local: TaxRateLocalSource(db),
    syncQueue: queue,
    businessIdReader: () => storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
    deviceIdReader: () => deviceId,
  );
});

@Riverpod(keepAlive: true)
class TaxRates extends _$TaxRates {
  @override
  Future<List<TaxRateDto>> build() async {
    final repository = await ref.watch(taxRateMasterRepositoryProvider.future);
    return repository.listActive();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository =
          await ref.read(taxRateMasterRepositoryProvider.future);
      return repository.listActive();
    });
  }
}
