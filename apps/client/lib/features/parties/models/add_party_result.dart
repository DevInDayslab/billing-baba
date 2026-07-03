/// Data captured from the Add Party dialog on save.
class AddPartyResult {
  const AddPartyResult({
    required this.partyName,
    this.gstin = '',
    this.phone = '',
    this.gstType = 'Unregistered/Consumer',
    this.state = 'Andhra Pradesh',
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
    this.openingBalance = '',
    this.openingBalanceAsOfDate,
    this.loyaltyPointsOpeningBalance = '',
    this.loyaltyPointsAsOfDate,
    this.hasCustomCreditLimit = false,
    this.creditLimit = '',
    this.additionalField1Enabled = false,
    this.additionalField1 = '',
    this.additionalField2Enabled = false,
    this.additionalField2 = '',
  });

  final String partyName;
  final String gstin;
  final String phone;
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
}
