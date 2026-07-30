import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/logging_service.dart';

/// Temporary diagnostics for business open/switch flow.
abstract final class BusinessOpenDebugLog {
  static void log(String message) {
    if (!AppConfig.consoleVerbose) return;
    LoggingService.instance.debug('[BUSINESS_OPEN] $message');
  }

  static void step(String step, [String? detail]) {
    if (detail == null || detail.isEmpty) {
      log('→ $step');
      return;
    }
    log('→ $step: $detail');
  }
}
