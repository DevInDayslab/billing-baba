import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/settings/application/settings_save_feedback.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_settings.dart';
import 'package:billing_baba/features/sales/repositories/sale_invoice_settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_invoice_settings_provider.g.dart';

typedef SaleInvoiceSettingsUpdater =
    SaleInvoiceSettings Function(
      SaleInvoiceSettings settings,
    );

@Riverpod(keepAlive: true)
Future<SaleInvoiceSettingsRepository> saleInvoiceSettingsRepository(
  Ref ref,
) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  return SaleInvoiceSettingsRepository(storage, businessId);
}

@Riverpod(keepAlive: true)
class SaleInvoiceSettingsNotifier extends _$SaleInvoiceSettingsNotifier {
  @override
  Future<SaleInvoiceSettings> build() async {
    final firmId = ref.watch(currentBusinessProvider)?.id;
    ref.listen(currentBusinessProvider, (_, _) {
      ref.invalidateSelf();
    });
    final repository = await ref.watch(
      saleInvoiceSettingsRepositoryProvider.future,
    );
    return repository.load(firmId: firmId);
  }

  Future<void> updateSettings(
    SaleInvoiceSettingsUpdater updater, {
    bool silent = true,
  }) async {
    final current = state;
    if (!current.hasValue) return;

    final next = updater(current.requireValue);
    state = AsyncData(next);

    final repository = await ref.read(
      saleInvoiceSettingsRepositoryProvider.future,
    );
    await repository.save(next);
    if (!silent) {
      notifySettingsSaved(message: SettingsSaveMessages.transaction);
    }
  }
}
