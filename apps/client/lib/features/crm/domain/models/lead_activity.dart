import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead_activity.freezed.dart';
part 'lead_activity.g.dart';

enum LeadActivityType {
  @JsonValue('call')
  call,
  @JsonValue('email')
  email,
  @JsonValue('meeting')
  meeting,
  @JsonValue('note')
  note,
  @JsonValue('status_change')
  statusChange,
}

@freezed
abstract class LeadActivity with _$LeadActivity {
  const factory LeadActivity({
    required String id,
    @JsonKey(name: 'lead_id') required String leadId,
    @JsonKey(name: 'business_id') required String businessId,
    required LeadActivityType type,
    @JsonKey(name: 'updated_at') required DateTime updatedAt, @JsonKey(name: 'created_at') required DateTime createdAt, String? notes,
    @JsonKey(name: 'added_by') String? addedBy,
    @JsonKey(name: 'sync_version') @Default(1) int syncVersion,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    @JsonKey(name: 'device_id') @Default('') String deviceId,
    @JsonKey(name: 'sync_status') @Default('pending') String syncStatus,
  }) = _LeadActivity;

  factory LeadActivity.fromJson(Map<String, dynamic> json) =>
      _$LeadActivityFromJson(json);
}

extension LeadActivityTypeX on LeadActivityType {
  String get label => switch (this) {
    LeadActivityType.call => 'Call',
    LeadActivityType.email => 'Email',
    LeadActivityType.meeting => 'Meeting',
    LeadActivityType.note => 'Note',
    LeadActivityType.statusChange => 'Status Change',
  };

  String get wireValue => switch (this) {
    LeadActivityType.call => 'call',
    LeadActivityType.email => 'email',
    LeadActivityType.meeting => 'meeting',
    LeadActivityType.note => 'note',
    LeadActivityType.statusChange => 'status_change',
  };

  static LeadActivityType fromWire(String value) {
    return LeadActivityType.values.firstWhere(
      (type) => type.wireValue == value,
      orElse: () => LeadActivityType.note,
    );
  }
}
