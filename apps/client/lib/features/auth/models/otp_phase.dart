import 'package:billing_baba/features/auth/providers/auth_provider.dart'
    show AuthStatus;

/// OTP sub-flow phases inside [AuthStatus.otpSent] / login.
enum OtpPhase {
  idle,
  sendingOtp,
  otpSent,
  verifyingOtp,
  backendLogin,
  backendLoginFailed,
  error,
}

extension OtpPhaseX on OtpPhase {
  bool get isBusy =>
      this == OtpPhase.sendingOtp ||
      this == OtpPhase.verifyingOtp ||
      this == OtpPhase.backendLogin;

  bool get canVerify => this == OtpPhase.otpSent || this == OtpPhase.error;

  bool get canResend => this == OtpPhase.otpSent || this == OtpPhase.error;
}
