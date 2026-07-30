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

  ItemImageModel copyWith({
    String? id,
    String? imageUrl,
    String? thumbnailUrl,
    String? mediumUrl,
    String? mediaAssetId,
    int? sortOrder,
    bool? isPrimary,
  }) {
    return ItemImageModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediumUrl: mediumUrl ?? this.mediumUrl,
      mediaAssetId: mediaAssetId ?? this.mediaAssetId,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
