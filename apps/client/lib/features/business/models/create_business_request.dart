import 'package:billing_baba/features/auth/models/auth_session.dart';

class CreateBusinessRequest {
  const CreateBusinessRequest({
    required this.name,
    this.ownerName,
    this.phone,
    this.email,
    this.gstin,
    this.businessType,
    this.businessCategory,
    this.state,
    this.currency,
    this.address,
    this.refreshToken,
  });

  final String name;
  final String? ownerName;
  final String? phone;
  final String? email;
  final String? gstin;
  final String? businessType;
  final String? businessCategory;
  final String? state;
  final String? currency;
  final String? address;
  final String? refreshToken;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (ownerName != null && ownerName!.isNotEmpty) 'owner_name': ownerName,
    if (phone != null && phone!.isNotEmpty) 'phone': phone,
    if (email != null && email!.isNotEmpty) 'email': email,
    if (gstin != null && gstin!.isNotEmpty) 'gstin': gstin,
    if (businessType != null && businessType!.isNotEmpty)
      'business_type': businessType,
    if (businessCategory != null && businessCategory!.isNotEmpty)
      'business_category': businessCategory,
    if (state != null && state!.isNotEmpty) 'state': state,
    if (currency != null && currency!.isNotEmpty) 'currency': currency,
    if (address != null && address!.isNotEmpty) 'address': address,
    if (refreshToken != null && refreshToken!.isNotEmpty)
      'refresh_token': refreshToken,
  };
}

class CreateBusinessOutcome {
  const CreateBusinessOutcome({
    required this.business,
    this.session,
  });

  final BusinessDetailDto business;
  final AuthSession? session;
}

class BusinessDetailDto {
  const BusinessDetailDto({
    required this.id,
    required this.name,
    required this.role,
    this.gstin,
    this.phone,
    this.email,
    this.stateCode,
    this.address,
    this.ownerName,
    this.isShared = false,
    this.logoUrl,
    this.scheduledDeletionAt,
  });

  factory BusinessDetailDto.fromJson(Map<String, dynamic> json) {
    return BusinessDetailDto(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      gstin: json['gstin'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      stateCode: json['state_code'] as String?,
      address: json['address'] as String?,
      ownerName: json['owner_name'] as String?,
      isShared: json['is_shared'] as bool? ?? false,
      logoUrl: json['logo_url'] as String?,
      scheduledDeletionAt: _parseDate(json['scheduled_deletion_at']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  final String id;
  final String name;
  final String role;
  final String? gstin;
  final String? phone;
  final String? email;
  final String? stateCode;
  final String? address;
  final String? ownerName;
  final bool isShared;
  final String? logoUrl;
  final DateTime? scheduledDeletionAt;
}
