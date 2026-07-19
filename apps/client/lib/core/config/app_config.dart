import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment-specific application configuration.
abstract final class AppConfig {
  static const appName = 'Billing Baba';

  static const _defaultApiBaseUrl =
      'https://billing-baba-production-6b5e.up.railway.app';

  static const _defaultWebsiteUrl = 'https://billingbaba.com';

  /// Resolved at runtime: `--dart-define=API_BASE_URL` overrides `.env`.
  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromEnv = dotenv.env['API_BASE_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return _defaultApiBaseUrl;
  }

  /// Where [apiBaseUrl] was resolved from (for startup diagnostics).
  static String get apiBaseUrlSource {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return 'dart-define';
    final fromEnv = dotenv.env['API_BASE_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return '.env';
    return 'default';
  }

  /// When true, shows the local-only developer login button on the login screen.
  static bool get enableDevLogin =>
      dotenv.env['ENABLE_DEV_LOGIN']?.toLowerCase() == 'true';

  /// When true, shows Developer menu in the app shell (debug / dev profile).
  static bool get showDeveloperMenu => kDebugMode || enableDevLogin;

  /// Verbose auth/MSG91 logging in development builds.
  static bool get authDebugLogging =>
      kDebugMode ||
      dotenv.env['DEBUG']?.toLowerCase() == 'true' ||
      dotenv.env['APP_ENV']?.toLowerCase() == 'development';

  /// Public website base URL used for collaboration invite links.
  static String get websiteUrl {
    const fromDefine = String.fromEnvironment('WEBSITE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromEnv = dotenv.env['WEBSITE_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return _defaultWebsiteUrl;
  }

  /// Builds `https://example.com/invite/{code}` from [inviteCode].
  static String inviteLinkForCode(String inviteCode) {
    final base = websiteUrl.replaceAll(RegExp(r'/+$'), '');
    return '$base/invite/$inviteCode';
  }

  /// Default OTP for local development when MSG91 is not configured.
  static String get devOtp => dotenv.env['DEV_OTP']?.trim() ?? '123456';

  /// Prints resolved config once at startup when debug logging is enabled.
  static void logStartupConfig() {
    if (!authDebugLogging) return;
    debugPrint(
      '[CONFIG] API_BASE_URL=$apiBaseUrl (source: $apiBaseUrlSource)',
    );
    debugPrint('[CONFIG] WEBSITE_URL=$websiteUrl');
    debugPrint('[CONFIG] ENABLE_DEV_LOGIN=$enableDevLogin');
    debugPrint('[CONFIG] APP_ENV=${dotenv.env['APP_ENV'] ?? '(unset)'}');
    debugPrint('[CONFIG] DEBUG=${dotenv.env['DEBUG'] ?? '(unset)'}');
    debugPrint('[CONFIG] DEV_OTP=${'*' * devOtp.length}');
  }
}
