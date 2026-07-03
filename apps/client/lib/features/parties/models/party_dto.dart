/// API response DTO for a party record.
class PartyDto {
  factory PartyDto.fromJson(Map<String, dynamic> json) {
    return PartyDto(
      id: json['id'] as String,
      name: json['name'] as String,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      partyType: json['party_type'] as String? ?? 'customer',
      partyCategory: json['party_category'] as String?,
      pricingTier: json['pricing_tier'] as String? ?? 'tier_1',
      gstin: json['gstin'] as String?,
      stateCode: json['state_code'] as String?,
      state: json['state'] as String?,
      areaId: json['area_id'] as String?,
      creditLimit: json['credit_limit']?.toString() ?? '0',
      openingBalance: json['opening_balance']?.toString() ?? '0',
      balance: json['balance']?.toString() ?? '0',
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
  const PartyDto({
    required this.id,
    required this.name,
    this.mobile,
    this.email,
    required this.partyType,
    this.partyCategory,
    required this.pricingTier,
    this.gstin,
    this.stateCode,
    this.state,
    this.areaId,
    required this.creditLimit,
    required this.openingBalance,
    required this.balance,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? mobile;
  final String? email;
  final String partyType;
  final String? partyCategory;
  final String pricingTier;
  final String? gstin;
  final String? stateCode;
  final String? state;
  final String? areaId;
  final String creditLimit;
  final String openingBalance;
  final String balance;
  final bool isActive;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mobile': mobile,
    'email': email,
    'party_type': partyType,
    'party_category': partyCategory,
    'pricing_tier': pricingTier,
    'gstin': gstin,
    'state_code': stateCode,
    'state': state,
    'area_id': areaId,
    'credit_limit': creditLimit,
    'opening_balance': openingBalance,
    'balance': balance,
    'is_active': isActive,
    'notes': notes,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PaginatedPartiesDto {
  factory PaginatedPartiesDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return PaginatedPartiesDto(
      parties: data is List
          ? data.cast<Map<String, dynamic>>().map(PartyDto.fromJson).toList()
          : [],
      page: meta['page'] as int? ?? 1,
      limit: meta['limit'] as int? ?? 20,
      total: meta['total'] as int? ?? 0,
    );
  }
  const PaginatedPartiesDto({
    required this.parties,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<PartyDto> parties;
  final int page;
  final int limit;
  final int total;
}
