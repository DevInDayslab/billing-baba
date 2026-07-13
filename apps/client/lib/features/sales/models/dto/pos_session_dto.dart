import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';

class PosSessionDto {
  const PosSessionDto({
    required this.id,
    required this.userId,
    required this.startedAt,
    required this.createdAt,
    required this.updatedAt,
    this.endedAt,
    this.openingCash,
    this.closingCash,
  });

  factory PosSessionDto.fromJson(Map<String, dynamic> json) {
    return PosSessionDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startedAt: json['started_at'] as String,
      endedAt: json['ended_at'] as String?,
      openingCash: json['opening_cash'] as String?,
      closingCash: json['closing_cash'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String userId;
  final String startedAt;
  final String? endedAt;
  final String? openingCash;
  final String? closingCash;
  final String createdAt;
  final String updatedAt;

  bool get isOpen => endedAt == null;
}

class PaginatedPosSessionsDto {
  const PaginatedPosSessionsDto({
    required this.sessions,
    required this.meta,
  });

  factory PaginatedPosSessionsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedPosSessionsDto(
      sessions: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(PosSessionDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<PosSessionDto> sessions;
  final PaginationMetaDto meta;
}
