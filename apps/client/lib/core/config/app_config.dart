import 'package:billing_baba/core/config/api_base_url_resolver.dart';
import 'package:billing_baba/core/logging/log_level.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment-specific application configuration.
abstract final class AppConfig {
  static const appName = 'Billing Baba';

  /// Filesystem folder for local logs and app data (no spaces).
  static const dataDirectoryName = 'BillingBaba';

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

  /// When true, logs are written to a local rotating file on disk.
  ///
  /// Defaults to `true` on desktop; set `FILE_LOGGING=false` to disable.
  static bool get fileLoggingEnabled {
    final fromEnv = dotenv.env['FILE_LOGGING']?.toLowerCase().trim();
    if (fromEnv == 'false' || fromEnv == '0') return false;
    if (fromEnv == 'true' || fromEnv == '1') return true;
    return !kIsWeb && AppPlatform.current.isDesktop;
  }

  /// Minimum severity written to the log file.
  ///
  /// Set via `LOG_LEVEL` (`debug`, `info`, `warn`, `error`). Defaults to
  /// `debug` when [consoleVerbose], otherwise `info`.
  static LogLevel get minLogLevel {
    final parsed = LogLevel.tryParse(dotenv.env['LOG_LEVEL']);
    if (parsed != null) return parsed;
    return consoleVerbose ? LogLevel.debug : LogLevel.info;
  }

  /// Whether [level] meets the configured [minLogLevel] threshold.
  static bool shouldLog(LogLevel level) => level.index >= minLogLevel.index;

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

  static String get _websiteBase => websiteUrl.replaceAll(RegExp(r'/+$'), '');

  /// Product documentation / features overview on the public site.
  static String get documentationUrl => '$_websiteBase/features';

  /// Contact / support page on the public site.
  static String get contactSupportUrl => '$_websiteBase/contact';

  /// Privacy policy page on the public site.
  static String get privacyPolicyUrl => '$_websiteBase/privacy';

  /// Support inbox for issue reports and mailto: actions.
  static const supportEmail = 'support@billingbaba.com';

  /// Builds `https://example.com/invite/{code}` from [inviteCode].
  static String inviteLinkForCode(String inviteCode) {
    return '$_websiteBase/invite/$inviteCode';
  }

  /// Default OTP for local development when MSG91 is not configured.
  static String get devOtp => dotenv.env['DEV_OTP']?.trim() ?? '123456';

  /// Shows sync diagnostics dropdown (cursor, queue internals, view logs).
  static bool get showSyncDiagnostics =>
      showDeveloperMenu || diagnosticsEnabled;

  /// Native Razorpay SDK on mobile (default true on Android/iOS).
  static bool get razorpayNative =>
      dotenv.env['RAZORPAY_NATIVE']?.toLowerCase() != 'false';

  /// WebView Razorpay fallback when native SDK cannot initialize.
  static bool get razorpayWebViewFallback =>
      dotenv.env['RAZORPAY_WEBVIEW_FALLBACK']?.toLowerCase() == 'true';

  /// Enables pending-verification recovery on app resume / reconnect.
  static bool get paymentRecoveryEnabled =>
      dotenv.env['PAYMENT_RECOVERY_ENABLED']?.toLowerCase() != 'false';

  /// Poll backend status when local verification is pending.
  static bool get paymentWebhookRecovery =>
      dotenv.env['PAYMENT_WEBHOOK_RECOVERY']?.toLowerCase() != 'false';

  /// Verbose payment gateway analytics logs (never secrets).
  static bool get paymentLoggingVerbose =>
      consoleVerbose ||
      dotenv.env['PAYMENT_LOGGING_VERBOSE']?.toLowerCase() == 'true';

  /// Checkout session timeout in seconds.
  static int get paymentCheckoutTimeoutSeconds =>
      int.tryParse(dotenv.env['PAYMENT_CHECKOUT_TIMEOUT'] ?? '') ?? 900;

  /// Verification API timeout in seconds.
  static int get paymentVerificationTimeoutSeconds =>
      int.tryParse(dotenv.env['PAYMENT_VERIFY_TIMEOUT'] ?? '') ?? 30;

  /// Recovery poll interval while verification is pending.
  static Duration get paymentRecoveryPollInterval => Duration(
    minutes: int.tryParse(dotenv.env['PAYMENT_RECOVERY_POLL_MINUTES'] ?? '') ?? 5,
  );

  /// Logs resolved config once at startup (console when verbose, file per [minLogLevel]).
  static void logStartupConfig() {
    if (!consoleVerbose && !shouldLog(LogLevel.info)) return;
    LoggingService.instance.info(
      '[CONFIG] API_BASE_URL=$apiBaseUrl (source: $apiBaseUrlSource)',
    );
    LoggingService.instance.info('[CONFIG] WEBSITE_URL=$websiteUrl');
    LoggingService.instance.info('[CONFIG] ENABLE_DEV_LOGIN=$enableDevLogin');
    LoggingService.instance.info(
      '[CONFIG] APP_ENV=${dotenv.env['APP_ENV'] ?? '(unset)'}',
    );
    LoggingService.instance.info(
      '[CONFIG] DEBUG=${dotenv.env['DEBUG'] ?? '(unset)'}',
    );
    LoggingService.instance.info('[CONFIG] DEV_OTP=${'*' * devOtp.length}');
    LoggingService.instance.info('[CONFIG] GIT_COMMIT=$gitCommit');
    LoggingService.instance.info(
      '[CONFIG] FILE_LOGGING=$fileLoggingEnabled LOG_LEVEL=${minLogLevel.name}',
    );
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
