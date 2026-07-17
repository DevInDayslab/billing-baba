class PosSaleLineItem {
  const PosSaleLineItem({
    required this.name,
    required this.quantity,
    required this.lineTotal,
    this.itemId,
    this.unit,
    this.unitPrice,
    this.cgstAmount,
    this.sgstAmount,
    this.igstAmount,
  });

  final String name;
  final int quantity;
  final double lineTotal;
  final String? itemId;
  final String? unit;
  final double? unitPrice;
  final double? cgstAmount;
  final double? sgstAmount;
  final double? igstAmount;
}
