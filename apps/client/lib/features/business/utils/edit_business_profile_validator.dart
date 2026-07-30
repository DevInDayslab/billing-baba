import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/shared/utils/validators.dart';

abstract final class EditBusinessProfileValidator {
  static Map<String, String> validate(UpdateBusinessProfileInput input) {
    final errors = <String, String>{};

    void add(String field, String? message) {
      if (message != null) errors[field] = message;
    }

    add('name', Validators.businessName(input.name));
    add('phone', Validators.phone(input.phone));
    add('email', Validators.email(input.email));
    add('gstin', Validators.gstin(input.gstin));
    add('pincode', Validators.pincode(input.pincode));
    add('upi_id', Validators.upiId(input.upiId));

    return errors;
  }
}
