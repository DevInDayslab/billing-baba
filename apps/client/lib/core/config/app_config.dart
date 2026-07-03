import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment-specific application configuration.
abstract final class AppConfig {
  static const appName = 'Billing Baba';

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// When true, shows the local-only developer login button on the login screen.
  static bool get enableDevLogin =>
      dotenv.env['ENABLE_DEV_LOGIN']?.toLowerCase() == 'true';

  /// Verbose auth/MSG91 logging in development builds.
  static bool get authDebugLogging =>
      kDebugMode ||
      dotenv.env['DEBUG']?.toLowerCase() == 'true' ||
      dotenv.env['APP_ENV']?.toLowerCase() == 'development';

  /// Default OTP for local development when MSG91 is not configured.
  static String get devOtp => dotenv.env['DEV_OTP']?.trim() ?? '123456';
}
