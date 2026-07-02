import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/auth/models/otp_phase.dart';
import 'package:flutter/foundation.dart';

/// Logs OTP/auth phase transitions only (no duplicate SDK dumps).
abstract final class AuthFlowLogger {
  static bool get enabled => AppConfig.authDebugLogging;

  static OtpPhase? _lastOtpPhase;

  static void otpTransition(OtpPhase phase) {
    if (!enabled) return;
    if (_lastOtpPhase == phase) return;
    if (_lastOtpPhase != null) {
      debugPrint('[AUTH_FLOW] ${_lastOtpPhase!.name} → ${phase.name}');
    } else {
      debugPrint('[AUTH_FLOW] → ${phase.name}');
    }
    _lastOtpPhase = phase;
  }

  static void authStatus(String status) {
    if (!enabled) return;
    debugPrint('[AUTH_FLOW] AuthStatus → $status');
  }

  static void reset() {
    _lastOtpPhase = null;
  }
}
