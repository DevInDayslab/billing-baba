import 'package:billing_baba/shared/utils/validators.dart';
import 'package:billing_baba/features/business/models/create_business_input.dart';

/// Client-side validation for the create-business form.
abstract final class CreateBusinessValidator {
  static Map<String, String> validate(CreateBusinessInput input) {
    final errors = <String, String>{};

    void add(String field, String? message) {
      if (message != null) errors[field] = message;
    }

    add('name', Validators.required(input.name, fieldName: 'Business name'));
    add(
      'owner_name',
      Validators.required(input.ownerName, fieldName: 'Owner name'),
    );
    add('phone', Validators.requiredPhone(input.phone));
    add('email', Validators.email(input.email));
    add('gstin', Validators.gstin(input.gstin));
    add(
      'business_type',
      Validators.requiredSelection(
        input.businessType,
        fieldName: 'Business type',
      ),
    );
    add(
      'state',
      Validators.requiredSelection(input.state, fieldName: 'State'),
    );
    add(
      'currency',
      Validators.requiredSelection(input.currency, fieldName: 'Currency'),
    );

    return errors;
  }
}
