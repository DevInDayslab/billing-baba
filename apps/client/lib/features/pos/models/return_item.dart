/// Line item selected for a POS return.
class ReturnItem {
  const ReturnItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String itemId;
  final String name;
  final int quantity;
  final String unit;
  final String unitPrice;
  final double lineTotal;
}
