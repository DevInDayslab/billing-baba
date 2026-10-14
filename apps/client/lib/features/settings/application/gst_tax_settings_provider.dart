import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/settings/application/settings_save_feedback.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/features/settings/models/gst_tax_settings.dart';
import 'package:billing_baba/features/settings/models/gst_tax_settings_behavior.dart';
import 'package:billing_baba/features/settings/repositories/gst_tax_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gstTaxSettingsRepositoryProvider =
    FutureProvider<GstTaxSettingsRepository>((ref) async {
      final storage = await ref.watch(storageServiceProvider.future);
      final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
      return GstTaxSettingsRepository(storage, businessId);
    });

final gstTaxSettingsProvider =
    AsyncNotifierProvider<GstTaxSettingsNotifier, GstTaxSettings>(
      GstTaxSettingsNotifier.new,
    );

final effectiveGstTaxSettingsProvider = Provider<GstTaxSettings>((ref) {
  return ref.watch(gstTaxSettingsProvider).value ?? GstTaxSettings.defaults();
});

final gstEnabledProvider = Provider<bool>((ref) {
  return ref.watch(effectiveGstTaxSettingsProvider).enableGst;
});

final gstAllowsTransactionTaxesProvider = Provider<bool>((ref) {
  return ref.watch(effectiveGstTaxSettingsProvider).allowsTransactionTaxes;
});

final gstPlaceOfSupplyEnabledProvider = Provider<bool>((ref) {
  return ref.watch(effectiveGstTaxSettingsProvider).showPlaceOfSupplyOnTransactions;
});

final gstReverseChargeFeatureEnabledProvider = Provider<bool>((ref) {
  return ref.watch(effectiveGstTaxSettingsProvider).reverseChargeFeatureEnabled;
});

final gstFormalDocumentProvider = Provider<bool>((ref) {
  return ref.watch(effectiveGstTaxSettingsProvider).isGstFormalDocument;
});

class GstTaxSettingsNotifier extends AsyncNotifier<GstTaxSettings> {
  @override
  Future<GstTaxSettings> build() async {
    ref.watch(currentBusinessProvider);
    final repo = await ref.watch(gstTaxSettingsRepositoryProvider.future);
    return repo.load();
  }

  Future<void> patch(
    GstTaxSettings Function(GstTaxSettings current) update,
  ) async {
    final next = update(state.requireValue);
    final repo = await ref.read(gstTaxSettingsRepositoryProvider.future);
    await repo.save(next);
    state = AsyncData(next);
    await _syncRelated(next);
    notifySettingsSaved(ref, message: SettingsSaveMessages.taxesGst);
  }

  Future<void> _syncRelated(GstTaxSettings settings) async {
    final items = await ref.read(itemSettingsProvider.future);
    var nextItems = items;
    var itemSettingsChanged = false;
    if (items.hsnSacCode != settings.showHsnSacOnItems) {
      nextItems = nextItems.copyWith(hsnSacCode: settings.showHsnSacOnItems);
      itemSettingsChanged = true;
    }
    if (items.additionalCess != settings.showAdditionalCessOnItems) {
      nextItems = nextItems.copyWith(
        additionalCess: settings.showAdditionalCessOnItems,
      );
      itemSettingsChanged = true;
    }
    if (itemSettingsChanged) {
      await ref
          .read(itemSettingsProvider.notifier)
          .save(nextItems, silent: true);
    }

    await ref.read(saleInvoiceSettingsProvider.notifier).updateSettings(
      (sale) => sale.copyWith(reverseCharge: settings.reverseCharge),
      silent: true,
    );
  }
}
