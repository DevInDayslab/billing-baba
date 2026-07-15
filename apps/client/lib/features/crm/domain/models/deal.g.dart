// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deal _$DealFromJson(Map<String, dynamic> json) => _Deal(
  id: json['id'] as String,
  businessId: json['business_id'] as String,
  name: json['name'] as String,
  stage:
      $enumDecodeNullable(_$DealStageEnumMap, json['stage']) ??
      DealStage.qualification,
  accountName: json['account_name'] as String?,
  assignedTo: json['assigned_to'] as String?,
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  expectedCloseDate: json['expected_close_date'] == null
      ? null
      : DateTime.parse(json['expected_close_date'] as String),
  description: json['description'] as String?,
  syncVersion: (json['sync_version'] as num?)?.toInt() ?? 1,
  isDeleted: json['is_deleted'] as bool? ?? false,
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  deviceId: json['device_id'] as String? ?? '',
  syncStatus: json['sync_status'] as String? ?? 'pending',
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$DealToJson(_Deal instance) => <String, dynamic>{
  'id': instance.id,
  'business_id': instance.businessId,
  'name': instance.name,
  'stage': _$DealStageEnumMap[instance.stage]!,
  'account_name': instance.accountName,
  'assigned_to': instance.assignedTo,
  'amount': instance.amount,
  'expected_close_date': instance.expectedCloseDate?.toIso8601String(),
  'description': instance.description,
  'sync_version': instance.syncVersion,
  'is_deleted': instance.isDeleted,
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'device_id': instance.deviceId,
  'sync_status': instance.syncStatus,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$DealStageEnumMap = {
  DealStage.qualification: 'qualification',
  DealStage.needsAnalysis: 'needs_analysis',
  DealStage.valueProposition: 'value_proposition',
  DealStage.identifyDecisionMakers: 'identify_decision_makers',
  DealStage.proposalPriceQuote: 'proposal_price_quote',
  DealStage.negotiationReview: 'negotiation_review',
  DealStage.closedWon: 'closed_won',
  DealStage.closedLost: 'closed_lost',
  DealStage.closedLostToCompetition: 'closed_lost_to_competition',
};
