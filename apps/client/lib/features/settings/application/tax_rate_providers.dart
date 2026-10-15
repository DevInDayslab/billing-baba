import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/settings/data/tax_rate_local_source.dart';
import 'package:billing_baba/features/settings/data/tax_rate_master_repository.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/settings/application/settings_save_feedback.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/features/settings/models/gst_tax_catalog.dart';
import 'package:billing_baba/features/settings/models/tax_rate_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_rate_providers.g.dart';

final taxRateMasterRepositoryProvider = FutureProvider<TaxRateMasterRepository>(
  (ref) async {
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
      businessIdReader: () =>
          storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
      deviceIdReader: () => deviceId,
    );
  },
);

@Riverpod(keepAlive: true)
class TaxRates extends _$TaxRates {
  @override
  Future<List<TaxRateDto>> build() async {
    final repository = await ref.watch(taxRateMasterRepositoryProvider.future);
    final storage = await ref.watch(storageServiceProvider.future);
    final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
    final seededKey = '${StorageKeys.gstTaxCatalogSeeded}_$businessId';
    var rates = await repository.listActive();
    if (rates.isEmpty &&
        businessId.isNotEmpty &&
        storage.read(seededKey) != '1') {
      for (final request in defaultGstTaxRateCreates()) {
        await repository.create(request);
      }
      await storage.write(seededKey, '1');
      rates = await repository.listActive();
    }
    return rates;
  }

  Future<void> updateRate(String id, UpdateTaxRateRequest request) async {
    final repository = await ref.read(taxRateMasterRepositoryProvider.future);
    await repository.update(id, request);
    ref.invalidateSelf();
    notifySettingsSaved(message: SettingsSaveMessages.taxRates);
  }

  Future<void> deleteRate(String id) async {
    final repository = await ref.read(taxRateMasterRepositoryProvider.future);
    await repository.softDelete(id);
    ref.invalidateSelf();
    notifySettingsSaved(message: SettingsSaveMessages.taxRates);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(taxRateMasterRepositoryProvider.future);
      return repository.listActive();
    });
  }
}
