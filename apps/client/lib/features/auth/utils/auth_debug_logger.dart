import 'package:billing_baba/core/config/app_config.dart';
import 'package:flutter/foundation.dart';

/// Auth-flow debug logging. Never logs full tokens or secrets.
abstract final class AuthDebugLogger {
  static bool get enabled => AppConfig.authDebugLogging;

  static void log(String message) {
    if (!enabled) return;
    debugPrint('[AUTH_DEBUG] $message');
  }

  static void widgetInitialized({
    required String widgetId,
    required String platform,
  }) {
    log('Widget initialized');
    log('Widget ID: ${_mask(widgetId, visibleEnd: 4)}');
    log('SDK platform: $platform');
  }

  static void sendOtp({
    required String maskedPhone,
    required String reqId,
  }) {
    log('sendOTP phone=$maskedPhone reqId=${_mask(reqId, visibleEnd: 6)}');
  }

  static void logSdkResponse(String step, Map<String, dynamic>? response) {
    if (!enabled || response == null) return;

    final buffer = StringBuffer()
      ..writeln('======== MSG91 $step RESPONSE ========');
    for (final entry in response.entries) {
      final value = _formatValue(entry.key, entry.value);
      buffer.writeln('${entry.key} : $value');
    }
    buffer.writeln('=======================================');
    debugPrint(buffer.toString());
  }

  static void accessTokenReceived(String token) {
    log('Access token received: ${_mask(token, visibleEnd: 8)}');
  }

  static void backendLoginSuccess() {
    log('Backend login succeeded');
  }

  static void jwtIssued(String accessToken) {
    log('JWT issued: ${_mask(accessToken, visibleEnd: 8)}');
  }

  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return '****';
    return '******${digits.substring(digits.length - 4)}';
  }

  static String _mask(String value, {required int visibleEnd}) {
    if (value.length <= visibleEnd) return '****';
    return '${'*' * (value.length - visibleEnd)}${value.substring(value.length - visibleEnd)}';
  }

  static String _formatValue(String key, Object? value) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('token') ||
        lowerKey.contains('auth') ||
        lowerKey == 'message' && value is String && value.contains('.')) {
      if (value is String) {
        return _mask(value, visibleEnd: 8);
      }
    }
    return '$value';
  }
}
