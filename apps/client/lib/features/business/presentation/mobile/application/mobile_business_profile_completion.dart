import 'package:billing_baba/features/business/models/business_profile_model.dart';

/// Calculates how complete the business profile is for the mobile progress bar.
int calculateMobileBusinessProfileCompletion({
  required BusinessProfileModel profile,
  required String name,
  required String phone,
  required String email,
  required String gstin,
  required String address,
  required String pincode,
  required String? businessType,
  required String? businessCategory,
  required String? state,
  required String upiId,
}) {
  final checks = <bool>[
    name.trim().isNotEmpty,
    phone.trim().isNotEmpty,
    email.trim().isNotEmpty,
    gstin.trim().isNotEmpty,
    address.trim().isNotEmpty,
    pincode.trim().isNotEmpty,
    (businessType ?? '').trim().isNotEmpty,
    (businessCategory ?? '').trim().isNotEmpty,
    (state ?? '').trim().isNotEmpty,
    upiId.trim().isNotEmpty,
    (profile.logoUrl ?? '').trim().isNotEmpty,
    (profile.signatureUrl ?? '').trim().isNotEmpty,
  ];

  final filled = checks.where((value) => value).length;
  if (checks.isEmpty) return 0;
  return ((filled / checks.length) * 100).round();
}
