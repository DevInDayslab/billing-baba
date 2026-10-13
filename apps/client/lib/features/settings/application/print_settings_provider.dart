import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/settings/application/settings_save_feedback.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/features/settings/repositories/print_settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_settings_provider.g.dart';

@Riverpod(keepAlive: true)
Future<PrintSettingsRepository> printSettingsRepository(Ref ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  return PrintSettingsRepository(storage, businessId);
}

@Riverpod(keepAlive: true)
class PrintSettingsNotifier extends _$PrintSettingsNotifier {
  @override
  Future<PrintSettings> build() async {
    final businessId = ref.watch(currentBusinessProvider)?.id ?? '';

    // Prefer sync path when SharedPreferences is already initialized.
    final storageReady = ref.watch(storageServiceProvider).asData?.value;
    if (storageReady != null) {
      return PrintSettingsRepository(storageReady, businessId).load();
    }

    final repository = await ref.watch(printSettingsRepositoryProvider.future);
    return repository.load();
  }

  Future<void> save(PrintSettings settings) async {
    final repository = await ref.read(printSettingsRepositoryProvider.future);
    await repository.save(settings);
    state = AsyncData(settings);
    notifySettingsSaved(message: SettingsSaveMessages.print);
  }

  Future<void> updateField(
    PrintSettings Function(PrintSettings) updater,
  ) async {
    final current = state;
    if (!current.hasValue) return;
    await save(updater(current.requireValue));
  }
}
