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
    required this.movementType,
    this.unit,
    this.isInbound = false,
    this.godownName,
    this.createdByName,
    this.notes,
    this.referenceDocumentId,
    this.referenceDocumentType,
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
  final String movementType;
  final String? godownName;
  final String? createdByName;
  final String? notes;
  final String? referenceDocumentId;
  final String? referenceDocumentType;

  double get signedQuantity => isInbound ? quantity : -quantity;

  double get amount => quantity * pricePerUnit;
}
