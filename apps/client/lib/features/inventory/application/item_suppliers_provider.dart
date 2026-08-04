import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_suppliers_provider.g.dart';

@Riverpod(keepAlive: true)
class ItemSuppliers extends _$ItemSuppliers {
  @override
  Future<Map<String, List<String>>> build() async {
    final service = await ref.watch(inventoryServiceProvider.future);
    return service.fetchItemSuppliersMap();
  }

  Future<void> ensureInitialized() async {
    await future;
  }

  List<String> suppliersFor(String itemId) {
    return state.value?[itemId] ?? const [];
  }

  Future<void> setSuppliers(
    String itemId,
    List<String> partyIds, {
    String? defaultPartyId,
  }) async {
    final service = await ref.read(inventoryServiceProvider.future);
    await service.replaceItemSuppliers(
      itemId,
      partyIds,
      defaultPartyId: defaultPartyId,
    );
    final current = Map<String, List<String>>.from(state.value ?? {});
    final cleaned = partyIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();
    if (cleaned.isEmpty) {
      current.remove(itemId);
    } else {
      current[itemId] = cleaned;
    }
    state = AsyncData(current);
  }

  Future<void> removeItem(String itemId) async {
    final service = await ref.read(inventoryServiceProvider.future);
    await service.removeItemSuppliers(itemId);
    final current = Map<String, List<String>>.from(state.value ?? {});
    if (current.remove(itemId) != null) {
      state = AsyncData(current);
    }
  }
}
