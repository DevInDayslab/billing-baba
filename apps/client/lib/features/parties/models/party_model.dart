import 'package:billing_baba/features/parties/data/party_cache.dart';
import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/create_party_request.dart';
import 'package:billing_baba/features/parties/models/party_additional_phone_detail.dart';
import 'package:billing_baba/features/parties/models/party_dto.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:intl/intl.dart';

/// Direction of a party's opening balance.
/// Stored as a signed amount: positive = receive, negative = pay.
enum OpeningBalanceDirection {
  toReceive,
  toPay;

  String get label => switch (this) {
    OpeningBalanceDirection.toReceive => 'To Receive',
    OpeningBalanceDirection.toPay => 'To Pay',
  };
}

class PartyModel {
  const PartyModel({
    required this.id,
    required this.name,
    required this.phone,
    this.legalName = '',
    this.alias = '',
    this.additionalPhones = const [],
    this.additionalPhoneDetails = const [],
    this.partyType = 'customer',
    this.balance = 0,
    this.unrecoveredAmount = 0,
    this.openingBalance = 0,
    this.isActive = true,
    this.gstin = '',
    this.gstType = '',
    this.state = '',
    this.email = '',
    this.notes = '',
    this.billingAddress = '',
    this.shippingAddress = '',
    this.partyGroup = '',
    this.areaCode = '',
    this.addressLine = '',
    this.city = '',
    this.pincode = '',
    this.country = 'India',
    this.shippingAddressLine = '',
    this.shippingCity = '',
    this.shippingPincode = '',
    this.shippingCountry = 'India',
    this.openingBalanceAsOfDate,
    this.loyaltyPointsOpeningBalance = '',
    this.loyaltyPointsAsOfDate,
    this.hasCustomCreditLimit = false,
    this.creditLimit = '',
    this.additionalField1 = '',
    this.additionalField2 = '',
    this.defaultPriceTier = PriceTier.retail,
    this.profileImageUrl,
    this.profileMediaAssetId,
    this.createdAt,
    this.updatedAt,
  });

