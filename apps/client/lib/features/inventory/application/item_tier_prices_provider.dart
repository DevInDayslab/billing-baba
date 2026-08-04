import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_tier_prices_provider.g.dart';

@Riverpod(keepAlive: true)
class ItemTierPrices extends _$ItemTierPrices {
  @override
  Future<Map<String, Map<String, double>>> build() async {
    final service = await ref.watch(inventoryServiceProvider.future);
    return service.fetchItemTierPricesMap();
  }

  Future<void> ensureInitialized() async {
    await future;
  }

  Map<String, double> tierPricesFor(String itemId) {
    return state.value?[itemId] ?? const {};
  }

  Future<void> setTierPrices(String itemId, Map<String, double> tierPrices) async {
    final service = await ref.read(inventoryServiceProvider.future);
    await service.replaceItemTierPrices(itemId, tierPrices);
    final current = Map<String, Map<String, double>>.from(state.value ?? {});
    final cleaned = {
      for (final entry in tierPrices.entries)
        if (entry.value > 0) entry.key: entry.value,
    };
    if (cleaned.isEmpty) {
      current.remove(itemId);
    } else {
      current[itemId] = cleaned;
    }
    state = AsyncData(current);
  }

  Future<void> removeItem(String itemId) async {
    final service = await ref.read(inventoryServiceProvider.future);
    await service.removeItemTierPrices(itemId);
    final current = Map<String, Map<String, double>>.from(state.value ?? {});
    if (current.remove(itemId) != null) {
      state = AsyncData(current);
    }
  }
}
