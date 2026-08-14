import 'package:billing_baba/features/business/models/create_business_request.dart';

class CreateBusinessInput {
  const CreateBusinessInput({
    required this.name,
    required this.ownerName,
    required this.phone,
    required this.businessType,
    required this.state,
    required this.currency,
    this.email = '',
    this.gstin = '',
    this.address = '',
    this.businessCategory = '',
  });

  final String name;
  final String ownerName;
  final String phone;
  final String email;
  final String gstin;
  final String businessType;
  final String state;
  final String currency;
  final String address;
  final String businessCategory;

  CreateBusinessRequest toRequest() {
    return CreateBusinessRequest(
      name: name.trim(),
      ownerName: ownerName.trim(),
      phone: phone.trim(),
      email: email.trim(),
      gstin: gstin.trim().toUpperCase(),
      businessType: businessType,
      businessCategory: businessCategory,
      state: state,
      currency: currency,
      address: address.trim(),
    );
  }
}
