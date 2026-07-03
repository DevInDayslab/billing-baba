// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemLocationDto _$ItemLocationDtoFromJson(Map<String, dynamic> json) =>
    _ItemLocationDto(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      godownId: json['godown_id'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      rack: json['rack'] as String?,
      shelf: json['shelf'] as String?,
      photoUrl: json['photo_url'] as String?,
      photoTakenAt: json['photo_taken_at'] as String?,
    );

Map<String, dynamic> _$ItemLocationDtoToJson(_ItemLocationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'godown_id': instance.godownId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'rack': instance.rack,
      'shelf': instance.shelf,
      'photo_url': instance.photoUrl,
      'photo_taken_at': instance.photoTakenAt,
    };
