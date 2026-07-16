import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/features/settings/repositories/print_settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_settings_provider.g.dart';

@Riverpod(keepAlive: true)
Future<PrintSettingsRepository> printSettingsRepository(Ref ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return PrintSettingsRepository(storage);
}

@Riverpod(keepAlive: true)
class PrintSettingsNotifier extends _$PrintSettingsNotifier {
  @override
  Future<PrintSettings> build() async {
    final repository = await ref.watch(printSettingsRepositoryProvider.future);
    return repository.load();
  }

  Future<void> save(PrintSettings settings) async {
    final repository = await ref.read(printSettingsRepositoryProvider.future);
    await repository.save(settings);
    state = AsyncData(settings);
  }

  Future<void> updateField(PrintSettings Function(PrintSettings) updater) async {
    final current = state;
    if (!current.hasValue) return;
    await save(updater(current.requireValue));
  }
}
