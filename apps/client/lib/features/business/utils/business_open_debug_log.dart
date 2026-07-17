import 'package:flutter/foundation.dart';

/// Temporary diagnostics for business open/switch flow.
abstract final class BusinessOpenDebugLog {
  static void log(String message) {
    debugPrint('[BUSINESS_OPEN] $message');
  }

  static void step(String step, [String? detail]) {
    if (detail == null || detail.isEmpty) {
      log('→ $step');
      return;
    }
    log('→ $step: $detail');
  }
}
