import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_alternatives_index_provider.g.dart';

@Riverpod(keepAlive: true)
class ItemAlternativesIndex extends _$ItemAlternativesIndex {
  @override
  Future<Map<String, List<String>>> build() async {
    final service = await ref.watch(inventoryServiceProvider.future);
    return service.fetchAlternativesIndex();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(inventoryServiceProvider.future);
      return service.fetchAlternativesIndex();
    });
  }
}
