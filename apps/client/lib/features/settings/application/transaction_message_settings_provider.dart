import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/settings/application/settings_save_feedback.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/features/settings/models/transaction_message_settings.dart';
import 'package:billing_baba/features/settings/repositories/transaction_message_settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_message_settings_provider.g.dart';

@Riverpod(keepAlive: true)
Future<TransactionMessageSettingsRepository>
transactionMessageSettingsRepository(Ref ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  return TransactionMessageSettingsRepository(storage, businessId);
}

@Riverpod(keepAlive: true)
class TransactionMessageSettingsNotifier
    extends _$TransactionMessageSettingsNotifier {
  @override
  Future<TransactionMessageSettings> build() async {
    final businessId = ref.watch(currentBusinessProvider)?.id ?? '';

    // Prefer sync path when SharedPreferences is already initialized.
    final storageReady = ref.watch(storageServiceProvider).asData?.value;
    if (storageReady != null) {
      return TransactionMessageSettingsRepository(
        storageReady,
        businessId,
      ).load();
    }

    final repository = await ref.watch(
      transactionMessageSettingsRepositoryProvider.future,
    );
    return repository.load();
  }

  Future<void> save(TransactionMessageSettings settings) async {
    final repository = await ref.read(
      transactionMessageSettingsRepositoryProvider.future,
    );
    await repository.save(settings);
    state = AsyncData(settings);
    notifySettingsSaved(ref, message: SettingsSaveMessages.transactionMessages);
  }
}
