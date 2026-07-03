class CreateBusinessRequest {
  const CreateBusinessRequest({
    required this.name,
    this.ownerName,
    this.phone,
    this.email,
    this.gstin,
    this.businessType,
    this.state,
    this.currency,
    this.address,
  });

  final String name;
  final String? ownerName;
  final String? phone;
  final String? email;
  final String? gstin;
  final String? businessType;
  final String? state;
  final String? currency;
  final String? address;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (ownerName != null && ownerName!.isNotEmpty) 'owner_name': ownerName,
    if (phone != null && phone!.isNotEmpty) 'phone': phone,
    if (email != null && email!.isNotEmpty) 'email': email,
    if (gstin != null && gstin!.isNotEmpty) 'gstin': gstin,
    if (businessType != null && businessType!.isNotEmpty)
      'business_type': businessType,
    if (state != null && state!.isNotEmpty) 'state': state,
    if (currency != null && currency!.isNotEmpty) 'currency': currency,
    if (address != null && address!.isNotEmpty) 'address': address,
  };
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
    this.isShared = false,
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
      isShared: json['is_shared'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String role;
  final String? gstin;
  final String? phone;
  final String? email;
  final String? stateCode;
  final String? address;
  final bool isShared;
}
