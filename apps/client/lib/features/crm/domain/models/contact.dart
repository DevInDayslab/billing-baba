import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact.freezed.dart';
part 'contact.g.dart';

@freezed
abstract class Contact with _$Contact {
  const factory Contact({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    required String name,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    String? salutation,
    @JsonKey(name: 'account_name') String? accountName,
    String? phone,
    String? email,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    String? title,
    String? description,
    @JsonKey(name: 'sync_version') @Default(1) int syncVersion,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    @JsonKey(name: 'device_id') @Default('') String deviceId,
    @JsonKey(name: 'sync_status') @Default('pending') String syncStatus,
  }) = _Contact;

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
}

extension ContactX on Contact {
  static String displayOrDash(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '—';
    return trimmed;
  }

  String get displayAccountName => displayOrDash(accountName);
  String get displayPhone => displayOrDash(phone);
  String get displayEmail => displayOrDash(email);
  String get displayAssignedTo => displayOrDash(assignedTo);
}
