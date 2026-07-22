class CreatePartyRequest {
  const CreatePartyRequest({
    required this.name,
    required this.mobile,
    this.legalName,
    this.alias,
    this.additionalPhones = const [],
    this.email,
    this.gstin,
    this.partyType = 'customer',
    this.partyCategory,
    this.partyGroup,
    this.areaCode,
    this.pricingTier = 'tier_1',
    this.state,
    this.stateCode,
    this.areaId,
    this.creditLimit,
    this.openingBalance,
    this.notes,
    this.currency,
    this.isActive = true,
  });

  final String name;
  final String mobile;
  final String? legalName;
  final String? alias;
  final List<String> additionalPhones;
  final String? email;
  final String? gstin;
  final String partyType;
  final String? partyCategory;
  final String? partyGroup;
  final String? areaCode;
  final String pricingTier;
  final String? state;
  final String? stateCode;
  final String? areaId;
  final String? creditLimit;
  final String? openingBalance;
  final String? notes;
  final String? currency;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'name': name,
    'mobile': mobile,
    if (legalName != null && legalName!.isNotEmpty) 'legal_name': legalName,
    if (alias != null && alias!.isNotEmpty) 'alias': alias,
    if (additionalPhones.isNotEmpty) 'additional_phones': additionalPhones,
    if (email != null && email!.isNotEmpty) 'email': email,
    if (gstin != null && gstin!.isNotEmpty) 'gstin': gstin,
    'party_type': partyType,
    if (partyCategory != null) 'party_category': partyCategory,
    if (partyGroup != null && partyGroup!.isNotEmpty)
      'party_group': partyGroup,
    if (areaCode != null && areaCode!.isNotEmpty) 'area_code': areaCode,
    'pricing_tier': pricingTier,
    if (state != null && state!.isNotEmpty) 'state': state,
    if (stateCode != null && stateCode!.isNotEmpty) 'state_code': stateCode,
    if (areaId != null) 'area_id': areaId,
    if (creditLimit != null && creditLimit!.isNotEmpty)
      'credit_limit': creditLimit,
    if (openingBalance != null && openingBalance!.isNotEmpty)
      'opening_balance': openingBalance,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    if (currency != null && currency!.isNotEmpty) 'currency': currency,
    'is_active': isActive,
  };
}

class UpdatePartyRequest {
  const UpdatePartyRequest({
    this.name,
    this.mobile,
    this.legalName,
    this.alias,
    this.additionalPhones,
    this.email,
    this.gstin,
    this.partyType,
    this.partyCategory,
    this.partyGroup,
    this.areaCode,
    this.pricingTier,
    this.state,
    this.stateCode,
    this.areaId,
    this.creditLimit,
    this.openingBalance,
    this.notes,
    this.currency,
    this.isActive,
  });

  final String? name;
  final String? mobile;
  final String? legalName;
  final String? alias;
  final List<String>? additionalPhones;
  final String? email;
  final String? gstin;
  final String? partyType;
  final String? partyCategory;
  final String? partyGroup;
  final String? areaCode;
  final String? pricingTier;
  final String? state;
  final String? stateCode;
  final String? areaId;
  final String? creditLimit;
  final String? openingBalance;
  final String? notes;
  final String? currency;
  final bool? isActive;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (mobile != null) json['mobile'] = mobile;
    if (legalName != null) json['legal_name'] = legalName;
    if (alias != null) json['alias'] = alias;
    if (additionalPhones != null) {
      json['additional_phones'] = additionalPhones;
    }
    if (email != null) json['email'] = email;
    if (gstin != null) json['gstin'] = gstin;
    if (partyType != null) json['party_type'] = partyType;
    if (partyCategory != null) json['party_category'] = partyCategory;
    if (partyGroup != null) json['party_group'] = partyGroup;
    if (areaCode != null) json['area_code'] = areaCode;
    if (pricingTier != null) json['pricing_tier'] = pricingTier;
    if (state != null) json['state'] = state;
    if (stateCode != null) json['state_code'] = stateCode;
    if (areaId != null) json['area_id'] = areaId;
    if (creditLimit != null) json['credit_limit'] = creditLimit;
    if (openingBalance != null) json['opening_balance'] = openingBalance;
    if (notes != null) json['notes'] = notes;
    if (currency != null) json['currency'] = currency;
    if (isActive != null) json['is_active'] = isActive;
    return json;
  }
}
