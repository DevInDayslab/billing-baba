class PosItem {
  const PosItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
  });

  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final int stock;
}
