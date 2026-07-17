import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';

/// Applies catalog item defaults to a purchase line (price, unit, qty).
PurchaseLineItem applyCatalogItemToPurchaseLine(
  PurchaseLineItem line,
  SaleItemOption item, {
  bool resetQtyWhenEmpty = true,
}) {
  final qty = resetQtyWhenEmpty && line.qty <= 0 ? 1.0 : line.qty;
  return line.copyWith(
    itemId: item.id,
    itemName: item.name,
    pricePerUnit: item.purchasePrice,
    unit: saleItemDefaultUnit(item),
    qty: qty,
  );
}

bool isEmptyPurchaseLineDraft(PurchaseLineItem line) =>
    line.itemName.trim().isEmpty && line.qty <= 0;

bool canClubPurchaseLineItem(PurchaseLineItem line) => line.itemId != null;

void ensureTrailingEmptyPurchaseLine(
  List<PurchaseLineItem> items,
  String Function() nextLineId,
) {
  if (items.isEmpty) {
    items.add(PurchaseLineItem.empty(id: nextLineId()));
    return;
  }
  final last = items.last;
  if (!isEmptyPurchaseLineDraft(last)) {
    items.add(PurchaseLineItem.empty(id: nextLineId()));
  }
}

/// Selects a catalog item on [targetIndex], clubbing qty into an existing row
/// with the same [itemId] when allowed.
List<PurchaseLineItem> selectCatalogItemOnPurchaseLines({
  required List<PurchaseLineItem> items,
  required int targetIndex,
  required PurchaseLineItem appliedLine,
  required String Function() nextLineId,
}) {
  if (targetIndex < 0 || targetIndex >= items.length) return items;

  final itemId = appliedLine.itemId;
  if (itemId == null) {
    final updated = [...items];
    updated[targetIndex] = appliedLine;
    ensureTrailingEmptyPurchaseLine(updated, nextLineId);
    return updated;
  }

  var clubIndex = -1;
  for (var i = 0; i < items.length; i++) {
    if (i == targetIndex) continue;
    final line = items[i];
    if (line.itemId == itemId && canClubPurchaseLineItem(line)) {
      clubIndex = i;
      break;
    }
  }

  if (clubIndex < 0) {
    final updated = [...items];
    updated[targetIndex] = appliedLine;
    ensureTrailingEmptyPurchaseLine(updated, nextLineId);
    return updated;
  }

  final qtyToAdd = appliedLine.qty > 0 ? appliedLine.qty : 1.0;
  final updated = [...items];
  updated[clubIndex] = updated[clubIndex].copyWith(
    qty: updated[clubIndex].qty + qtyToAdd,
  );

  final target = items[targetIndex];
  if (isEmptyPurchaseLineDraft(target)) {
    updated.removeAt(targetIndex);
  } else {
    updated[targetIndex] = PurchaseLineItem.empty(id: target.id);
  }

  ensureTrailingEmptyPurchaseLine(updated, nextLineId);
  return updated;
}
