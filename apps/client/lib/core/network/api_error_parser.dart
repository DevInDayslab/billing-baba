import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:dio/dio.dart';

abstract final class ApiErrorParser {
  static ApiValidationException? parseValidation(DioException error) {
    final data = error.response?.data;
    if (data is! Map<String, dynamic>) return null;

    final envelope = _readErrorEnvelope(data);
    final code = envelope?['code']?.toString() ?? data['code']?.toString();
    final rawErrors = envelope?['details'] ?? data['errors'];
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

    final message =
        envelope?['message']?.toString() ??
        data['message']?.toString() ??
        'Validation failed';
    return ApiValidationException(message: message, fieldErrors: fieldErrors);
  }

  static String? errorCode(DioException error) {
    final data = error.response?.data;
    if (data is! Map<String, dynamic>) return null;
    final envelope = _readErrorEnvelope(data);
    return envelope?['code']?.toString() ?? data['code']?.toString();
  }

  static String? errorMessage(DioException error) {
    final data = error.response?.data;
    if (data is! Map<String, dynamic>) return null;
    final envelope = _readErrorEnvelope(data);
    return envelope?['message']?.toString() ?? data['message']?.toString();
  }

  static Map<String, dynamic>? _readErrorEnvelope(Map<String, dynamic> data) {
    final nested = data['error'];
    if (nested is Map<String, dynamic>) return nested;
    return null;
  }
}
