import 'package:billing_baba/features/inventory/utils/item_tax_rate.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';

/// Applies catalog item defaults to an invoice line (price, unit, qty, tax).
SaleLineItem applyCatalogItemToLine(
  SaleLineItem line,
  SaleItemOption item, {
  String? partyPriceTier,
  bool resetQtyWhenEmpty = true,
  double? fallbackTaxPercent,
}) {
  final qty = resetQtyWhenEmpty && line.qty <= 0 ? 1.0 : line.qty;
  final price = resolveTierPrice(
    salePrice: item.salePrice,
    tierPrices: item.tierPrices,
    partyTier: partyPriceTier,
  );
  final taxPercent = item.defaultTaxPercent > 0
      ? item.defaultTaxPercent
      : (fallbackTaxPercent ?? line.taxPercent);
  return line.copyWith(
    itemId: item.id,
    itemName: item.name,
    pricePerUnit: price,
    catalogUnitPrice: price,
    priceManuallyOverridden: false,
    unit: saleItemDefaultUnit(item),
    qty: qty,
    taxPercent: taxPercent,
  );
}

bool isEmptySaleLineDraft(SaleLineItem line) =>
    line.itemName.trim().isEmpty && line.qty <= 0;

bool canClubSaleLineItem(SaleLineItem line) =>
    line.itemId != null &&
    line.serialNo.trim().isEmpty &&
    line.batchNo.trim().isEmpty;

void ensureTrailingEmptySaleLine(
  List<SaleLineItem> items,
  String Function() nextLineId,
) {
  if (items.isEmpty) {
    items.add(SaleLineItem.empty(id: nextLineId()));
    return;
  }
  final last = items.last;
  if (!isEmptySaleLineDraft(last)) {
    items.add(SaleLineItem.empty(id: nextLineId()));
  }
}

/// Selects a catalog item on [targetIndex], clubbing qty into an existing row
/// with the same [itemId] when allowed (POS-style).
List<SaleLineItem> selectCatalogItemOnSaleLines({
  required List<SaleLineItem> items,
  required int targetIndex,
  required SaleLineItem appliedLine,
  required String Function() nextLineId,
}) {
  if (targetIndex < 0 || targetIndex >= items.length) return items;

  final itemId = appliedLine.itemId;
  if (itemId == null) {
    final updated = [...items];
    updated[targetIndex] = appliedLine;
    ensureTrailingEmptySaleLine(updated, nextLineId);
    return updated;
  }

  var clubIndex = -1;
  for (var i = 0; i < items.length; i++) {
    if (i == targetIndex) continue;
    final line = items[i];
    if (line.itemId == itemId && canClubSaleLineItem(line)) {
      clubIndex = i;
      break;
    }
  }

  if (clubIndex < 0) {
    final updated = [...items];
    updated[targetIndex] = appliedLine;
    ensureTrailingEmptySaleLine(updated, nextLineId);
    return updated;
  }

  final qtyToAdd = appliedLine.qty > 0 ? appliedLine.qty : 1.0;
  final updated = [...items];
  updated[clubIndex] = updated[clubIndex].copyWith(
    qty: updated[clubIndex].qty + qtyToAdd,
  );

  final target = items[targetIndex];
  if (isEmptySaleLineDraft(target)) {
    updated.removeAt(targetIndex);
  } else {
    updated[targetIndex] = SaleLineItem.empty(id: target.id);
  }

  ensureTrailingEmptySaleLine(updated, nextLineId);
  return updated;
}
