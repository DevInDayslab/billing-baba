import 'package:billing_baba/core/network/api_error_parser.dart';
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
      ApiErrorParser.errorMessage(error) ?? error.message ?? 'Request failed',
      code: ApiErrorParser.errorCode(error),
    );
  }

  return SalesException(error.toString());
}
