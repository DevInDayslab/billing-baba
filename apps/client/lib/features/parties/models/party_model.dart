import 'package:billing_baba/features/parties/models/add_party_result.dart';

class PartyModel {
  const PartyModel({
    required this.id,
    required this.name,
    required this.phone,
    this.balance = 0,
    this.isActive = true,
    this.gstin = '',
    this.gstType = '',
    this.state = '',
    this.email = '',
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
  });

  final String id;
  final String name;
  final String phone;

  /// Positive = amount to receive. Negative = amount to pay.
  final double balance;
  final bool isActive;
  final String gstin;
  final String gstType;
  final String state;
  final String email;
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

  bool get hasReceivable => balance > 0;
  bool get hasPayable => balance < 0;

  PartyModel copyWith({
    String? id,
    String? name,
    String? phone,
    double? balance,
    bool? isActive,
    String? gstin,
    String? gstType,
    String? state,
    String? email,
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
  }) {
    return PartyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      isActive: isActive ?? this.isActive,
      gstin: gstin ?? this.gstin,
      gstType: gstType ?? this.gstType,
      state: state ?? this.state,
      email: email ?? this.email,
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
      phone: result.phone.trim().isEmpty ? '+91 00000 00000' : result.phone.trim(),
      balance: openingBalance,
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
      additionalField1:
          result.additionalField1Enabled ? result.additionalField1.trim() : '',
      additionalField2:
          result.additionalField2Enabled ? result.additionalField2.trim() : '',
    );
  }
}
