import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/settings/application/settings_save_feedback.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/features/settings/models/desktop_ui_scale.dart';
import 'package:billing_baba/features/settings/models/general_settings.dart';
import 'package:billing_baba/features/settings/repositories/general_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final generalSettingsRepositoryProvider =
    FutureProvider<GeneralSettingsRepository>((ref) async {
      final storage = await ref.watch(storageServiceProvider.future);
      final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
      return GeneralSettingsRepository(storage, businessId);
    });

final generalSettingsProvider =
    AsyncNotifierProvider<GeneralSettingsNotifier, GeneralSettings>(
      GeneralSettingsNotifier.new,
    );

final lastLocalBackupAtProvider = FutureProvider<DateTime?>((ref) async {
  ref.watch(currentBusinessProvider);
  final repo = await ref.watch(generalSettingsRepositoryProvider.future);
  return repo.readLastBackupAt();
});

final amountDecimalPlacesProvider = Provider<int>((ref) {
  return ref.watch(generalSettingsProvider).value?.amountDecimalPlaces ?? 0;
});

GeneralSettings _generalSettingsOrDefaults(Ref ref) {
  return ref.watch(generalSettingsProvider).value ?? GeneralSettings.defaults();
}

final deliveryChallanPrintAmountEnabledProvider = Provider<bool>((ref) {
  return _generalSettingsOrDefaults(ref).deliveryChallanPrintAmountEnabled;
});

final deliveryChallanGoodsReturnEnabledProvider = Provider<bool>((ref) {
  return _generalSettingsOrDefaults(ref).deliveryChallanGoodsReturnEnabled;
});

final blockNewPartiesFromTxnProvider = Provider<bool>((ref) {
  return ref
          .watch(generalSettingsProvider)
          .value
          ?.blockNewPartiesFromTxnForm ??
      false;
});

final blockNewItemsFromTxnProvider = Provider<bool>((ref) {
  return ref.watch(generalSettingsProvider).value?.blockNewItemsFromTxnForm ??
      false;
});

final stopSaleOnNegativeStockProvider = Provider<bool>((ref) {
  return ref.watch(generalSettingsProvider).value?.stopSaleOnNegativeStock ??
      true;
});

final enableGstinOnPartyProvider = Provider<bool>((ref) {
  return ref.watch(generalSettingsProvider).value?.enableGstinOnParty ?? true;
});

final desktopUiScaleProvider = Provider<double>((ref) {
  final percent =
      ref.watch(generalSettingsProvider).value?.desktopUiScalePercent ?? 100;
  return DesktopUiScale.scaleFactorForPercent(percent);
});

class GeneralSettingsNotifier extends AsyncNotifier<GeneralSettings> {
  @override
  Future<GeneralSettings> build() async {
    ref.watch(currentBusinessProvider);
    final repo = await ref.watch(generalSettingsRepositoryProvider.future);
    final loaded = await repo.load();
    final normalized = loaded.copyWith(
      desktopUiScalePercent: DesktopUiScale.normalizePercent(
        loaded.desktopUiScalePercent,
      ),
    );
    final businessId = ref.read(currentBusinessProvider)?.id ?? '';
    if (normalized.selectedFirmBusinessId.isEmpty && businessId.isNotEmpty) {
      return normalized.copyWith(selectedFirmBusinessId: businessId);
    }
    return normalized;
  }

  Future<void> patch(
    GeneralSettingsUpdater update, {
    bool silent = false,
  }) async {
    final current = state.requireValue;
    final next = update(current);
    final repo = await ref.read(generalSettingsRepositoryProvider.future);
    await repo.save(next);
    state = AsyncData(next);
    if (!silent) {
      notifySettingsSaved(message: SettingsSaveMessages.general);
    }
  }

  Future<void> setGodownStockTransferEnabled(bool enabled) async {
    await patch((s) => s.copyWith(godownStockTransferEnabled: enabled));
    if (!enabled) return;
    final itemSettings = await ref.read(itemSettingsProvider.future);
    if (!itemSettings.stockMaintenance) {
      await ref.read(itemSettingsProvider.notifier).save(
        itemSettings.copyWith(stockMaintenance: true),
        silent: true,
      );
    }
  }

  Future<void> recordLocalBackupNow() async {
    final repo = await ref.read(generalSettingsRepositoryProvider.future);
    await repo.recordLastBackupAt(DateTime.now());
    ref.invalidate(lastLocalBackupAtProvider);
  }
}
