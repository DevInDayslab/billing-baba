// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_meta_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginationMetaDto _$PaginationMetaDtoFromJson(Map<String, dynamic> json) =>
    _PaginationMetaDto(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaginationMetaDtoToJson(_PaginationMetaDto instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'totalPages': instance.totalPages,
    };
