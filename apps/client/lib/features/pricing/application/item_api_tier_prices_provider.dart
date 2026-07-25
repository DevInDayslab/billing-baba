import 'dart:async';

import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/tier_price_model.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cached API tier prices keyed by item id → tier key → price.
final itemApiTierPricesProvider =
    NotifierProvider<ItemApiTierPrices, Map<String, Map<String, double>>>(
      ItemApiTierPrices.new,
    );

class ItemApiTierPrices extends Notifier<Map<String, Map<String, double>>> {
  final Set<String> _loading = {};

  @override
  Map<String, Map<String, double>> build() => {};

  Future<void> preloadForItemIds(Iterable<String> itemIds) async {
    final pending = itemIds
        .where((id) => !state.containsKey(id) && !_loading.contains(id))
        .toList();
    if (pending.isEmpty) return;

    _loading.addAll(pending);
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final entries = await Future.wait(
        pending.map((itemId) => _loadItem(service, itemId)),
      );
      state = {
        ...state,
        for (final entry in entries) entry.key: entry.value,
      };
    } finally {
      for (final id in pending) {
        _loading.remove(id);
      }
    }
  }

  Future<MapEntry<String, Map<String, double>>> _loadItem(
    InventoryService service,
    String itemId,
  ) async {
    try {
      final tiers = await service.fetchItemTierPrices(itemId);
      return MapEntry(itemId, _toTierMap(tiers));
    } on Object {
      return MapEntry(itemId, const {});
    }
  }

  Map<String, double> _toTierMap(List<TierPriceModel> tiers) {
    return PriceTier.mapFromApiTierPrices(
      tiers.map((tier) => (pricingTier: tier.pricingTier, price: tier.price)),
    );
  }

  void removeItem(String itemId) {
    if (!state.containsKey(itemId)) return;
    final next = Map<String, Map<String, double>>.from(state);
    next.remove(itemId);
    state = next;
    _loading.remove(itemId);
  }

  Future<void> refreshItem(String itemId) async {
    removeItem(itemId);
    await preloadForItemIds([itemId]);
  }
}

Map<String, double> mergedTierPricesForItem({
  required Map<String, Map<String, double>> apiStore,
  required Map<String, Map<String, double>> localStore,
  required String itemId,
}) {
  return PriceTier.mergeTierPriceMaps(
    apiStore[itemId] ?? const {},
    localStore[itemId] ?? const {},
  );
}
