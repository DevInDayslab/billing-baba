import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:dio/dio.dart';

class ReportsException implements Exception {
  const ReportsException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

ReportsException mapReportsError(Object error) {
  if (error is DioException) {
    final code = ApiErrorParser.errorCode(error);
    final message =
        ApiErrorParser.errorMessage(error) ?? error.message ?? 'Request failed';
    return ReportsException(message, code: code);
  }
  if (error is ReportsException) return error;
  return ReportsException(error.toString());
}

abstract final class ReportsErrorMapper {
  static String messageFor(Object error) {
    if (error is ReportsException) return error.message;
    return mapReportsError(error).message;
  }
}
