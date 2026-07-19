// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_access.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompanyAccess _$CompanyAccessFromJson(Map<String, dynamic> json) =>
    _CompanyAccess(
      businessName: json['business_name'] as String,
      ownerName: json['owner_name'] as String,
      ownerPhone: json['owner_phone'] as String,
      totalMembers: (json['total_members'] as num).toInt(),
      loggedInPhone: json['logged_in_phone'] as String,
    );

Map<String, dynamic> _$CompanyAccessToJson(_CompanyAccess instance) =>
    <String, dynamic>{
      'business_name': instance.businessName,
      'owner_name': instance.ownerName,
      'owner_phone': instance.ownerPhone,
      'total_members': instance.totalMembers,
      'logged_in_phone': instance.loggedInPhone,
    };
