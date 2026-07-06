import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';

/// Applies catalog item defaults to an invoice line (price, unit, qty).
SaleLineItem applyCatalogItemToLine(
  SaleLineItem line,
  SaleItemOption item, {
  bool resetQtyWhenEmpty = true,
}) {
  final qty = resetQtyWhenEmpty && line.qty <= 0 ? 1.0 : line.qty;
  return line.copyWith(
    itemId: item.id,
    itemName: item.name,
    pricePerUnit: item.salePrice,
    unit: saleItemDefaultUnit(item),
    qty: qty,
  );
}
