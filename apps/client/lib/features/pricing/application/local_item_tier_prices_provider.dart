import 'dart:async';
import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local-only item tier prices keyed by item id → tier key → price.
///
/// Not synced to the API — used for frontend tier-based pricing demos.
final localItemTierPricesProvider =
    NotifierProvider<LocalItemTierPrices, Map<String, Map<String, double>>>(
      LocalItemTierPrices.new,
    );

class LocalItemTierPrices extends Notifier<Map<String, Map<String, double>>> {
  Future<void>? _initialization;

  @override
  Map<String, Map<String, double>> build() {
    _initialization = _loadFromStorage();
    return {};
  }

  /// Awaits the first load from local storage before reading tier prices.
  Future<void> ensureInitialized() => _initialization ??= _loadFromStorage();

  Future<void> _loadFromStorage() async {
    final storage = await ref.read(storageServiceProvider.future);
    final businessId = storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) return;
    final raw = storage.read('${StorageKeys.localItemTierPrices}_$businessId');
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final loaded = decoded.map(
        (itemId, tiers) => MapEntry(
          itemId as String,
          (tiers as Map).map(
            (tier, price) => MapEntry(
              tier as String,
              (price as num).toDouble(),
            ),
          ),
        ),
      );
      state = loaded;
    } on Object catch (_) {
      // Ignore corrupt cache.
    }
  }

  Future<void> _persist() async {
    final storage = await ref.read(storageServiceProvider.future);
    final businessId = storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) return;
    await storage.write(
      '${StorageKeys.localItemTierPrices}_$businessId',
      jsonEncode(state),
    );
  }

  Map<String, double> tierPricesFor(String itemId) => state[itemId] ?? const {};

  void setTierPrices(String itemId, Map<String, double> tierPrices) {
    final cleaned = {
      for (final entry in tierPrices.entries)
        if (entry.value > 0) entry.key: entry.value,
    };

    if (cleaned.isEmpty) {
      if (!state.containsKey(itemId)) return;
      final next = Map<String, Map<String, double>>.from(state)..remove(itemId);
      state = next;
    } else {
      state = {...state, itemId: cleaned};
    }
    unawaited(_persist());
  }

  void removeItem(String itemId) {
    if (!state.containsKey(itemId)) return;
    final next = Map<String, Map<String, double>>.from(state)..remove(itemId);
    state = next;
    unawaited(_persist());
  }
}
