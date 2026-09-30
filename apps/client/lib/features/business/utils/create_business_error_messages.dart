import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:dio/dio.dart';

/// Maps create-business failures to clear, user-facing copy.
abstract final class CreateBusinessErrorMessages {
  static String fromError(Object error) {
    if (error is BusinessOfflineException) {
      return 'You are offline. Business creation has been queued and will sync when you reconnect.';
    }

    if (error is BusinessSelectionFailed) {
      return _businessSelectionFailedMessage(error.message);
    }

    if (error is ApiValidationException) {
      if (error.fieldErrors.isNotEmpty) {
        return error.fieldErrors.values.first;
      }
      return error.message;
    }

    if (error is DioException) {
      return _fromDio(error);
    }

    return 'Could not create the business. Please try again.';
  }

  static String _fromDio(DioException error) {
    if (ApiErrorParser.isOffline(error)) {
      return OfflineUiMessages.workingOffline;
    }

    final validation = ApiErrorParser.parseValidation(error);
    if (validation != null && validation.fieldErrors.isNotEmpty) {
      return validation.fieldErrors.values.first;
    }

    final code = ApiErrorParser.errorCode(error);
    final status = error.response?.statusCode;

    switch (code) {
      case 'UNAUTHORIZED':
      case 'INVALID_TOKEN':
      case 'TOKEN_EXPIRED':
        return 'Your session expired. Sign in again and try again.';
      case 'RATE_LIMITED':
      case 'SERVER_BUSY':
        return 'Our servers are busy. Wait a moment and try again.';
      case 'INTERNAL_SERVER_ERROR':
        return _serverFailureMessage();
      default:
        break;
    }

    final message = ApiErrorParser.errorMessage(error);
    if (message != null &&
        message.isNotEmpty &&
        message != 'An unexpected error occurred' &&
        message != 'Invalid request body') {
      return message;
    }

    if (status != null && status >= 500) {
      return _serverFailureMessage();
    }
    if (status == 401 || status == 403) {
      return 'You do not have permission to create a business. Sign in again and try again.';
    }

    return 'Could not create the business. Check your details and try again.';
  }

  static String _serverFailureMessage() {
    return 'Billing Baba could not finish creating the business on our servers. '
        'Wait a minute and try again. If it keeps happening, contact support.';
  }

  static String _businessSelectionFailedMessage(String raw) {
    final message = raw.trim();
    const genericFallbacks = {
      '',
      'Could not select business',
      'Could not select business. Please try again.',
      'Something went wrong. Please try again.',
    };
    if (genericFallbacks.contains(message)) {
      return _createdButNotOpenedMessage();
    }

    final lower = message.toLowerCase();
    if (lower.contains('invalid refresh token') ||
        lower.contains('session expired') ||
        lower.contains('sign in again')) {
      return 'Your business was created, but your session expired before we could '
          'open it. Sign in again and select it from your company list.';
    }

    if (message.startsWith('Your business was created')) {
      return message;
    }

    return 'Your business was created, but we could not open it automatically. '
        '$message Open it from your company list if it is not already open.';
  }

  static String _createdButNotOpenedMessage() {
    return 'Your business was created, but we could not open it automatically. '
        'Sign in again if needed, then open it from your company list.';
  }
}
