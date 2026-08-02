import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_activity.freezed.dart';
part 'contact_activity.g.dart';

enum ContactActivityType {
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
abstract class ContactActivity with _$ContactActivity {
  const factory ContactActivity({
    required String id,
    @JsonKey(name: 'contact_id') required String contactId,
    @JsonKey(name: 'business_id') required String businessId,
    required ContactActivityType type,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    String? notes,
    @JsonKey(name: 'added_by') String? addedBy,
    @JsonKey(name: 'sync_version') @Default(1) int syncVersion,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    @JsonKey(name: 'device_id') @Default('') String deviceId,
    @JsonKey(name: 'sync_status') @Default('pending') String syncStatus,
  }) = _ContactActivity;

  factory ContactActivity.fromJson(Map<String, dynamic> json) =>
      _$ContactActivityFromJson(json);
}

extension ContactActivityTypeX on ContactActivityType {
  String get label => switch (this) {
    ContactActivityType.call => 'Call',
    ContactActivityType.email => 'Email',
    ContactActivityType.meeting => 'Meeting',
    ContactActivityType.note => 'Note',
    ContactActivityType.statusChange => 'Status Change',
  };

  String get wireValue => switch (this) {
    ContactActivityType.call => 'call',
    ContactActivityType.email => 'email',
    ContactActivityType.meeting => 'meeting',
    ContactActivityType.note => 'note',
    ContactActivityType.statusChange => 'status_change',
  };

  static ContactActivityType fromWire(String value) {
    return ContactActivityType.values.firstWhere(
      (type) => type.wireValue == value,
      orElse: () => ContactActivityType.note,
    );
  }
}
