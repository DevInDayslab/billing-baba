class ItemLocationHistoryDto {
  const ItemLocationHistoryDto({
    required this.id,
    required this.itemLocationId,
    required this.itemId,
    required this.createdAt,
    this.rack,
    this.shelf,
    this.photoUrl,
    this.photoMediaAssetId,
    this.employeeLabel,
    this.changedBy,
  });

  factory ItemLocationHistoryDto.fromJson(Map<String, dynamic> json) {
    return ItemLocationHistoryDto(
      id: json['id'] as String,
      itemLocationId: json['item_location_id'] as String,
      itemId: json['item_id'] as String,
      createdAt: json['created_at'] as String,
      rack: json['rack'] as String?,
      shelf: json['shelf'] as String?,
      photoUrl: json['photo_url'] as String?,
      photoMediaAssetId: json['photo_media_asset_id'] as String?,
      employeeLabel: json['employee_label'] as String?,
      changedBy: json['changed_by'] as String?,
    );
  }

  final String id;
  final String itemLocationId;
  final String itemId;
  final String createdAt;
  final String? rack;
  final String? shelf;
  final String? photoUrl;
  final String? photoMediaAssetId;
  final String? employeeLabel;
  final String? changedBy;
}

class PaginatedItemLocationHistoryDto {
  const PaginatedItemLocationHistoryDto({
    required this.records,
    required this.meta,
  });

  factory PaginatedItemLocationHistoryDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final metaJson = json['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedItemLocationHistoryDto(
      records: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(ItemLocationHistoryDto.fromJson)
                .toList()
          : const [],
      meta: (
        page: (metaJson['page'] as num?)?.toInt() ?? 1,
        limit: (metaJson['limit'] as num?)?.toInt() ?? 50,
        total: (metaJson['total'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  final List<ItemLocationHistoryDto> records;
  final ({int page, int limit, int total}) meta;
}
