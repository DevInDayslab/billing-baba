import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';

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
  final double unitCost = item.purchasePrice > 0
      ? item.purchasePrice
      : (item.mfgCost > 0 ? item.mfgCost : 0.0);

  return line.copyWith(
    itemId: item.id,
    itemName: item.name,
    pricePerUnit: price,
    catalogUnitPrice: price,
    priceManuallyOverridden: false,
    unit: saleItemDefaultUnit(item),
    qty: qty,
    taxPercent: taxPercent,
    unitCost: unitCost,
  );
}

/// Preserves catalog-linked fields when a widget passes a stale line snapshot
/// (e.g. qty blur after async [selectCatalogItem]).
SaleLineItem preserveCatalogFieldsOnStaleLineUpdate(
  SaleLineItem current,
  SaleLineItem incoming,
) {
  final sameItemName =
      incoming.itemName.trim().isNotEmpty &&
      incoming.itemName.trim() == current.itemName.trim();

  if (current.itemId == null || incoming.itemId != null || !sameItemName) {
    return incoming;
  }

  final preservePrice =
      !incoming.priceManuallyOverridden &&
      (current.priceManuallyOverridden || incoming.pricePerUnit == 0);

  return incoming.copyWith(
    itemId: current.itemId,
    catalogUnitPrice: current.catalogUnitPrice,
    pricePerUnit: preservePrice ? current.pricePerUnit : incoming.pricePerUnit,
    priceManuallyOverridden:
        incoming.priceManuallyOverridden || current.priceManuallyOverridden,
    unit: incoming.unit == 'NONE' && current.unit != 'NONE'
        ? current.unit
        : incoming.unit,
    taxPercent: incoming.taxPercent == 0 && current.taxPercent > 0
        ? current.taxPercent
        : incoming.taxPercent,
  );
}

/// Re-applies user edits that may have happened while catalog defaults load.
SaleLineItem mergeUserEditsIntoCatalogLine(
  SaleLineItem applied,
  SaleLineItem current,
) {
  return applied.copyWith(
    qty: current.qty > 0 ? current.qty : applied.qty,
  );
}

bool isEmptySaleLineDraft(SaleLineItem line) =>
    line.qty <= 0 && (line.itemName.trim().isEmpty || line.itemId == null);

int? resolveSaleLineIndex(
  List<SaleLineItem> items, {
  required int fallbackIndex,
  String? lineId,
}) {
  if (lineId != null) {
    final byId = items.indexWhere((line) => line.id == lineId);
    if (byId >= 0) return byId;
  }
  if (fallbackIndex >= 0 && fallbackIndex < items.length) {
    return fallbackIndex;
  }
  return null;
}

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
