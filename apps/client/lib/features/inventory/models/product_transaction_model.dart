class ProductTransaction {
  const ProductTransaction({
    required this.id,
    required this.itemId,
    required this.typeLabel,
    required this.invoiceRefNo,
    required this.partyName,
    required this.date,
    required this.quantity,
    required this.pricePerUnit,
    required this.status,
    required this.documentLabel,
    required this.transactionType,
    required this.referenceNo,
    this.unit,
    this.isInbound = false,
    this.godownName,
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
  final String documentLabel;
  final String transactionType;
  final String referenceNo;
  final String? godownName;

  double get signedQuantity => isInbound ? quantity : -quantity;

  double get amount => quantity * pricePerUnit;
}
