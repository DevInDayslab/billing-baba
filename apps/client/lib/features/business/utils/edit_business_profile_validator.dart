import 'package:billing_baba/core/utils/validators.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';

abstract final class EditBusinessProfileValidator {
  static Map<String, String> validate(UpdateBusinessProfileInput input) {
    final errors = <String, String>{};

    void add(String field, String? message) {
      if (message != null) errors[field] = message;
    }

    add('name', Validators.required(input.name, fieldName: 'Business name'));
    add('phone', Validators.phone(input.phone));
    add('email', Validators.email(input.email));
    add('gstin', Validators.gstinMaxLength(input.gstin));
    add('pincode', Validators.pincode(input.pincode));

    return errors;
  }
}
