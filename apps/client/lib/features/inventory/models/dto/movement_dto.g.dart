// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MovementDto _$MovementDtoFromJson(Map<String, dynamic> json) => _MovementDto(
  id: json['id'] as String,
  itemId: json['item_id'] as String,
  itemName: json['item_name'] as String,
  godownId: json['godown_id'] as String,
  godownName: json['godown_name'] as String,
  movementType: json['movement_type'] as String,
  quantityDelta: json['quantity_delta'] as String,
  createdAt: json['created_at'] as String,
  costPerUnit: json['cost_per_unit'] as String?,
  referenceId: json['reference_id'] as String?,
  referenceType: json['reference_type'] as String?,
  referenceNumber: json['reference_number'] as String?,
  partyName: json['party_name'] as String?,
  createdBy: json['created_by'] as String?,
);

Map<String, dynamic> _$MovementDtoToJson(_MovementDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'item_name': instance.itemName,
      'godown_id': instance.godownId,
      'godown_name': instance.godownName,
      'movement_type': instance.movementType,
      'quantity_delta': instance.quantityDelta,
      'created_at': instance.createdAt,
      'cost_per_unit': instance.costPerUnit,
      'reference_id': instance.referenceId,
      'reference_type': instance.referenceType,
      'reference_number': instance.referenceNumber,
      'party_name': instance.partyName,
      'created_by': instance.createdBy,
    };
