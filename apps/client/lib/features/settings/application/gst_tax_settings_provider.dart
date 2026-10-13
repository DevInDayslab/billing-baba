import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/settings/application/settings_save_feedback.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/features/settings/models/gst_tax_settings.dart';
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

final gstEnabledProvider = Provider<bool>((ref) {
  return ref.watch(gstTaxSettingsProvider).value?.enableGst ?? true;
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
    notifySettingsSaved(message: SettingsSaveMessages.taxesGst);
  }

  Future<void> _syncRelated(GstTaxSettings settings) async {
    final items = await ref.read(itemSettingsProvider.future);
    if (items.hsnSacCode != settings.enableHsnSac) {
      await ref
          .read(itemSettingsProvider.notifier)
          .save(
            items.copyWith(hsnSacCode: settings.enableHsnSac),
            silent: true,
          );
    }

    await ref.read(saleInvoiceSettingsProvider.notifier).updateSettings(
      (sale) => sale.copyWith(reverseCharge: settings.reverseCharge),
      silent: true,
    );
  }
}
