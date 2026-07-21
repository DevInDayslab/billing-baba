import 'package:billing_baba/core/utils/validators.dart';
import 'package:billing_baba/features/parties/data/party_cache.dart';
import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/create_party_request.dart';
import 'package:billing_baba/features/parties/models/party_dto.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:intl/intl.dart';

class PartyModel {
  const PartyModel({
    required this.id,
    required this.name,
    required this.phone,
    this.partyType = 'customer',
    this.balance = 0,
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
      phone: _formatPhone(dto.mobile),
      partyType: dto.partyType,
      balance: balance,
      openingBalance: openingBalance,
      isActive: dto.isActive,
      gstin: dto.gstin ?? '',
      gstType: extension.gstType,
      state: dto.state ?? '',
      email: dto.email ?? '',
      notes: dto.notes ?? '',
      billingAddress: extension.billingAddress,
      shippingAddress: extension.shippingAddress,
      partyGroup: extension.partyGroup,
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
      phone:
          json['phone'] as String? ?? _formatPhone(json['mobile'] as String?),
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
      name: result.partyName.trim(),
      phone: result.phone.trim(),
      balance: openingBalance,
      openingBalance: openingBalance,
      gstin: result.gstin.trim(),
      gstType: result.gstType,
      state: result.state,
      email: result.email.trim(),
      billingAddress: result.billingAddress.trim(),
      shippingAddress: result.shippingAddress.trim(),
      partyGroup: result.partyGroup.trim(),
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
  final String phone;
  final String partyType;

  /// Positive = amount to receive. Negative = amount to pay.
  final double balance;
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

  /// Two-decimal string for numeric form fields.
  static String formatDecimalInput(double value) => value.toStringAsFixed(2);

  static String displayDate(DateTime? value) {
    if (value == null) return '—';
    return DateFormat('dd/MM/yyyy').format(value);
  }

  PartyModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? partyType,
    double? balance,
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
      phone: phone ?? this.phone,
      partyType: partyType ?? this.partyType,
      balance: balance ?? this.balance,
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

  static String? _optionalNormalizedPhone(String phone) {
    final normalized = normalizePhone(phone);
    return normalized.isEmpty ? null : normalized;
  }

  static String? _optionalNormalizedGstin(String gstin) {
    final trimmed = gstin.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.toUpperCase();
  }

  static CreatePartyRequest createRequestFromResult(AddPartyResult result) {
    return CreatePartyRequest(
      name: result.partyName.trim(),
      mobile: _optionalNormalizedPhone(result.phone),
      email: result.email.trim().isEmpty ? null : result.email.trim(),
      gstin: _optionalNormalizedGstin(result.gstin),
      partyType: result.partyType,
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
      name: result.partyName.trim(),
      mobile: _optionalNormalizedPhone(result.phone),
      email: result.email.trim().isEmpty ? null : result.email.trim(),
      gstin: _optionalNormalizedGstin(result.gstin),
      partyType: result.partyType,
      state: result.state.trim().isEmpty ? null : result.state.trim(),
      creditLimit: result.hasCustomCreditLimit
          ? Validators.normalizeDecimalString(result.creditLimit) ?? '0'
          : '0',
      openingBalance:
          Validators.normalizeDecimalString(result.openingBalance) ?? '0',
      isActive: isActive,
    );
  }
}
