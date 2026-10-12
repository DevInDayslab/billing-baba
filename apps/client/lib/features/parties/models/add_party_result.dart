import 'package:billing_baba/features/parties/models/party_additional_phone_detail.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';

/// Data captured from the Add Party dialog on save.
class AddPartyResult {
  const AddPartyResult({
    required this.partyName,
    this.legalName = '',
    this.alias = '',
    this.partyType = 'customer',
    this.gstin = '',
    this.phone = '',
    this.additionalPhones = const [],
    this.additionalPhoneDetails = const [],
    this.gstType = 'Unregistered/Consumer',
    this.state = 'Andhra Pradesh',
    this.email = '',
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
    this.openingBalance = '0.00',
    this.openingBalanceAsOfDate,
    this.loyaltyPointsOpeningBalance = '0.00',
    this.loyaltyPointsAsOfDate,
    this.hasCustomCreditLimit = false,
    this.creditLimit = '',
    this.additionalField1Enabled = false,
    this.additionalField1 = '',
    this.additionalField2Enabled = false,
    this.additionalField2 = '',
    this.additionalField3Enabled = false,
    this.additionalField3 = '',
    this.additionalField4Enabled = false,
    this.additionalField4 = '',
    this.defaultPriceTier = PriceTier.retail,
  });

  final String partyName;
  final String legalName;
  final String alias;
  final String partyType;
  final String gstin;
  final String phone;
  final List<String> additionalPhones;
  final List<PartyAdditionalPhoneDetail> additionalPhoneDetails;
  final String gstType;
  final String state;
  final String email;
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
  final String openingBalance;
  final DateTime? openingBalanceAsOfDate;
  final String loyaltyPointsOpeningBalance;
  final DateTime? loyaltyPointsAsOfDate;
  final bool hasCustomCreditLimit;
  final String creditLimit;
  final bool additionalField1Enabled;
  final String additionalField1;
  final bool additionalField2Enabled;
  final String additionalField2;
  final bool additionalField3Enabled;
  final String additionalField3;
  final bool additionalField4Enabled;
  final String additionalField4;
  final String defaultPriceTier;
}
