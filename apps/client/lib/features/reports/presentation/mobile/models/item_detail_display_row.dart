/// One aggregated day row for the mobile item detail report table.
class ItemDetailDisplayRow {
  const ItemDetailDisplayRow({
    required this.date,
    required this.saleQty,
    required this.purchaseQty,
    required this.adjustQty,
    required this.closingQty,
  });

  final DateTime date;
  final double saleQty;
  final double purchaseQty;
  final double adjustQty;
  final double closingQty;
}
