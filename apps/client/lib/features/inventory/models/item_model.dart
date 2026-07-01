enum ItemType { product, service }

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.type,
    this.quantity,
    this.salePrice,
    this.stockValue,
    this.categoryId,
    this.availableForSale,
    this.reservedQuantity,
  });

  final String id;
  final String name;
  final ItemType type;
  final double? quantity;
  final double? salePrice;
  final double? stockValue;
  final String? categoryId;
  final double? availableForSale;
  final double? reservedQuantity;
}
