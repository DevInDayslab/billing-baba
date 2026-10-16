import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/providers/async_provider_guard.dart';
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
    if (ApiErrorParser.isOffline(error)) {
      return const ReportsException(
        OfflineUiMessages.reportsNeedNetwork,
        code: 'OFFLINE',
      );
    }
    final code = ApiErrorParser.errorCode(error);
    final message =
        ApiErrorParser.errorMessage(error) ?? 'Unable to load report.';
    return ReportsException(message, code: code);
  }
  if (error is ReportsException) return error;
  if (OfflineUiMessages.isOfflineError(error)) {
    return const ReportsException(
      OfflineUiMessages.reportsNeedNetwork,
      code: 'OFFLINE',
    );
  }
  return ReportsException(OfflineUiMessages.messageFor(error));
}

abstract final class ReportsErrorMapper {
  static String messageFor(Object error) {
    if (error is ReportsException) return error.message;
    return mapReportsError(error).message;
  }

  /// Brief Riverpod invalidation races while opening reports — not real failures.
  static bool isTransientLoadError(Object error) {
    return isAsyncProviderStaleError(error);
  }
}
