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
    this.description,
    this.hsnCode,
    this.barcode,
    this.brandId,
    this.baseUnitShortName,
    this.purchasePrice,
    this.mrp,
    this.reorderLevel,
    this.primaryImageUrl,
    this.isRawMaterial = false,
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
  final String? description;
  final String? hsnCode;
  final String? barcode;
  final String? brandId;
  final String? baseUnitShortName;
  final double? purchasePrice;
  final double? mrp;
  final double? reorderLevel;
  final String? primaryImageUrl;
  final bool isRawMaterial;

  InventoryItem copyWith({
    String? id,
    String? name,
    ItemType? type,
    double? quantity,
    double? salePrice,
    double? stockValue,
    String? categoryId,
    double? availableForSale,
    double? reservedQuantity,
    String? description,
    String? hsnCode,
    String? barcode,
    String? brandId,
    String? baseUnitShortName,
    double? purchasePrice,
    double? mrp,
    double? reorderLevel,
    String? primaryImageUrl,
    bool? isRawMaterial,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      salePrice: salePrice ?? this.salePrice,
      stockValue: stockValue ?? this.stockValue,
      categoryId: categoryId ?? this.categoryId,
      availableForSale: availableForSale ?? this.availableForSale,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      description: description ?? this.description,
      hsnCode: hsnCode ?? this.hsnCode,
      barcode: barcode ?? this.barcode,
      brandId: brandId ?? this.brandId,
      baseUnitShortName: baseUnitShortName ?? this.baseUnitShortName,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      mrp: mrp ?? this.mrp,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      isRawMaterial: isRawMaterial ?? this.isRawMaterial,
    );
  }
}
