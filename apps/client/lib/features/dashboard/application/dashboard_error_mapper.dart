import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/offline_utils.dart';
import 'package:dio/dio.dart';

class DashboardException implements Exception {
  const DashboardException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

DashboardException mapDashboardError(Object error) {
  if (error is DioException) {
    final code = ApiErrorParser.errorCode(error);
    final message =
        ApiErrorParser.errorMessage(error) ?? error.message ?? 'Request failed';
    return DashboardException(message, code: code);
  }
  if (error is DashboardException) return error;
  return DashboardException(error.toString());
}

abstract final class DashboardErrorMapper {
  static String messageFor(Object error) {
    if (isOfflineError(error)) return OfflineMessages.connectToInternet;
    if (error is DashboardException) return error.message;
    return mapDashboardError(error).message;
  }
}
