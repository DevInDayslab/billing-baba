import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:dio/dio.dart';

abstract final class ApiErrorParser {
  static ApiValidationException? parseValidation(DioException error) {
    final data = error.response?.data;
    if (data is! Map<String, dynamic>) return null;

    final code = data['code']?.toString();
    final rawErrors = data['errors'];
    if (code != 'VALIDATION_ERROR' || rawErrors is! Map) return null;

    final fieldErrors = <String, String>{};
    for (final entry in rawErrors.entries) {
      final messages = entry.value;
      if (messages is List && messages.isNotEmpty) {
        fieldErrors[entry.key.toString()] = messages.first.toString();
      } else if (messages is String && messages.isNotEmpty) {
        fieldErrors[entry.key.toString()] = messages;
      }
    }

    if (fieldErrors.isEmpty) return null;

    final message = data['message']?.toString() ?? 'Validation failed';
    return ApiValidationException(message: message, fieldErrors: fieldErrors);
  }
}
