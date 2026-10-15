import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/settings/application/settings_save_feedback.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/features/settings/models/whatsapp_settings.dart';
import 'package:billing_baba/features/settings/repositories/whatsapp_settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'whatsapp_settings_provider.g.dart';

@Riverpod(keepAlive: true)
Future<WhatsAppSettingsRepository> whatsappSettingsRepository(Ref ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  return WhatsAppSettingsRepository(storage, businessId);
}

@Riverpod(keepAlive: true)
class WhatsAppSettingsNotifier extends _$WhatsAppSettingsNotifier {
  @override
  Future<WhatsAppSettings> build() async {
    ref.watch(currentBusinessProvider);
    final repository = await ref.watch(
      whatsappSettingsRepositoryProvider.future,
    );
    return repository.load();
  }

  Future<void> save(WhatsAppSettings settings) async {
    final repository = await ref.read(
      whatsappSettingsRepositoryProvider.future,
    );
    await repository.save(settings);
    state = AsyncData(settings);
    notifySettingsSaved(message: SettingsSaveMessages.whatsApp);
  }
}
