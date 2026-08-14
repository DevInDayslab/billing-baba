import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead.freezed.dart';
part 'lead.g.dart';

enum LeadSource {
  @JsonValue('google_ads')
  googleAds,
  @JsonValue('referral')
  referral,
  @JsonValue('website')
  website,
  @JsonValue('walk_in')
  walkIn,
  @JsonValue('other')
  other,
}

enum LeadStatus {
  @JsonValue('new')
  newLead,
  @JsonValue('contacted')
  contacted,
  @JsonValue('qualified')
  qualified,
  @JsonValue('converted')
  converted,
  @JsonValue('lost')
  lost,
}

@freezed
abstract class Lead with _$Lead {
  const factory Lead({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    required String name,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    String? company,
    String? phone,
    String? email,
    @JsonKey(name: 'lead_source') LeadSource? leadSource,
    @Default(LeadStatus.newLead) LeadStatus status,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    String? notes,
    @JsonKey(name: 'sync_version') @Default(1) int syncVersion,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    @JsonKey(name: 'device_id') @Default('') String deviceId,
    @JsonKey(name: 'sync_status') @Default('pending') String syncStatus,
  }) = _Lead;

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);
}

extension LeadSourceX on LeadSource {
  String get label => switch (this) {
    LeadSource.googleAds => 'Google Ads',
    LeadSource.referral => 'Referral',
    LeadSource.website => 'Website',
    LeadSource.walkIn => 'Walk-in',
    LeadSource.other => 'Other',
  };

  String get wireValue => switch (this) {
    LeadSource.googleAds => 'google_ads',
    LeadSource.referral => 'referral',
    LeadSource.website => 'website',
    LeadSource.walkIn => 'walk_in',
    LeadSource.other => 'other',
  };

  static LeadSource? fromWire(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final source in LeadSource.values) {
      if (source.wireValue == value) return source;
    }
    return LeadSource.other;
  }
}

extension LeadStatusX on LeadStatus {
  String get label => switch (this) {
    LeadStatus.newLead => 'New',
    LeadStatus.contacted => 'Contacted',
    LeadStatus.qualified => 'Qualified',
    LeadStatus.converted => 'Converted',
    LeadStatus.lost => 'Lost',
  };

  String get wireValue => switch (this) {
    LeadStatus.newLead => 'new',
    LeadStatus.contacted => 'contacted',
    LeadStatus.qualified => 'qualified',
    LeadStatus.converted => 'converted',
    LeadStatus.lost => 'lost',
  };

  static LeadStatus fromWire(String value) {
    return LeadStatus.values.firstWhere(
      (status) => status.wireValue == value,
      orElse: () => LeadStatus.newLead,
    );
  }
}

extension LeadX on Lead {
  static String displayOrDash(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '—';
    return trimmed;
  }

  String get displayCompany => displayOrDash(company);
  String get displayPhone => displayOrDash(phone);
  String get displayEmail => displayOrDash(email);
  String get displayAssignedTo => displayOrDash(assignedTo);
  String get displayLeadSource => leadSource?.label ?? '—';
}
