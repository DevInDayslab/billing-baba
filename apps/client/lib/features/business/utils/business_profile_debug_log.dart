import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/logging_service.dart';

/// Temporary diagnostics for business profile update flow.
abstract final class BusinessProfileDebugLog {
  static bool get enabled => AppConfig.authDebugLogging;

  static void log(String message) {
    if (!enabled) return;
    LoggingService.instance.debug('[BUSINESS_PROFILE] $message');
  }

  static void section(String title) {
    log('── $title ──');
  }

  static String maskToken(String? token) {
    if (token == null || token.isEmpty) return '(empty)';
    if (token.length <= 12) return '***';
    return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }

  static Map<String, String> sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, String>{};
    for (final entry in headers.entries) {
      final key = entry.key;
      final value = entry.value?.toString() ?? '';
      if (key.toLowerCase() == 'authorization') {
        sanitized[key] = value.startsWith('Bearer ')
            ? 'Bearer ${maskToken(value.substring(7))}'
            : maskToken(value);
      } else {
        sanitized[key] = value;
      }
    }
    return sanitized;
  }
}
