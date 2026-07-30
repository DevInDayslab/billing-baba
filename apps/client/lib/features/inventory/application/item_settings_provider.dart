import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/repositories/item_settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_settings_provider.g.dart';

@Riverpod(keepAlive: true)
Future<ItemSettingsRepository> itemSettingsRepository(Ref ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  return ItemSettingsRepository(storage, businessId);
}

@Riverpod(keepAlive: true)
class ItemSettingsNotifier extends _$ItemSettingsNotifier {
  @override
  Future<ItemSettings> build() async {
    ref.watch(currentBusinessProvider);
    final repository = await ref.watch(itemSettingsRepositoryProvider.future);
    return repository.load();
  }

  Future<void> save(ItemSettings settings) async {
    final repository = await ref.read(itemSettingsRepositoryProvider.future);
    await repository.save(settings);
    state = AsyncData(settings);
  }
}
