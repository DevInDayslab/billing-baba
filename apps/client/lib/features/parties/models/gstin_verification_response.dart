/// Full verification payload from `POST /api/v1/gstin/verify`.
///
/// Includes metadata (`success`, `cached`, `creditsRemaining`) for future UX
/// such as cached-result badges and credit monitoring without model changes.
class GstinVerificationResponse {
  const GstinVerificationResponse({
    required this.success,
    required this.cached,
    required this.creditsRemaining,
    required this.data,
  });

  factory GstinVerificationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return GstinVerificationResponse(
      success: json['success'] as bool? ?? false,
      cached: json['cached'] as bool? ?? false,
      creditsRemaining: json['credits_remaining'] as int? ?? 0,
      data: data is Map<String, dynamic>
          ? GstinDetails.fromJson(data)
          : GstinDetails.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  final bool success;
  final bool cached;
  final int creditsRemaining;
  final GstinDetails data;
}

/// Verified GSTIN business details (legal name, address, status, etc.).
class GstinDetails {
  const GstinDetails({
    required this.gstin,
    required this.legalName,
    required this.tradeName,
    required this.status,
    required this.constitution,
    required this.taxpayerType,
    required this.registrationDate,
    required this.state,
    required this.pan,
    required this.address,
    required this.natureOfBusiness,
  });

  factory GstinDetails.fromJson(Map<String, dynamic> json) {
    final nature = json['nature_of_business'];
    return GstinDetails(
      gstin: json['gstin'] as String? ?? '',
      legalName: json['legal_name'] as String? ?? '',
      tradeName: json['trade_name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      constitution: json['constitution'] as String? ?? '',
      taxpayerType: json['taxpayer_type'] as String? ?? '',
      registrationDate: json['registration_date'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pan: json['pan'] as String? ?? '',
      address: json['address'] as String? ?? '',
      natureOfBusiness: nature is List
          ? nature.map((item) => item.toString()).toList()
          : const [],
    );
  }

  final String gstin;
  final String legalName;
  final String tradeName;
  final String status;
  final String constitution;
  final String taxpayerType;
  final String registrationDate;
  final String state;
  final String pan;
  final String address;
  final List<String> natureOfBusiness;
}
