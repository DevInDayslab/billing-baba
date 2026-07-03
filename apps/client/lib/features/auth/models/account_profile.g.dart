// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountProfile _$AccountProfileFromJson(Map<String, dynamic> json) =>
    _AccountProfile(
      phone: json['phone'] as String,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      language: json['language'] as String? ?? 'en',
    );

Map<String, dynamic> _$AccountProfileToJson(_AccountProfile instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'display_name': instance.displayName,
      'email': instance.email,
      'avatar_url': instance.avatarUrl,
      'timezone': instance.timezone,
      'language': instance.language,
    };