  factory PartyModel.fromDto(
    PartyDto dto, {
    PartyLocalExtension extension = const PartyLocalExtension(),
  }) {
    final balance = double.tryParse(dto.balance) ?? 0;
    final openingBalance = double.tryParse(dto.openingBalance) ?? 0;
    final creditLimitValue = double.tryParse(dto.creditLimit) ?? 0;

    return PartyModel(
      id: dto.id,
      name: dto.name,
      legalName: dto.legalName ?? '',
      alias: dto.alias ?? '',
      phone: _formatPhone(dto.mobile),
      additionalPhones: _phonesFrom(
        dto.additionalPhones,
        extension.additionalPhones,
      ),
      additionalPhoneDetails: _additionalPhoneDetailsFrom(
        dto.additionalPhones,
        extension.additionalPhones,
        extension.additionalPhoneDetails,
      ),
      partyType: dto.partyType,
      balance: balance,
      unrecoveredAmount: dto.unrecoveredAmount,
      openingBalance: openingBalance,
      isActive: dto.isActive,
      gstin: dto.gstin ?? '',
      gstType: extension.gstType,
      state: dto.state ?? '',
      email: dto.email ?? '',
      notes: dto.notes ?? '',
      billingAddress: extension.billingAddress,
      shippingAddress: extension.shippingAddress,
      partyGroup: _resolvePartyGroup(dto.partyGroup, extension.partyGroup),
      areaCode: dto.areaCode ?? '',
      addressLine: extension.addressLine,
      city: extension.city,
      pincode: extension.pincode,
      country: extension.country,
      shippingAddressLine: extension.shippingAddressLine,
      shippingCity: extension.shippingCity,
      shippingPincode: extension.shippingPincode,
      shippingCountry: extension.shippingCountry,
      openingBalanceAsOfDate: extension.openingBalanceAsOfDate,
      loyaltyPointsOpeningBalance: extension.loyaltyPointsOpeningBalance,
      loyaltyPointsAsOfDate: extension.loyaltyPointsAsOfDate,
      hasCustomCreditLimit: creditLimitValue > 0,
      creditLimit: dto.creditLimit,
      additionalField1: extension.additionalField1,
      additionalField2: extension.additionalField2,
      defaultPriceTier: extension.defaultPriceTier.isNotEmpty
          ? PriceTier.normalizeTierKey(extension.defaultPriceTier)
          : PriceTier.normalizeTierKey(dto.pricingTier),
      profileImageUrl: dto.profileImageUrl,
      profileMediaAssetId: dto.profileMediaAssetId,
      createdAt: DateTime.tryParse(dto.createdAt),
      updatedAt: DateTime.tryParse(dto.updatedAt),
    );
  }

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      legalName: json['legal_name'] as String? ?? '',
      alias: json['alias'] as String? ?? '',
      phone:
          json['phone'] as String? ?? _formatPhone(json['mobile'] as String?),
      additionalPhones: json['additional_phones'] is List
          ? (json['additional_phones'] as List)
                .map((phone) => _formatPhone(phone.toString()))
                .where((phone) => phone.isNotEmpty)
                .toList()
          : const [],
      partyType: json['party_type'] as String? ?? 'customer',
      balance:
          (json['balance'] as num?)?.toDouble() ??
          double.tryParse(json['balance']?.toString() ?? '') ??
          0,
      openingBalance:
          (json['opening_balance'] as num?)?.toDouble() ??
          double.tryParse(json['opening_balance']?.toString() ?? '') ??
          0,
      isActive: json['is_active'] as bool? ?? true,
      gstin: json['gstin'] as String? ?? '',
      email: json['email'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      creditLimit: json['credit_limit']?.toString() ?? '',
      state: json['state'] as String? ?? '',
      hasCustomCreditLimit: (json['credit_limit']?.toString() ?? '0') != '0',
      profileImageUrl: json['profile_image_url'] as String?,
      profileMediaAssetId: json['profile_media_asset_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  factory PartyModel.fromAddPartyResult(
    AddPartyResult result, {
    required String id,
  }) {
    final openingBalance = double.tryParse(result.openingBalance) ?? 0;

    return PartyModel(
      id: id,
      name: _normalizedPartyName(result.partyName),
      legalName: _normalizedLegalName(result.legalName),
      alias: result.alias.trim(),
      phone: result.phone.trim(),
      additionalPhones: result.additionalPhones
          .map(_formatPhone)
          .where((phone) => phone.isNotEmpty)
          .toList(),
      additionalPhoneDetails: result.additionalPhoneDetails,
      partyType: result.partyType,
      balance: openingBalance,
      openingBalance: openingBalance,
      gstin: result.gstin.trim(),
      gstType: result.gstType,
      state: result.state,
      email: result.email.trim(),
      billingAddress: result.billingAddress.trim(),
      shippingAddress: result.shippingAddress.trim(),
      partyGroup: result.partyGroup.trim(),
      areaCode: result.areaCode.trim(),
      addressLine: result.addressLine.trim(),
      city: result.city.trim(),
      pincode: result.pincode.trim(),
      country: result.country,
      shippingAddressLine: result.shippingAddressLine.trim(),
      shippingCity: result.shippingCity.trim(),
      shippingPincode: result.shippingPincode.trim(),
      shippingCountry: result.shippingCountry,
      openingBalanceAsOfDate: result.openingBalanceAsOfDate,
      loyaltyPointsOpeningBalance: result.loyaltyPointsOpeningBalance.trim(),
      loyaltyPointsAsOfDate: result.loyaltyPointsAsOfDate,
      hasCustomCreditLimit: result.hasCustomCreditLimit,
      creditLimit: result.creditLimit.trim(),
      additionalField1: result.additionalField1Enabled
          ? result.additionalField1.trim()
          : '',
      additionalField2: result.additionalField2Enabled
          ? result.additionalField2.trim()
          : '',
      defaultPriceTier: result.defaultPriceTier,
    );
  }

  final String id;
  final String name;
  final String legalName;
  final String alias;
  final String phone;
  final List<String> additionalPhones;
  final List<PartyAdditionalPhoneDetail> additionalPhoneDetails;
  final String partyType;

  /// Positive = amount to receive. Negative = amount to pay.
  final double balance;
  final double unrecoveredAmount;
  final double openingBalance;
  final bool isActive;
  final String gstin;
  final String gstType;
  final String state;
  final String email;
  final String notes;
  final String billingAddress;
  final String shippingAddress;
  final String partyGroup;
  final String areaCode;
  final String addressLine;
  final String city;
  final String pincode;
  final String country;
  final String shippingAddressLine;
  final String shippingCity;
  final String shippingPincode;
  final String shippingCountry;
  final DateTime? openingBalanceAsOfDate;
  final String loyaltyPointsOpeningBalance;
  final DateTime? loyaltyPointsAsOfDate;
  final bool hasCustomCreditLimit;
  final String creditLimit;
  final String additionalField1;
  final String additionalField2;
  final String defaultPriceTier;
  final String? profileImageUrl;
  final String? profileMediaAssetId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasReceivable => balance > 0;
  bool get hasPayable => balance < 0;

  String get partyTypeLabel => switch (partyType) {
    'customer' => 'Customer',
    'supplier' => 'Supplier',
    'both' => 'Customer & Supplier',
    _ => partyType,
  };

  String get statusLabel => isActive ? 'Active' : 'Inactive';

  static String displayOrDash(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '—' : trimmed;
  }

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Always formats monetary values (including zero) as currency.
  static String formatCurrency(double value) => _currencyFormat.format(value);

  static String displayCurrency(double? value) => formatCurrency(value ?? 0);

  static String displayOutstanding(double balance) =>
      formatCurrency(balance.abs());

  static String displayCreditLimit({
    required bool hasCustomCreditLimit,
    required String creditLimit,
  }) {
    if (!hasCustomCreditLimit) return 'No Limit';
    final parsed = double.tryParse(creditLimit.replaceAll(',', '')) ?? 0;
    return formatCurrency(parsed);
  }

  /// Two-decimal string for numeric form fields (magnitude only).
  static String formatDecimalInput(double value) =>
      value.abs().toStringAsFixed(2);

  static OpeningBalanceDirection openingBalanceDirection(double signedBalance) {
    if (signedBalance < 0) return OpeningBalanceDirection.toPay;
    return OpeningBalanceDirection.toReceive;
  }

  /// Combines a non-negative magnitude with direction into a signed storage value.
  static String signedOpeningBalanceString({
    required String magnitude,
    required OpeningBalanceDirection direction,
  }) {
    final normalized = Validators.normalizeDecimalString(magnitude);
    if (normalized == null) return '0';
    final parsed = double.tryParse(normalized) ?? 0;
    if (parsed == 0) return '0';
    final signed = direction == OpeningBalanceDirection.toPay
        ? -parsed.abs()
        : parsed.abs();
    return Validators.normalizeDecimalString(signed.toStringAsFixed(2)) ?? '0';
  }

  static String displayOpeningBalance(double signedBalance) {
    if (signedBalance == 0) return displayCurrency(0);
    return '${openingBalanceDirection(signedBalance).label}: '
        '${displayOutstanding(signedBalance)}';
  }

  static String displayDate(DateTime? value) {
    if (value == null) return '—';
    return DateFormat('dd/MM/yyyy').format(value);
  }

  static String displayPhones(PartyModel party) {
    final phones = <String>[
      if (party.phone.trim().isNotEmpty) party.phone,
      ...party.additionalPhones,
    ];
    if (phones.isEmpty) return '—';
    return phones.join(', ');
  }

  /// True when legal name is present and differs from the display/party name.
  static bool hasDistinctLegalName(PartyModel party) {
    final legal = party.legalName.trim();
    if (legal.isEmpty) return false;
    return legal.toLowerCase() != party.name.trim().toLowerCase();
  }

  /// `Acme`, `Acme Pvt Ltd`, or `Acme (Acme Pvt Ltd)` when both differ.
  static String displayNameWithLegal(PartyModel party) {
    final name = party.name.trim();
    final legal = party.legalName.trim();
    if (name.isEmpty) return legal;
    if (!hasDistinctLegalName(party)) return name;
    return '$name ($legal)';
  }

  PartyModel copyWith({
    String? id,
    String? name,
    String? legalName,
    String? alias,
    String? phone,
    List<String>? additionalPhones,
    String? partyType,
    double? balance,
    double? unrecoveredAmount,
    double? openingBalance,
    bool? isActive,
    String? gstin,
    String? gstType,
    String? state,
    String? email,
    String? notes,
    String? billingAddress,
    String? shippingAddress,
    String? partyGroup,
    String? areaCode,
    String? addressLine,
    String? city,
    String? pincode,
    String? country,
    String? shippingAddressLine,
    String? shippingCity,
    String? shippingPincode,
    String? shippingCountry,
    DateTime? openingBalanceAsOfDate,
    String? loyaltyPointsOpeningBalance,
    DateTime? loyaltyPointsAsOfDate,
    bool? hasCustomCreditLimit,
    String? creditLimit,
    String? additionalField1,
    String? additionalField2,
    String? defaultPriceTier,
    String? profileImageUrl,
    String? profileMediaAssetId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearProfileImage = false,
  }) {
    return PartyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      legalName: legalName ?? this.legalName,
      alias: alias ?? this.alias,
      phone: phone ?? this.phone,
      additionalPhones: additionalPhones ?? this.additionalPhones,
      partyType: partyType ?? this.partyType,
      balance: balance ?? this.balance,
      unrecoveredAmount: unrecoveredAmount ?? this.unrecoveredAmount,
      openingBalance: openingBalance ?? this.openingBalance,
      isActive: isActive ?? this.isActive,
      gstin: gstin ?? this.gstin,
      gstType: gstType ?? this.gstType,
      state: state ?? this.state,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      partyGroup: partyGroup ?? this.partyGroup,
      areaCode: areaCode ?? this.areaCode,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      shippingAddressLine: shippingAddressLine ?? this.shippingAddressLine,
      shippingCity: shippingCity ?? this.shippingCity,
      shippingPincode: shippingPincode ?? this.shippingPincode,
      shippingCountry: shippingCountry ?? this.shippingCountry,
      openingBalanceAsOfDate:
          openingBalanceAsOfDate ?? this.openingBalanceAsOfDate,
      loyaltyPointsOpeningBalance:
          loyaltyPointsOpeningBalance ?? this.loyaltyPointsOpeningBalance,
      loyaltyPointsAsOfDate:
          loyaltyPointsAsOfDate ?? this.loyaltyPointsAsOfDate,
      hasCustomCreditLimit: hasCustomCreditLimit ?? this.hasCustomCreditLimit,
      creditLimit: creditLimit ?? this.creditLimit,
      additionalField1: additionalField1 ?? this.additionalField1,
      additionalField2: additionalField2 ?? this.additionalField2,
      defaultPriceTier: defaultPriceTier ?? this.defaultPriceTier,
      profileImageUrl: clearProfileImage
          ? null
          : (profileImageUrl ?? this.profileImageUrl),
      profileMediaAssetId: clearProfileImage
          ? null
          : (profileMediaAssetId ?? this.profileMediaAssetId),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<String> _phonesFrom(
    List<String> dtoPhones,
    List<String> extensionPhones,
  ) {
    final source = dtoPhones.isNotEmpty ? dtoPhones : extensionPhones;
    return source.map(_formatPhone).where((phone) => phone.isNotEmpty).toList();
  }

  static List<PartyAdditionalPhoneDetail> _additionalPhoneDetailsFrom(
    List<String> dtoPhones,
    List<String> extensionPhones,
    List<PartyAdditionalPhoneDetail> extensionDetails,
  ) {
    if (extensionDetails.isNotEmpty) {
      return extensionDetails;
    }
    return _phonesFrom(dtoPhones, extensionPhones)
        .map((phone) => PartyAdditionalPhoneDetail(phone: normalizePhone(phone)))
        .where((entry) => entry.phone.isNotEmpty)
        .toList();
  }

  static String _formatPhone(String? mobile) {
    if (mobile == null || mobile.isEmpty) return '';
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    return mobile;
  }

  static String normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  static String? _optionalNormalizedGstin(String gstin) {
    final trimmed = gstin.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.toUpperCase();
  }

  static String _resolvePartyGroup(String? apiValue, String localValue) {
    final api = apiValue?.trim() ?? '';
    if (api.isNotEmpty) return api;
    return localValue.trim();
  }

  static List<String> _normalizeAdditionalPhones(List<String> phones) {
    final seen = <String>{};
    final normalized = <String>[];
    for (final phone in phones) {
      final digits = normalizePhone(phone);
      if (digits.length != 10 || seen.contains(digits)) continue;
      seen.add(digits);
      normalized.add(digits);
    }
    return normalized;
  }

  static String _normalizedPartyName(String value) {
    return Validators.capitalizeFirstLetter(value);
  }

  static String _normalizedLegalName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return Validators.capitalizeFirstLetter(trimmed);
  }

  static String? _normalizedOptionalLegalName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return Validators.capitalizeFirstLetter(trimmed);
  }

