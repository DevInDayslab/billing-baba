import 'package:billing_baba/features/crm/domain/services/lead_service_types.dart';
import 'package:dio/dio.dart';

abstract final class LeadErrorMapper {
  static String messageFor(Object error) {
    if (error is LeadBusinessNotSelectedException) {
      return 'No business selected. Please select a business and try again.';
    }
    if (error is LeadValidationException) {
      return error.message;
    }
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) return 'Session expired. Please log in again.';
      if (statusCode == 403) return 'You do not have permission to view leads.';
      if (statusCode != null) {
        return 'Server error ($statusCode). Please try again.';
      }
      return 'Network error. Please check your connection.';
    }
    return 'Unable to load leads. Please try again.';
  }
}
