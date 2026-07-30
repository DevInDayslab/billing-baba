import 'dart:async';
import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local-only item ↔ supplier party links keyed by item id → party ids.
///
/// Not synced to the API — used until a server-side item suppliers API exists.
final localItemSuppliersProvider =
    NotifierProvider<LocalItemSuppliers, Map<String, List<String>>>(
      LocalItemSuppliers.new,
    );

class LocalItemSuppliers extends Notifier<Map<String, List<String>>> {
  Future<void>? _initialization;

  @override
  Map<String, List<String>> build() {
    _initialization = _loadFromStorage();
    return {};
  }

  /// Awaits the first load from local storage before reading suppliers.
  Future<void> ensureInitialized() => _initialization ??= _loadFromStorage();

  Future<void> _loadFromStorage() async {
    final storage = await ref.read(storageServiceProvider.future);
    final businessId = storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) return;
    final raw = storage.read('${StorageKeys.localItemSuppliers}_$businessId');
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final loaded = <String, List<String>>{};
      for (final entry in decoded.entries) {
        final itemId = entry.key;
        final value = entry.value;
        if (itemId is! String || value is! List) continue;
        loaded[itemId] = value.whereType<String>().toList();
      }
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
      '${StorageKeys.localItemSuppliers}_$businessId',
      jsonEncode(state),
    );
  }

  List<String> suppliersFor(String itemId) => state[itemId] ?? const [];

  void setSuppliers(String itemId, List<String> partyIds) {
    final cleaned = partyIds.where((id) => id.trim().isNotEmpty).toList();
    if (cleaned.isEmpty) {
      if (!state.containsKey(itemId)) return;
      final next = Map<String, List<String>>.from(state)..remove(itemId);
      state = next;
    } else {
      state = {...state, itemId: cleaned};
    }
    unawaited(_persist());
  }

  void removeItem(String itemId) {
    if (!state.containsKey(itemId)) return;
    final next = Map<String, List<String>>.from(state)..remove(itemId);
    state = next;
    unawaited(_persist());
  }
}
