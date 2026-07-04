class ItemImageModel {
  const ItemImageModel({
    required this.id,
    required this.imageUrl,
    required this.sortOrder,
    required this.isPrimary,
  });

  final String id;
  final String imageUrl;
  final int sortOrder;
  final bool isPrimary;
}
