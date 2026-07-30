import 'package:billing_baba/features/crm/domain/services/contact_service_types.dart';

class ContactErrorMapper {
  const ContactErrorMapper._();

  static String messageFor(Object error) {
    if (error is ContactBusinessNotSelectedException) {
      return 'Select a business to view contacts.';
    }
    if (error is ContactValidationException) {
      return error.message;
    }
    return 'Unable to load contacts. Please try again.';
  }
}
