class InventoryCategory {
  const InventoryCategory({
    required this.id,
    required this.name,
    this.itemCount = 0,
    this.isUncategorized = false,
  });

  final String id;
  final String name;
  final int itemCount;
  final bool isUncategorized;
}
