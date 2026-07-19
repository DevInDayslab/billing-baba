import 'package:billing_baba/core/utils/validators.dart';

class BusinessProfileModel {
  const BusinessProfileModel({
    required this.id,
    required this.name,
    this.ownerName,
    this.phone,
    this.email,
    this.gstin,
    this.businessType,
    this.businessCategory,
    this.state,
    this.pincode,
    this.currency = 'INR',
    this.address,
    this.timezone = 'Asia/Kolkata',
    this.language = 'en',
    this.logoUrl,
    this.signatureUrl,
    this.stampUrl,
    this.upiQrUrl,
  });

  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return BusinessProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerName: json['owner_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      gstin: json['gstin'] as String?,
      businessType: json['business_type'] as String?,
      businessCategory: json['business_category'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      currency: json['currency'] as String? ?? 'INR',
      address: json['address'] as String?,
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      language: json['language'] as String? ?? 'en',
      logoUrl: json['logo_url'] as String?,
      signatureUrl: json['signature_url'] as String?,
      stampUrl: json['stamp_url'] as String?,
      upiQrUrl: json['upi_qr_url'] as String?,
    );
  }

  final String id;
  final String name;
  final String? ownerName;
  final String? phone;
  final String? email;
  final String? gstin;
  final String? businessType;
  final String? businessCategory;
  final String? state;
  final String? pincode;
  final String currency;
  final String? address;
  final String timezone;
  final String language;
  final String? logoUrl;
  final String? signatureUrl;
  final String? stampUrl;
  final String? upiQrUrl;

  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'B';
    return trimmed[0].toUpperCase();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'owner_name': ownerName,
    'phone': phone,
    'email': email,
    'gstin': gstin,
    'business_type': businessType,
    'business_category': businessCategory,
    'state': state,
    'pincode': pincode,
    'currency': currency,
    'address': address,
    'timezone': timezone,
    'language': language,
    'logo_url': logoUrl,
    'signature_url': signatureUrl,
    'stamp_url': stampUrl,
    'upi_qr_url': upiQrUrl,
  };
}

class UpdateBusinessProfileRequest {
  const UpdateBusinessProfileRequest({
    required this.name,
    this.phone,
    this.email,
    this.gstin,
    this.businessType,
    this.businessCategory,
    this.state,
    this.pincode,
    this.address,
  });

  final String name;
  final String? phone;
  final String? email;
  final String? gstin;
  final String? businessType;
  final String? businessCategory;
  final String? state;
  final String? pincode;
  final String? address;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
    if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
    if (gstin != null && gstin!.trim().isNotEmpty) 'gstin': gstin!.trim(),
    if (businessType != null && businessType!.trim().isNotEmpty)
      'business_type': businessType!.trim(),
    if (businessCategory != null && businessCategory!.trim().isNotEmpty)
      'business_category': businessCategory!.trim(),
    if (state != null && state!.trim().isNotEmpty) 'state': state!.trim(),
    if (pincode != null && pincode!.trim().isNotEmpty)
      'pincode': pincode!.trim(),
    if (address != null && address!.trim().isNotEmpty)
      'address': address!.trim(),
  };
}

class UpdateBusinessProfileInput {
  const UpdateBusinessProfileInput({
    required this.name,
    this.phone,
    this.email,
    this.gstin,
    this.businessType,
    this.businessCategory,
    this.state,
    this.pincode,
    this.address,
  });

  final String name;
  final String? phone;
  final String? email;
  final String? gstin;
  final String? businessType;
  final String? businessCategory;
  final String? state;
  final String? pincode;
  final String? address;

  UpdateBusinessProfileRequest toRequest() => UpdateBusinessProfileRequest(
    name: name,
    phone: Validators.normalizeIndianPhone(phone),
    email: email?.trim().isEmpty ?? true ? null : email?.trim(),
    gstin: gstin?.trim().isEmpty ?? true ? null : gstin?.trim(),
    businessType: businessType?.trim().isEmpty ?? true
        ? null
        : businessType?.trim(),
    businessCategory: businessCategory?.trim().isEmpty ?? true
        ? null
        : businessCategory?.trim(),
    state: state?.trim().isEmpty ?? true ? null : state?.trim(),
    pincode: Validators.normalizePincode(pincode),
    address: address?.trim().isEmpty ?? true ? null : address?.trim(),
  );
}
