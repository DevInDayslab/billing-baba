// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  expiresIn: (json['expires_in'] as num).toInt(),
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  businesses: (json['businesses'] as List<dynamic>)
      .map((e) => BusinessSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  deviceTrustToken: json['device_trust_token'] as String?,
  deviceTrustExpiresAt: json['device_trust_expires_at'] as String?,
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_in': instance.expiresIn,
      'user': instance.user,
      'businesses': instance.businesses,
      'device_trust_token': instance.deviceTrustToken,
      'device_trust_expires_at': instance.deviceTrustExpiresAt,
    };

_MeResponse _$MeResponseFromJson(Map<String, dynamic> json) => _MeResponse(
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  businesses: (json['businesses'] as List<dynamic>)
      .map((e) => BusinessSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  profile: AccountProfile.fromJson(json['profile'] as Map<String, dynamic>),
  selectedBusiness: json['selected_business'] == null
      ? null
      : BusinessSummary.fromJson(
          json['selected_business'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$MeResponseToJson(_MeResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'businesses': instance.businesses,
      'profile': instance.profile,
      'selected_business': instance.selectedBusiness,
    };
