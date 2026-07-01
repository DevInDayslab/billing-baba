class ProductTransaction {
  const ProductTransaction({
    required this.id,
    required this.itemId,
    required this.typeLabel,
    required this.invoiceRefNo,
    required this.partyName,
    required this.date,
    required this.quantity,
    this.unit,
    required this.pricePerUnit,
    required this.status,
    this.isInbound = false,
  });

  final String id;
  final String itemId;
  final String typeLabel;
  final String invoiceRefNo;
  final String partyName;
  final DateTime date;
  final double quantity;
  final String? unit;
  final double pricePerUnit;
  final String status;
  final bool isInbound;
}
