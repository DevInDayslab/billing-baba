import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/auth/models/otp_phase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile OTP verification — full-bleed, scroll-safe, no fixed-width overflow.
class MobileVerifyOtpPage extends ConsumerStatefulWidget {
  const MobileVerifyOtpPage({super.key});

  @override
  ConsumerState<MobileVerifyOtpPage> createState() =>
      _MobileVerifyOtpPageState();
}

class _MobileVerifyOtpPageState extends ConsumerState<MobileVerifyOtpPage> {
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
    for (var i = 0; i < _otpLength; i++) {
      final index = i;
      _focusNodes[index].onKeyEvent = (node, event) => _onKey(index, event);
    }
    _startResendTicker();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
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

  void _applyOtpDigits(String digits, {required int startIndex}) {
    final cleaned = digits.replaceAll(RegExp(r'\D'), '');
    if (cleaned.isEmpty) return;

    var index = startIndex;
    for (final char in cleaned.split('')) {
      if (index >= _otpLength) break;
      if (char.isEmpty) continue;
      _controllers[index].text = char;
      index++;
    }

    final focusIndex = index.clamp(0, _otpLength - 1);
    _focusNodes[focusIndex].requestFocus();

    if (_otp.length == _otpLength) {
      final latest = ref.read(authProvider);
      if (latest.canVerifyOtp && !latest.isOtpBusy) {
        unawaited(_verify());
      }
    }
  }

  void _onDigitChanged(int index, String value) {
    final auth = ref.read(authProvider);
    if (auth.isOtpBusy) return;

    if (value.length > 1) {
      _applyOtpDigits(value, startIndex: index);
      return;
    }

    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_otp.length == _otpLength) {
      final latest = ref.read(authProvider);
      if (latest.canVerifyOtp && !latest.isOtpBusy) {
        unawaited(_verify());
      }
    }
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }
    if (_controllers[index].text.isNotEmpty) return KeyEventResult.ignored;
    if (index <= 0) return KeyEventResult.ignored;
    _focusNodes[index - 1].requestFocus();
    _controllers[index - 1].clear();
    return KeyEventResult.handled;
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
    if (context.canPop()) {
      context.pop();
    }
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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightSystemUi,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEAF2FB),
                AppColors.surface,
                AppColors.surface,
              ],
              stops: [0, 0.38, 1],
            ),
          ),
          child: SafeArea(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset > 0 ? 8 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: auth.isOtpBusy ? null : _goBackToLogin,
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Back',
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.sm,
                        AppSpacing.xl,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _BrandHeader(),
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            'Verify number',
                            style: AppTypography.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.2,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text.rich(
                            TextSpan(
                              style: AppTypography.inter(
                                fontSize: AppTypography.bodySize,
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Enter the 6-digit code sent to ',
                                ),
                                TextSpan(
                                  text: '+91 ${auth.phone}',
                                  style: AppTypography.inter(
                                    fontSize: AppTypography.bodySize,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isBackendLoginFailed) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed:
                                    auth.isOtpBusy ? null : _goBackToLogin,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Change number',
                                  style: AppTypography.inter(
                                    fontSize: AppTypography.bodySize,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          _OtpDigitRow(
                            length: _otpLength,
                            controllers: _controllers,
                            focusNodes: _focusNodes,
                            enabled: inputsEnabled,
                            onChanged: _onDigitChanged,
                          ),
                          if (auth.error != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              auth.error!,
                              textAlign: TextAlign.center,
                              style: AppTypography.inter(
                                fontSize: AppTypography.bodySize,
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          _PrimaryActions(
                            isBackendLoginFailed: isBackendLoginFailed,
                            isSigningIn: isSigningIn,
                            isVerifyingOtp: isVerifyingOtp,
                            canVerify: canVerify,
                            isOtpBusy: auth.isOtpBusy,
                            canRetry: auth.canRetryBackendLogin,
                            onBack: _goBackToLogin,
                            onRetry: _retryBackendLogin,
                            onVerify: _verify,
                          ),
                          if (auth.showResend) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _ResendSection(
                              isResending: isResending,
                              secondsLeft: resendSecondsLeft,
                              canResend: auth.canResendOtp,
                              onResend: _resend,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            'Secure verification',
                            textAlign: TextAlign.center,
                            style: AppTypography.inter(
                              fontSize: AppTypography.captionSize,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Billing',
                  style: AppTypography.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                TextSpan(
                  text: ' Baba',
                  style: AppTypography.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpDigitRow extends StatelessWidget {
  const _OtpDigitRow({
    required this.length,
    required this.controllers,
    required this.focusNodes,
    required this.enabled,
    required this.onChanged,
  });

  final int length;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool enabled;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth < 340 ? 6.0 : 8.0;
        final fontSize = constraints.maxWidth < 340 ? 18.0 : 22.0;

        return Row(
          children: [
            for (var i = 0; i < length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    maxHeight: 56,
                  ),
                  child: TextFormField(
                    controller: controllers[i],
                    focusNode: focusNodes[i],
                    enabled: enabled,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    textInputAction: i == length - 1
                        ? TextInputAction.done
                        : TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(length),
                    ],
                    style: AppTypography.inter(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    onChanged: (value) => onChanged(i, value),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions({
    required this.isBackendLoginFailed,
    required this.isSigningIn,
    required this.isVerifyingOtp,
    required this.canVerify,
    required this.isOtpBusy,
    required this.canRetry,
    required this.onBack,
    required this.onRetry,
    required this.onVerify,
  });

  final bool isBackendLoginFailed;
  final bool isSigningIn;
  final bool isVerifyingOtp;
  final bool canVerify;
  final bool isOtpBusy;
  final bool canRetry;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    if (isBackendLoginFailed) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: isOtpBusy ? null : onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Back',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inter(
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
              height: 54,
              child: FilledButton(
                onPressed: canRetry && !isOtpBusy ? onRetry : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.45),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Retry',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final label = isSigningIn
        ? 'Signing you in...'
        : (isVerifyingOtp ? 'Verifying...' : 'Verify OTP');
    final showSpinner = isSigningIn || isVerifyingOtp;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: canVerify ? onVerify : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: showSpinner
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}

class _ResendSection extends StatelessWidget {
  const _ResendSection({
    required this.isResending,
    required this.secondsLeft,
    required this.canResend,
    required this.onResend,
  });

  final bool isResending;
  final int secondsLeft;
  final bool canResend;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Didn't receive the code?",
          textAlign: TextAlign.center,
          style: AppTypography.inter(
            fontSize: AppTypography.bodySize,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (isResending)
          Text(
            'Sending OTP...',
            style: AppTypography.inter(
              fontSize: AppTypography.bodySize,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          )
        else if (secondsLeft > 0)
          Text(
            'Resend OTP in ${secondsLeft}s',
            style: AppTypography.inter(
              fontSize: AppTypography.bodySize,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          )
        else
          TextButton(
            onPressed: canResend ? onResend : null,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Resend OTP',
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                fontWeight: FontWeight.w600,
                color: canResend ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
