import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/models/item_settings_state.dart';
import 'package:billing_baba/features/inventory/repositories/item_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ItemSettingsUpdater = ItemSettingsState Function(
  ItemSettingsState settings,
);

final itemSettingsRepositoryProvider =
    FutureProvider<ItemSettingsRepository>((ref) async {
      final storage = await ref.watch(storageServiceProvider.future);
      final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
      return ItemSettingsRepository(storage, businessId);
    });

final itemSettingsProvider =
    AsyncNotifierProvider<ItemSettingsNotifier, ItemSettingsState>(
      ItemSettingsNotifier.new,
    );

class ItemSettingsNotifier extends AsyncNotifier<ItemSettingsState> {
  @override
  Future<ItemSettingsState> build() async {
    ref.listen(currentBusinessProvider, (_, _) {
      ref.invalidateSelf();
    });
    final repository = await ref.watch(itemSettingsRepositoryProvider.future);
    return repository.load();
  }

  Future<void> updateSettings(ItemSettingsUpdater updater) async {
    final current = state;
    if (!current.hasValue) return;

    final next = updater(current.requireValue);
    state = AsyncData(next);

    final repository = await ref.read(itemSettingsRepositoryProvider.future);
    await repository.save(next);
  }
}
