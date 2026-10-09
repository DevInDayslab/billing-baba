import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/settings/application/settings_save_feedback.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/features/settings/models/accounting_settings.dart';
import 'package:billing_baba/features/settings/repositories/accounting_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountingSettingsRepositoryProvider =
    FutureProvider<AccountingSettingsRepository>((ref) async {
      final storage = await ref.watch(storageServiceProvider.future);
      final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
      return AccountingSettingsRepository(storage, businessId);
    });

final accountingSettingsProvider =
    AsyncNotifierProvider<AccountingSettingsNotifier, AccountingSettings>(
      AccountingSettingsNotifier.new,
    );

final accountingModuleEnabledProvider = Provider<bool>((ref) {
  return ref
          .watch(accountingSettingsProvider)
          .value
          ?.enableAccountingModule ??
      false;
});

final journalEntriesEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(accountingSettingsProvider).value;
  if (settings == null || !settings.enableAccountingModule) {
    return false;
  }
  return settings.allowJournalEntries;
});

class AccountingSettingsNotifier extends AsyncNotifier<AccountingSettings> {
  @override
  Future<AccountingSettings> build() async {
    ref.watch(currentBusinessProvider);
    final repo = await ref.watch(accountingSettingsRepositoryProvider.future);
    return repo.load();
  }

  Future<void> patch(AccountingSettingsUpdater update) async {
    final current = state.requireValue;
    final next = update(current);
    final repo = await ref.read(accountingSettingsRepositoryProvider.future);
    await repo.save(next);
    state = AsyncData(next);
    notifySettingsSaved(ref, message: SettingsSaveMessages.accounting);
  }
}
