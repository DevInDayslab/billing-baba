import 'package:billing_baba/features/crm/domain/services/deal_service_types.dart';
import 'package:flutter/foundation.dart';

abstract final class DealErrorMapper {
  static String messageFor(Object error) {
    if (error is DealValidationException) return error.message;
    if (error is DealBusinessNotSelectedException) {
      return 'Select a business before managing deals.';
    }
    debugPrint('[DEAL_ERROR] $error');
    if (kDebugMode) {
      return 'Something went wrong. Please try again. ($error)';
    }
    return 'Something went wrong. Please try again.';
  }
}
