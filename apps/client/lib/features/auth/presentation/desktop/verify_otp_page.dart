import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/models/otp_phase.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DesktopVerifyOtpPage extends ConsumerStatefulWidget {
  const DesktopVerifyOtpPage({super.key});

  @override
  ConsumerState<DesktopVerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends ConsumerState<DesktopVerifyOtpPage> {
  static const _otpLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  Timer? _resendTicker;

  @override
  void initState() {
    super.initState();
    _startResendTicker();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  void _startResendTicker() {
    _resendTicker?.cancel();
    _resendTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.showResend && auth.resendAvailableAt != null) {
        setState(() {});
      }
    });
  }

  void _stopResendTicker() {
    _resendTicker?.cancel();
    _resendTicker = null;
  }

  void _clearOtpFields() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
  }

  @override
  void dispose() {
    _stopResendTicker();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final auth = ref.read(authProvider);
    if (!auth.canVerifyOtp || auth.isOtpBusy || _otp.length < _otpLength) {
      return;
    }
    await ref.read(authProvider.notifier).verifyOtp(_otp);
  }

  void _onDigitChanged(int index, String value) {
    final auth = ref.read(authProvider);
    if (auth.isOtpBusy) return;

    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == _otpLength) {
      final latest = ref.read(authProvider);
      if (latest.canVerifyOtp && !latest.isOtpBusy) {
        unawaited(_verify());
      }
    }
  }

  Future<void> _resend() async {
    final auth = ref.read(authProvider);
    if (!auth.canResendOtp || auth.isOtpBusy) return;
    await ref.read(authProvider.notifier).resendOtp();
  }

  Future<void> _retryBackendLogin() async {
    final auth = ref.read(authProvider);
    if (!auth.canRetryBackendLogin || auth.isOtpBusy) return;
    await ref.read(authProvider.notifier).retryBackendLogin();
  }

  void _goBackToLogin() {
    _stopResendTicker();
    ref.read(authProvider.notifier).resetToLogin();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref
      ..listen<bool>(
        authProvider.select((s) => s.showResend),
        (previous, next) {
          if (next) {
            _startResendTicker();
          } else {
            _stopResendTicker();
          }
        },
      )
      ..listen<int>(
        authProvider.select((s) => s.otpSessionVersion),
        (previous, next) {
          if (previous != null && previous != next) {
            _clearOtpFields();
          }
        },
      );

    final canVerify =
        auth.canVerifyOtp && !auth.isOtpBusy && _otp.length == _otpLength;
    final isVerifyingOtp = auth.otpPhase == OtpPhase.verifyingOtp;
    final isSigningIn = auth.isBackendLogin;
    final isBackendLoginFailed = auth.isBackendLoginFailed;
    final isResending = auth.isSendingOtp && auth.status == AuthStatus.otpSent;
    final resendSecondsLeft = auth.resendSecondsLeft;
    final inputsEnabled = !auth.isOtpBusy && !isBackendLoginFailed;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              width: 440,
              constraints: const BoxConstraints(maxWidth: 440),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Billing',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'Baba',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'SIMPLIFY . BILL . GROW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const Divider(),
                  const SizedBox(height: AppSpacing.xxl),
                  const Text(
                    'Verify Your Mobile Number',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'Enter 6-digit code sent to '),
                        TextSpan(
                          text: '+91 ${auth.phone}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (!isBackendLoginFailed)
                    TextButton(
                      onPressed: auth.isOtpBusy ? null : _goBackToLogin,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Change Number',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_otpLength, (i) {
                      return SizedBox(
                        width: 48,
                        height: 56,
                        child: TextFormField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          enabled: inputsEnabled,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.mdBorder,
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mdBorder,
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mdBorder,
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mdBorder,
                              borderSide: const BorderSide(
                                color: AppColors.error,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FF),
                          ),
                          onChanged: (v) => _onDigitChanged(i, v),
                        ),
                      );
                    }),
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      auth.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  if (isBackendLoginFailed) ...[
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: auth.isOtpBusy ? null : _goBackToLogin,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mdBorder,
                                ),
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed:
                                  auth.canRetryBackendLogin && !auth.isOtpBusy
                                  ? _retryBackendLogin
                                  : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.primary
                                    .withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mdBorder,
                                ),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (isSigningIn)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdBorder,
                          ),
                        ),
                        iconAlignment: IconAlignment.end,
                        icon: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                        label: const Text(
                          'Signing you in...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: canVerify ? _verify : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdBorder,
                          ),
                        ),
                        iconAlignment: IconAlignment.end,
                        icon: isVerifyingOtp
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                        label: Text(
                          isVerifyingOtp ? 'Verifying...' : 'Verify OTP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (auth.showResend) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      "Didn't receive the code?",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isResending)
                      const Text(
                        'Sending OTP...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (resendSecondsLeft > 0)
                      Text(
                        'Resend OTP in ${resendSecondsLeft}s',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: auth.canResendOtp ? _resend : null,
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: auth.canResendOtp
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'SECURE VERIFICATION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
