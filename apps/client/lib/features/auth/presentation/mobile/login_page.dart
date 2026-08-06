import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/auth/presentation/desktop/widgets/network_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mobile login — full-bleed, minimal composition (no floating card).
class MobileLoginPage extends ConsumerStatefulWidget {
  const MobileLoginPage({super.key});

  @override
  ConsumerState<MobileLoginPage> createState() => _MobileLoginPageState();
}

class _MobileLoginPageState extends ConsumerState<MobileLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).sendOtp(_phoneController.text.trim());
  }

  Future<void> _devLogin() async {
    await ref.read(authProvider.notifier).devLogin();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isDevLoginLoading =
        auth.isBackendLogin && auth.status == AuthStatus.unauthenticated;
    final isOtpFlowLoading =
        auth.isSendingOtp ||
        (auth.isBackendLogin && auth.status == AuthStatus.otpSent);
    final canSend = auth.canSendOtp && !isOtpFlowLoading && !isDevLoginLoading;
    final showDevLogin = AppConfig.enableDevLogin;
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.lg,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: AppSpacing.lg),
                            const _BrandHeader(),
                            const SizedBox(height: AppSpacing.xxl),
                            Text(
                              'Welcome',
                              style: AppTypography.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.2,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Enter your mobile number to continue.',
                              style: AppTypography.inter(
                                fontSize: AppTypography.bodySize,
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            Text(
                              'Phone number',
                              style: AppTypography.inter(
                                fontSize: AppTypography.bodySize,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _PhoneField(
                              controller: _phoneController,
                              focusNode: _phoneFocus,
                              enabled: !isOtpFlowLoading && !isDevLoginLoading,
                              onSubmitted: (_) => _submit(),
                            ),
                            if (auth.error != null ||
                                auth.networkError != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              NetworkErrorBanner(
                                errorMessage: auth.error,
                                networkError: auth.networkError,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                            _ContinueButton(
                              loading: isOtpFlowLoading,
                              enabled: canSend,
                              onPressed: _submit,
                            ),
                            if (showDevLogin) ...[
                              const SizedBox(height: AppSpacing.md),
                              _DevLoginButton(
                                loading: isDevLoginLoading,
                                onPressed: _devLogin,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const _LegalFooter(),
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
        RichText(
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
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      style: AppTypography.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.4,
      ),
      decoration: InputDecoration(
        hintText: '10-digit mobile number',
        hintStyle: AppTypography.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary.withValues(alpha: 0.55),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+91',
                style: AppTypography.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 1,
                height: 22,
                color: const Color(0xFFE2E8F0),
              ),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 18,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().length != 10) {
          return 'Enter a valid 10-digit mobile number';
        }
        return null;
      },
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: AppTypography.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

class _DevLoginButton extends StatelessWidget {
  const _DevLoginButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: loading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey.shade600,
                ),
              )
            : Text(
                'Developer login',
                style: AppTypography.inter(
                  fontSize: AppTypography.bodySize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Text.rich(
        TextSpan(
          style: AppTypography.inter(
            fontSize: AppTypography.captionSize,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms',
              style: AppTypography.inter(
                fontSize: AppTypography.captionSize,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const TextSpan(text: ' & '),
            TextSpan(
              text: 'Privacy Policy',
              style: AppTypography.inter(
                fontSize: AppTypography.captionSize,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
