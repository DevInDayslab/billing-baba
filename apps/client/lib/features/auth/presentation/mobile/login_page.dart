import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/network/network_error_details.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/auth/presentation/desktop/widgets/network_error_banner.dart';
import 'package:billing_baba/features/auth/presentation/mobile/widgets/mobile_auth_layout.dart';
import 'package:billing_baba/shared/widgets/legal/legal_consent_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    final storage = ref.watch(storageServiceProvider).asData?.value;
    final isReturningUser =
        storage?.read(StorageKeys.hasLoggedInBefore) == 'true';
    final isDevLoginLoading =
        auth.isBackendLogin && auth.status == AuthStatus.unauthenticated;
    final isContinueLoading = auth.isSendingOtp || auth.isBackendLogin;
    final isOtpFlowLoading = isContinueLoading;
    final continueButtonLabel = auth.isSendingOtp
        ? 'Sending OTP...'
        : auth.isBackendLogin
        ? 'Signing in...'
        : 'Continue';
    final canSend = auth.canSendOtp && !isContinueLoading;
    final showDevLogin = AppConfig.enableDevLogin;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightSystemUi,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const MobileAuthBackdrop(),
            SafeArea(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: bottomInset > 0 ? 8 : 0),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xs,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const MobileAuthBrandHero(),
                      const SizedBox(height: AppSpacing.lg),
                      _LoginFormCard(
                        formKey: _formKey,
                        isReturningUser: isReturningUser,
                        phoneController: _phoneController,
                        phoneFocus: _phoneFocus,
                        phoneEnabled:
                            !isOtpFlowLoading && !isDevLoginLoading,
                        rememberChecked: auth.rememberFor30Days,
                        rememberEnabled:
                            !isOtpFlowLoading && !isDevLoginLoading,
                        onRememberChanged: (value) => ref
                            .read(authProvider.notifier)
                            .setRememberFor30Days(value: value),
                        showError:
                            auth.error != null || auth.networkError != null,
                        errorMessage: auth.error,
                        networkError: auth.networkError,
                        continueLoading: isOtpFlowLoading,
                        continueLabel: continueButtonLabel,
                        continueEnabled: canSend,
                        onContinue: _submit,
                        showDevLogin: showDevLogin,
                        devLoginLoading: isDevLoginLoading,
                        onDevLogin: _devLogin,
                      ),
                      const LegalConsentFooter(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          AppSpacing.lg,
                          0,
                          AppSpacing.md,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({
    required this.formKey,
    required this.isReturningUser,
    required this.phoneController,
    required this.phoneFocus,
    required this.phoneEnabled,
    required this.rememberChecked,
    required this.rememberEnabled,
    required this.onRememberChanged,
    required this.showError,
    required this.errorMessage,
    required this.networkError,
    required this.continueLoading,
    required this.continueLabel,
    required this.continueEnabled,
    required this.onContinue,
    required this.showDevLogin,
    required this.devLoginLoading,
    required this.onDevLogin,
  });

  final GlobalKey<FormState> formKey;
  final bool isReturningUser;
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final bool phoneEnabled;
  final bool rememberChecked;
  final bool rememberEnabled;
  final ValueChanged<bool> onRememberChanged;
  final bool showError;
  final String? errorMessage;
  final NetworkErrorDetails? networkError;
  final bool continueLoading;
  final String continueLabel;
  final bool continueEnabled;
  final VoidCallback onContinue;
  final bool showDevLogin;
  final bool devLoginLoading;
  final VoidCallback onDevLogin;

  @override
  Widget build(BuildContext context) {
    return MobileAuthGlassCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isReturningUser ? 'Welcome back' : 'Get started',
              style: AppTypography.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sign in with your mobile number.',
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Phone number',
              style: AppTypography.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PhoneField(
              controller: phoneController,
              focusNode: phoneFocus,
              enabled: phoneEnabled,
              onSubmitted: (_) => onContinue(),
            ),
            const SizedBox(height: AppSpacing.sm),
            const MobileAuthShieldHint(
              message: 'OTP is sent only to verify your number',
            ),
            const SizedBox(height: AppSpacing.md),
            _RememberRow(
              value: rememberChecked,
              enabled: rememberEnabled,
              onChanged: onRememberChanged,
            ),
            if (showError) ...[
              const SizedBox(height: AppSpacing.md),
              NetworkErrorBanner(
                errorMessage: errorMessage,
                networkError: networkError,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            MobileAuthGradientButton(
              loading: continueLoading,
              label: continueLabel,
              enabled: continueEnabled,
              onPressed: onContinue,
            ),
            if (showDevLogin) ...[
              const SizedBox(height: AppSpacing.sm),
              _DevLoginButton(
                loading: devLoginLoading,
                onPressed: onDevLogin,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RememberRow extends StatelessWidget {
  const _RememberRow({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onChanged(!value) : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: value ? AppColors.primary : AppColors.chipBorder,
                    width: 1.5,
                  ),
                ),
                child: value
                    ? const Icon(
                        LucideIcons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Remember this device for 30 days',
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodySize,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      autofillHints: const [AutofillHints.telephoneNumber],
      onFieldSubmitted: onSubmitted,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      style: AppTypography.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 1.2,
      ),
      decoration: InputDecoration(
        hintText: '10-digit number',
        hintStyle: AppTypography.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          letterSpacing: 0,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.phone,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
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
                color: AppColors.divider,
              ),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 16,
        ),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.chipBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.chipBorder),
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
          borderSide: const BorderSide(color: AppColors.chipBorder),
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
      height: 44,
      child: TextButton(
        onPressed: loading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textSecondary,
                ),
              )
            : Text(
                'Developer login',
                style: AppTypography.inter(
                  fontSize: AppTypography.captionSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}
