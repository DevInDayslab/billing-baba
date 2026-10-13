import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/settings/application/settings_save_feedback.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/features/inventory/application/item_settings_guard.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/repositories/item_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_settings_provider.g.dart';

/// Item Settings → Quantity (upto decimal places).
final itemQuantityDecimalPlacesProvider = Provider<int>((ref) {
  final settings = ref.watch(itemSettingsProvider).value;
  return settings?.quantityDecimalPlaces ??
      ItemSettings.defaults().quantityDecimalPlaces;
});

@Riverpod(keepAlive: true)
Future<ItemSettingsRepository> itemSettingsRepository(Ref ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  return ItemSettingsRepository(storage, businessId);
}

@Riverpod(keepAlive: true)
class ItemSettingsNotifier extends _$ItemSettingsNotifier {
  @override
  Future<ItemSettings> build() async {
    ref.watch(currentBusinessProvider);
    final repository = await ref.watch(itemSettingsRepositoryProvider.future);
    return repository.load();
  }

  Future<void> save(ItemSettings settings, {bool silent = false}) async {
    final current = state.value ?? await future;
    final restriction = await ref
        .read(itemSettingsGuardProvider)
        .restrictionForPatch(current, settings);
    if (restriction != null) {
      notifySettingsBlocked(ref, message: restriction.message);
      return;
    }

    final repository = await ref.read(itemSettingsRepositoryProvider.future);
    await repository.save(settings);
    state = AsyncData(settings);
    if (!silent) {
      notifySettingsSaved(ref, message: SettingsSaveMessages.item);
    }
  }

  Future<void> patch(ItemSettingsUpdater update) async {
    final current = state.value ?? await future;
    await save(update(current));
  }
}
