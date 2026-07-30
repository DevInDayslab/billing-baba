import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/network_exception_classifier.dart';
import 'package:dio/dio.dart';

/// User-facing copy for offline-first UX. Never expose raw transport errors.
abstract final class OfflineUiMessages {
  static const workingOffline =
      "You're offline. Working locally — your changes are saved and will sync automatically once you're connected again.";

  static const syncWhenOnline =
      'Changes will sync automatically when you reconnect.';

  static const noLocalDataYet =
      'No local data available yet. Connect to the internet once to download this information.';

  static const dashboardNeedsNetwork =
      'Dashboard summaries need an internet connection. Your invoices, items, and parties remain available offline.';

  static const reportsNeedNetwork =
      'Reports need an internet connection. Your transactions are still saved locally.';

  static String messageFor(Object error) {
    if (error is DioException) {
      if (ApiErrorParser.isOffline(error)) {
        return workingOffline;
      }
      final api = ApiErrorParser.errorMessage(error);
      if (api != null && api.isNotEmpty && !_looksTechnical(api)) {
        return api;
      }
      return 'Unable to reach the server. Please try again.';
    }

    final classified = NetworkExceptionClassifier.classify(error);
    if (_isOfflineReason(classified.reason)) {
      return workingOffline;
    }

    final details = classified.details.trim();
    if (details.isNotEmpty && !_looksTechnical(details)) {
      return details;
    }

    return 'Something went wrong. Please try again.';
  }

  static bool isOfflineError(Object error) {
    if (error is DioException) return ApiErrorParser.isOffline(error);
    final classified = NetworkExceptionClassifier.classify(error);
    return _isOfflineReason(classified.reason);
  }

  static bool _isOfflineReason(String? reason) {
    return switch (reason) {
      'Network Error' => true,
      'Connection refused' => true,
      'Server Timeout' => true,
      'DNS Failure' => true,
      _ => false,
    };
  }

  static bool _looksTechnical(String value) {
    final lower = value.toLowerCase();
    return lower.contains('dioexception') ||
        lower.contains('socketexception') ||
        lower.contains('connection refused') ||
        lower.contains('localhost') ||
        lower.contains('failed host lookup') ||
        lower.contains('os error');
  }
}
