import 'package:billing_baba/core/platform/external_links.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Login-style consent line with tappable Terms and Privacy links.
class LegalConsentFooter extends StatelessWidget {
  const LegalConsentFooter({
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.sm,
      AppSpacing.xl,
      AppSpacing.md,
    ),
    super.key,
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'By continuing, you agree to our ',
            style: _baseStyle,
            textAlign: TextAlign.center,
          ),
          _LegalInlineLink(
            label: 'Terms',
            onTap: () => openTermsOfService(context),
          ),
          Text(' & ', style: _baseStyle),
          _LegalInlineLink(
            label: 'Privacy Policy',
            onTap: () => openPrivacyPolicy(context),
          ),
        ],
      ),
    );
  }

  static TextStyle get _baseStyle => AppTypography.inter(
    fontSize: AppTypography.captionSize,
    color: AppColors.textSecondary,
    height: 1.45,
  );
}

/// Settings / About row of legal document links.
class LegalDocumentLinksRow extends StatelessWidget {
  const LegalDocumentLinksRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        _LegalInlineLink(
          label: 'Terms of Service',
          onTap: () => openTermsOfService(context),
        ),
        Text(
          '·',
          style: AppTypography.inter(
            fontSize: AppTypography.bodySmallSize,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
        ),
        _LegalInlineLink(
          label: 'Privacy Policy',
          onTap: () => openPrivacyPolicy(context),
        ),
      ],
    );
  }
}

class _LegalInlineLink extends StatelessWidget {
  const _LegalInlineLink({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Text(
            label,
            style:
                AppTypography.inter(
                  fontSize: AppTypography.captionSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.45,
                ).copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary.withValues(alpha: 0.35),
                ),
          ),
        ),
      ),
    );
  }
}
