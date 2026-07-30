import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:dio/dio.dart';

class SalesException implements Exception {
  const SalesException(this.message, {this.code, this.fieldErrors});

  final String message;
  final String? code;
  final Map<String, List<String>>? fieldErrors;

  @override
  String toString() => message;
}

class SalesOfflineException extends SalesException {
  const SalesOfflineException(super.message);
}

SalesException mapSalesError(Object error) {
  if (error is DioException) {
    if (ApiErrorParser.isOffline(error)) {
      return const SalesOfflineException(OfflineUiMessages.workingOffline);
    }

    final validation = ApiErrorParser.parseValidation(error);
    if (validation != null) {
      return SalesException(
        validation.message,
        code: 'VALIDATION_ERROR',
        fieldErrors: validation.fieldErrors.map(
          (key, value) => MapEntry(key, [value]),
        ),
      );
    }

    return SalesException(
      ApiErrorParser.userFacingMessage(error),
      code: ApiErrorParser.errorCode(error),
    );
  }

  if (error is SalesException) return error;
  if (OfflineUiMessages.isOfflineError(error)) {
    return const SalesOfflineException(OfflineUiMessages.workingOffline);
  }

  return SalesException(OfflineUiMessages.messageFor(error));
}

abstract final class SalesErrorMapper {
  static String messageFor(Object error) {
    if (error is SalesException) return error.message;
    return mapSalesError(error).message;
  }
}
