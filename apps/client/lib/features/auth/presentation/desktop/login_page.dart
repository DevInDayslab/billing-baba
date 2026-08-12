import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/network/network_error_details.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/auth/presentation/desktop/widgets/network_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopLoginPage extends ConsumerStatefulWidget {
  const DesktopLoginPage({super.key});

  @override
  ConsumerState<DesktopLoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<DesktopLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).sendOtp(_phoneController.text.trim());
  }

  Future<void> _devLogin() async {
    debugPrint('[LOGIN] Developer Login button tapped');
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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top-left brand header ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Billing',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.2,
                              ),
                            ),
                            TextSpan(
                              text: 'Baba',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Centered card ──
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? AppSpacing.xxl : AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                      child: isDesktop
                          ? _DesktopCard(
                              formKey: _formKey,
                              phoneController: _phoneController,
                              isOtpFlowLoading: isOtpFlowLoading,
                              continueButtonLabel: continueButtonLabel,
                              isDevLoginLoading: isDevLoginLoading,
                              canSend: canSend,
                              errorMessage: auth.error,
                              networkError: auth.networkError,
                              showDevLogin: showDevLogin,
                              isReturningUser: isReturningUser,
                              rememberFor30Days: auth.rememberFor30Days,
                              onRememberChanged: (value) => ref
                                  .read(authProvider.notifier)
                                  .setRememberFor30Days(value: value),
                              onSubmit: _submit,
                              onDevLogin: _devLogin,
                            )
                          : _MobileCard(
                              formKey: _formKey,
                              phoneController: _phoneController,
                              isOtpFlowLoading: isOtpFlowLoading,
                              continueButtonLabel: continueButtonLabel,
                              isDevLoginLoading: isDevLoginLoading,
                              canSend: canSend,
                              errorMessage: auth.error,
                              networkError: auth.networkError,
                              showDevLogin: showDevLogin,
                              isReturningUser: isReturningUser,
                              rememberFor30Days: auth.rememberFor30Days,
                              onRememberChanged: (value) => ref
                                  .read(authProvider.notifier)
                                  .setRememberFor30Days(value: value),
                              onSubmit: _submit,
                              onDevLogin: _devLogin,
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Desktop: two-panel card with vertical divider
// ─────────────────────────────────────────────
class _DesktopCard extends StatelessWidget {
  const _DesktopCard({
    required this.formKey,
    required this.phoneController,
    required this.isOtpFlowLoading,
    required this.continueButtonLabel,
    required this.isDevLoginLoading,
    required this.canSend,
    required this.onSubmit,
    required this.isReturningUser,
    required this.rememberFor30Days,
    required this.onRememberChanged,
    this.errorMessage,
    this.networkError,
    this.showDevLogin = false,
    this.onDevLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final bool isOtpFlowLoading;
  final String continueButtonLabel;
  final bool isDevLoginLoading;
  final bool canSend;
  final String? errorMessage;
  final NetworkErrorDetails? networkError;
  final bool showDevLogin;
  final bool isReturningUser;
  final bool rememberFor30Days;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onSubmit;
  final VoidCallback? onDevLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1100,
      constraints: const BoxConstraints(maxWidth: 1100, minHeight: 580),
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left image panel
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/login.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            // Vertical divider
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Colors.grey.shade200,
            ),

            // Right form panel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: AppSpacing.xxl,
                ),
                child: _LoginForm(
                  formKey: formKey,
                  phoneController: phoneController,
                  isOtpFlowLoading: isOtpFlowLoading,
                  continueButtonLabel: continueButtonLabel,
                  isDevLoginLoading: isDevLoginLoading,
                  canSend: canSend,
                  errorMessage: errorMessage,
                  networkError: networkError,
                  showDevLogin: showDevLogin,
                  isReturningUser: isReturningUser,
                  rememberFor30Days: rememberFor30Days,
                  onRememberChanged: onRememberChanged,
                  onSubmit: onSubmit,
                  onDevLogin: onDevLogin,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mobile: single-panel card
// ─────────────────────────────────────────────
class _MobileCard extends StatelessWidget {
  const _MobileCard({
    required this.formKey,
    required this.phoneController,
    required this.isOtpFlowLoading,
    required this.continueButtonLabel,
    required this.isDevLoginLoading,
    required this.canSend,
    required this.onSubmit,
    required this.isReturningUser,
    required this.rememberFor30Days,
    required this.onRememberChanged,
    this.errorMessage,
    this.networkError,
    this.showDevLogin = false,
    this.onDevLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final bool isOtpFlowLoading;
  final String continueButtonLabel;
  final bool isDevLoginLoading;
  final bool canSend;
  final String? errorMessage;
  final NetworkErrorDetails? networkError;
  final bool showDevLogin;
  final bool isReturningUser;
  final bool rememberFor30Days;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onSubmit;
  final VoidCallback? onDevLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: _LoginForm(
        formKey: formKey,
        phoneController: phoneController,
        isOtpFlowLoading: isOtpFlowLoading,
        continueButtonLabel: continueButtonLabel,
        isDevLoginLoading: isDevLoginLoading,
        canSend: canSend,
        errorMessage: errorMessage,
        networkError: networkError,
        showDevLogin: showDevLogin,
        isReturningUser: isReturningUser,
        rememberFor30Days: rememberFor30Days,
        onRememberChanged: onRememberChanged,
        onSubmit: onSubmit,
        onDevLogin: onDevLogin,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared login form (right panel / mobile card)
// ─────────────────────────────────────────────
class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.phoneController,
    required this.isOtpFlowLoading,
    required this.continueButtonLabel,
    required this.isDevLoginLoading,
    required this.canSend,
    required this.onSubmit,
    required this.isReturningUser,
    required this.rememberFor30Days,
    required this.onRememberChanged,
    this.errorMessage,
    this.networkError,
    this.showDevLogin = false,
    this.onDevLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final bool isOtpFlowLoading;
  final String continueButtonLabel;
  final bool isDevLoginLoading;
  final bool canSend;
  final String? errorMessage;
  final NetworkErrorDetails? networkError;
  final bool showDevLogin;
  final bool isReturningUser;
  final bool rememberFor30Days;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onSubmit;
  final VoidCallback? onDevLogin;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isReturningUser ? 'Welcome Back' : 'Welcome',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Sign in to continue managing your business.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Phone number label
          const Text(
            'Phone Number',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Phone input
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter 10-digit number',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade200, width: 1.5),
                  ),
                ),
                child: const Text(
                  '+91',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 16,
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FF),
              border: OutlineInputBorder(
                borderRadius: AppRadius.mdBorder,
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdBorder,
                borderSide: BorderSide(color: Colors.grey.shade200),
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
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdBorder,
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().length != 10) {
                return 'Enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),

          if (errorMessage != null || networkError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            NetworkErrorBanner(
              errorMessage: errorMessage,
              networkError: networkError,
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          SizedBox(
            height: 40,
            child: CheckboxListTile(
              value: rememberFor30Days,
              onChanged: isOtpFlowLoading || isDevLoginLoading
                  ? null
                  : (value) => onRememberChanged(value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
              title: const Text(
                'Remember for 30 days',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Continue button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: canSend ? onSubmit : null,
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
              icon: isOtpFlowLoading
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
                continueButtonLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          if (showDevLogin) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Development Only',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: isDevLoginLoading ? null : onDevLogin,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorder,
                  ),
                ),
                icon: isDevLoginLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey.shade600,
                        ),
                      )
                    : const Icon(Icons.developer_mode_outlined, size: 18),
                label: Text(
                  isDevLoginLoading ? 'Signing in...' : 'Developer Login',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Secure login divider
          Row(
            children: [
              Expanded(
                child: Divider(color: Colors.grey.shade300, thickness: 1),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'SECURE LOGIN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Divider(color: Colors.grey.shade300, thickness: 1),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Footer note
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                children: [
                  TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
