import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/network/offline_ui_messages.dart';
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

  /// Maps API/business errors to user-facing copy.
  static String userFacingMessage(DioException error) {
    if (isOffline(error)) {
      return OfflineUiMessages.workingOffline;
    }

    final code = errorCode(error);
    final message = errorMessage(error);

    switch (code) {
      case 'BUSINESS_NOT_SELECTED':
        return 'No company is selected in your session. Open a company from the Company List, then try again.';
      case 'UNAUTHORIZED':
      case 'INVALID_TOKEN':
      case 'TOKEN_EXPIRED':
        return message ?? 'Your session expired. Please sign in again.';
      case 'VALIDATION_ERROR':
        return message ??
            'Some fields are invalid. Please review and try again.';
      default:
        break;
    }

    if (message != null && message.isNotEmpty) return message;

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return OfflineUiMessages.workingOffline;
    }

    return 'Unable to save business profile. Please try again.';
  }

  static bool isOffline(DioException error) {
    if (error.response != null) return false;
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.unknown;
  }

  /// First validation detail message when present.
  static String? firstValidationDetail(DioException error) {
    final validation = parseValidation(error);
    if (validation == null || validation.fieldErrors.isEmpty) return null;
    return validation.fieldErrors.values.first;
  }
}
