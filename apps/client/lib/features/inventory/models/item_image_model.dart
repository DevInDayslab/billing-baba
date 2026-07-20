class ItemImageModel {
  const ItemImageModel({
    required this.id,
    required this.imageUrl,
    required this.sortOrder,
    required this.isPrimary,
    this.thumbnailUrl,
    this.mediumUrl,
    this.mediaAssetId,
  });

  final String id;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? mediumUrl;
  final String? mediaAssetId;
  final int sortOrder;
  final bool isPrimary;

  String urlForGrid() => thumbnailUrl ?? imageUrl;

  String urlForDetail() => mediumUrl ?? imageUrl;
}
