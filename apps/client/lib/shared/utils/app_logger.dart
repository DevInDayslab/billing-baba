import 'package:billing_baba/core/logging/logging_service.dart';

/// Lightweight application logger — delegates to [LoggingService].
abstract final class AppLogger {
  static void debug(String message) {
    LoggingService.instance.debug(message);
  }

  static void info(String message) {
    LoggingService.instance.info(message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    LoggingService.instance.error(message, error, stackTrace);
  }
}
