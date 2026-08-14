class ItemSupplierModel {
  const ItemSupplierModel({
    required this.id,
    required this.itemId,
    required this.partyId,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  final String id;
  final String itemId;
  final String partyId;
  final bool isDefault;
  final int sortOrder;
}
