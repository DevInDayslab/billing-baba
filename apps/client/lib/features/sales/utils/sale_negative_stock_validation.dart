import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/settings/application/general_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// When [stopSaleOnNegativeStock] is on, blocks sale if any tracked line exceeds stock.
String? validateSaleLinesForNegativeStock(Ref ref, List<SaleLineItem> items) {
  if (!ref.read(stopSaleOnNegativeStockProvider)) {
    return null;
  }

  final itemSettings = ref.read(itemSettingsProvider).asData?.value;
  if (itemSettings != null && !itemSettings.stockMaintenance) {
    return null;
  }

  final inventory = ref.read(inventoryItemListProvider);
  final byId = {for (final item in inventory) item.id: item};

  for (final line in items) {
    if (line.qty <= 0) continue;
    final itemId = line.itemId?.trim();
    if (itemId == null || itemId.isEmpty) continue;

    final item = byId[itemId];
    if (item == null || item.type == ItemType.service) continue;

    final available = item.availableForSale ?? item.quantity;
    if (available == null) continue;

    if (line.qty > available) {
      final name = line.itemName.trim().isNotEmpty ? line.itemName : item.name;
      return 'Cannot sell $name: only ${available.toStringAsFixed(available == available.roundToDouble() ? 0 : 2)} in stock (sale would go negative).';
    }
  }

  return null;
}
