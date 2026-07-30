import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/logging_service.dart';

/// Temporary diagnostics for the Switch Company navigation/loading flow.
///
/// Search logs for `[SWITCH_COMPANY]` while reproducing the flicker.
/// Opt in via `VERBOSE_LOGGING=true` in `.env`.
abstract final class SwitchCompanyDebugLog {
  static int _seq = 0;

  static void log(String message) {
    if (!AppConfig.consoleVerbose) return;
    _seq += 1;
    LoggingService.instance.debug('[SWITCH_COMPANY #$_seq] $message');
  }

  static void nav(String detail) => log('NAV $detail');

  static void action(String detail) => log('ACTION $detail');

  static void loading(String detail) => log('LOADING $detail');

  static void invalidate(String detail) => log('INVALIDATE $detail');

  static void api(String detail) => log('API $detail');

  static void lifecycle(String widget, String event, [String? detail]) {
    if (detail == null || detail.isEmpty) {
      log('LIFECYCLE $widget.$event');
      return;
    }
    log('LIFECYCLE $widget.$event: $detail');
  }
}
