class PosItem {
  const PosItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    this.categoryId,
    this.categoryName = 'Uncategorized',
    this.mrp,
    this.unit = 'pcs',
    this.imageUrl,
    this.hsnCode,
  });

  final String id;
  final String name;
  final String sku;
  final String? categoryId;
  final String categoryName;
  final double price;
  final double? mrp;
  final int stock;
  final String unit;
  final String? imageUrl;
  final String? hsnCode;

  bool get isOutOfStock => stock <= 0;

  /// Used for category chip styling (prefers stable category id).
  String get categoryStyleKey => categoryId ?? categoryName;
}
