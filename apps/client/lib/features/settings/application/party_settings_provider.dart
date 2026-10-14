import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/settings/application/settings_save_feedback.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/features/settings/models/party_settings.dart';
import 'package:billing_baba/features/settings/repositories/party_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final partySettingsRepositoryProvider =
    FutureProvider<PartySettingsRepository>((ref) async {
      final storage = await ref.watch(storageServiceProvider.future);
      final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
      return PartySettingsRepository(storage, businessId);
    });

final partySettingsProvider =
    AsyncNotifierProvider<PartySettingsNotifier, PartySettings>(
      PartySettingsNotifier.new,
    );

final partyGroupingEnabledProvider = Provider<bool>((ref) {
  return ref.watch(partySettingsProvider).value?.partyGroupingEnabled ?? true;
});

final partyShippingAddressEnabledProvider = Provider<bool>((ref) {
  return ref.watch(partySettingsProvider).value?.shippingAddressEnabled ?? true;
});

final partyPrintShippingAddressEnabledProvider = Provider<bool>((ref) {
  return ref
          .watch(partySettingsProvider)
          .value
          ?.printShippingAddressEnabled ??
      true;
});

final partyManageStatusEnabledProvider = Provider<bool>((ref) {
  return ref.watch(partySettingsProvider).value?.managePartyStatusEnabled ??
      true;
});

final partyLoyaltyPointsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(partySettingsProvider).value?.loyaltyPointsEnabled ?? false;
});

class PartySettingsNotifier extends AsyncNotifier<PartySettings> {
  @override
  Future<PartySettings> build() async {
    ref.watch(currentBusinessProvider);
    final repo = await ref.watch(partySettingsRepositoryProvider.future);
    return repo.load();
  }

  Future<void> patch(PartySettingsUpdater update) async {
    final current = state.requireValue;
    final next = update(current);
    final repo = await ref.read(partySettingsRepositoryProvider.future);
    await repo.save(next);
    state = AsyncData(next);
    notifySettingsSaved(message: SettingsSaveMessages.party);
  }
}
