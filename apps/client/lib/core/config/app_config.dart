import 'package:billing_baba/core/config/api_base_url_resolver.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment-specific application configuration.
abstract final class AppConfig {
  static const appName = 'Billing Baba';

  static const _defaultApiBaseUrl =
      'https://billing-baba-production-6b5e.up.railway.app';

  static const _defaultWebsiteUrl = 'https://billingbaba.com';

  static String? _resolvedApiBaseUrl;
  static bool _initialized = false;

  /// Call once after [dotenv.load] to resolve platform-aware API URL.
  static Future<void> initialize() async {
    if (_initialized) return;
    final raw = _readRawApiBaseUrl();
    _resolvedApiBaseUrl = await ApiBaseUrlResolver.resolve(raw);
    _initialized = true;
    _logApiBaseUrl();
  }

  static String _readRawApiBaseUrl() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromEnv = dotenv.env['API_BASE_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return _defaultApiBaseUrl;
  }

  /// Resolved at runtime: `--dart-define=API_BASE_URL` overrides `.env`.
  static String get apiBaseUrl => _resolvedApiBaseUrl ?? _readRawApiBaseUrl();

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

  /// Verbose auth/MSG91 logging — opt-in via env, not enabled by default in debug.
  static bool get authDebugLogging => consoleVerbose;

  /// Verbose console/file diagnostics (HTTP traces, image cache, temp debug helpers).
  ///
  /// Set `VERBOSE_LOGGING=true` or `DEBUG=true` in `.env` when debugging.
  static bool get consoleVerbose =>
      dotenv.env['VERBOSE_LOGGING']?.toLowerCase() == 'true' ||
      dotenv.env['DEBUG']?.toLowerCase() == 'true' ||
      dotenv.env['APP_ENV']?.toLowerCase() == 'development' ||
      _isDiagnosticsAppEnv;

  /// Production-grade diagnostics for alpha, demo, and internal builds.
  static bool get diagnosticsEnabled => consoleVerbose || _isDiagnosticsAppEnv;

  static bool get _isDiagnosticsAppEnv {
    final env = dotenv.env['APP_ENV']?.toLowerCase();
    return env == 'alpha' || env == 'demo' || env == 'internal';
  }

  /// Shows detailed network error UI (View Details) in diagnostics builds.
  static bool get showDiagnosticsDetails => diagnosticsEnabled;

  /// Git commit from `--dart-define=GIT_COMMIT=...` (CI builds).
  static String get gitCommit {
    const fromDefine = String.fromEnvironment('GIT_COMMIT');
    if (fromDefine.isNotEmpty) return fromDefine;
    return '(unavailable)';
  }

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

  /// Prints resolved config once at startup.
  static void logStartupConfig() {
    if (!_initialized) {
      debugPrint(
        '[CONFIG] API_BASE_URL=$apiBaseUrl (source: $apiBaseUrlSource, '
        'platform-aware resolve pending)',
      );
    }
    if (!consoleVerbose) return;
    debugPrint('[CONFIG] WEBSITE_URL=$websiteUrl');
    debugPrint('[CONFIG] ENABLE_DEV_LOGIN=$enableDevLogin');
    debugPrint('[CONFIG] APP_ENV=${dotenv.env['APP_ENV'] ?? '(unset)'}');
    debugPrint('[CONFIG] DEBUG=${dotenv.env['DEBUG'] ?? '(unset)'}');
    debugPrint('[CONFIG] DEV_OTP=${'*' * devOtp.length}');
    debugPrint('[CONFIG] GIT_COMMIT=$gitCommit');
  }

  static void _logApiBaseUrl() {
    final platform = AppPlatform.current;
    final deviceKind = ApiBaseUrlResolver.deviceKind ?? 'unknown';
    final rewrite = ApiBaseUrlResolver.rewriteNote;
    debugPrint(
      '[CONFIG] API_BASE_URL=$apiBaseUrl (source: $apiBaseUrlSource, '
      'platform=${platform.os.name}, device=$deviceKind'
      '${rewrite != null ? ', rewrite: $rewrite' : ''})',
    );
  }

  static List<String> startupConfigLines() {
    return [
      'APP_ENV=${dotenv.env['APP_ENV'] ?? '(unset)'}',
      'DEBUG=${dotenv.env['DEBUG'] ?? '(unset)'}',
      'ENABLE_DEV_LOGIN=$enableDevLogin',
      'API_BASE_URL=$apiBaseUrl (source: $apiBaseUrlSource)',
      'WEBSITE_URL=$websiteUrl',
      'GIT_COMMIT=$gitCommit',
    ];
  }
}