  static CreatePartyRequest createRequestFromResult(AddPartyResult result) {
    final primaryMobile = normalizePhone(result.phone);
    return CreatePartyRequest(
      name: _normalizedPartyName(result.partyName),
      legalName: _normalizedOptionalLegalName(result.legalName),
      alias: result.alias.trim().isEmpty ? null : result.alias.trim(),
      mobile: primaryMobile,
      additionalPhones: _normalizeAdditionalPhones(result.additionalPhones),
      email: result.email.trim().isEmpty ? null : result.email.trim(),
      gstin: _optionalNormalizedGstin(result.gstin),
      partyType: result.partyType,
      partyGroup: result.partyGroup.trim().isEmpty
          ? null
          : result.partyGroup.trim(),
      areaCode: result.areaCode.trim().isEmpty ? null : result.areaCode.trim(),
      state: result.state.trim().isEmpty ? null : result.state.trim(),
      creditLimit: result.hasCustomCreditLimit
          ? Validators.normalizeDecimalString(result.creditLimit)
          : null,
      openingBalance: Validators.normalizeDecimalString(result.openingBalance),
      pricingTier: PriceTier.toApiTier(result.defaultPriceTier),
    );
  }

  static UpdatePartyRequest updateRequestFromResult(
    AddPartyResult result, {
    bool? isActive,
  }) {
    return UpdatePartyRequest(
      name: _normalizedPartyName(result.partyName),
      legalName: _normalizedLegalName(result.legalName),
      alias: result.alias.trim(),
      mobile: normalizePhone(result.phone),
      additionalPhones: _normalizeAdditionalPhones(result.additionalPhones),
      email: result.email.trim(),
      gstin: result.gstin.trim().isEmpty
          ? ''
          : result.gstin.trim().toUpperCase(),
      partyType: result.partyType,
      partyGroup: result.partyGroup.trim(),
      areaCode: result.areaCode.trim(),
      state: result.state.trim(),
      pricingTier: PriceTier.toApiTier(result.defaultPriceTier),
      creditLimit: result.hasCustomCreditLimit
          ? Validators.normalizeDecimalString(result.creditLimit)
          : '0',
      openingBalance:
          Validators.normalizeDecimalString(result.openingBalance) ?? '0',
      isActive: isActive,
    );
  }
}
