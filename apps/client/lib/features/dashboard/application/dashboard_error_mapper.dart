import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/offline_ui_messages.dart';
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
    if (ApiErrorParser.isOffline(error)) {
      return const DashboardException(
        OfflineUiMessages.dashboardNeedsNetwork,
        code: 'OFFLINE',
      );
    }
    final code = ApiErrorParser.errorCode(error);
    final message =
        ApiErrorParser.errorMessage(error) ?? 'Unable to load dashboard.';
    return DashboardException(message, code: code);
  }
  if (error is DashboardException) return error;
  if (OfflineUiMessages.isOfflineError(error)) {
    return const DashboardException(
      OfflineUiMessages.dashboardNeedsNetwork,
      code: 'OFFLINE',
    );
  }
  return DashboardException(OfflineUiMessages.messageFor(error));
}

abstract final class DashboardErrorMapper {
  static String messageFor(Object error) {
    if (error is DashboardException) return error.message;
    return mapDashboardError(error).message;
  }
}
