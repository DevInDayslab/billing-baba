import 'dart:ui';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shared mobile auth chrome (login + OTP) — backdrop, brand, glass card, CTA.
class MobileAuthBackdrop extends StatelessWidget {
  const MobileAuthBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEDE8FF),
            Color(0xFFF4F7FF),
            Color(0xFFFAFBFE),
            AppColors.surface,
          ],
          stops: [0, 0.22, 0.55, 1],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: _GlowOrb(
              size: 260,
              color: AppColors.primary.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            top: 48,
            left: -90,
            child: _GlowOrb(
              size: 200,
              color: AppColors.accent.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -40,
            child: _GlowOrb(
              size: 140,
              color: AppColors.secondary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class MobileAuthBrandHero extends StatelessWidget {
  const MobileAuthBrandHero({
    this.showFeaturePills = true,
    this.showTagline = true,
    super.key,
  });

  final bool showFeaturePills;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final logoWidth = (MediaQuery.sizeOf(context).width - AppSpacing.xl * 2)
        .clamp(100.0, 140.0);

    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo.png',
            width: logoWidth,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Billing & inventory for your business',
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              fontSize: AppTypography.bodySize,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
        if (showFeaturePills) ...[
          const SizedBox(height: AppSpacing.md),
          const _HeroFeaturePills(),
        ],
      ],
    );
  }
}

class _HeroFeaturePills extends StatelessWidget {
  const _HeroFeaturePills();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _FeaturePill(icon: LucideIcons.package, label: 'Inventory control'),
        _FeaturePill(icon: LucideIcons.receipt, label: 'GST billing'),
        _FeaturePill(icon: LucideIcons.scanBarcode, label: 'POS ready'),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class MobileAuthGlassCard extends StatelessWidget {
  const MobileAuthGlassCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.65),
            ),
            boxShadow: AppShadows.elevated,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg + 2,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class MobileAuthGradientButton extends StatelessWidget {
  const MobileAuthGradientButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.loading = false,
    this.showArrow = true,
    super.key,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onPressed;
  final bool loading;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading && onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: active
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              )
            : null,
        color: active ? null : AppColors.primary.withValues(alpha: 0.4),
        boxShadow: active ? AppShadows.elevated : null,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: active ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
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
                    if (showArrow) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(LucideIcons.arrowRight, size: 20),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class MobileAuthShieldHint extends StatelessWidget {
  const MobileAuthShieldHint({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          LucideIcons.shieldCheck,
          size: 16,
          color: AppColors.textSecondary.withValues(alpha: 0.85),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            message,
            style: AppTypography.inter(
              fontSize: AppTypography.captionSize,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class MobileAuthBackButton extends StatelessWidget {
  const MobileAuthBackButton({
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: AppColors.surface.withValues(alpha: 0.65),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          onPressed: enabled ? onPressed : null,
          icon: const Icon(LucideIcons.arrowLeft, size: 22),
          color: AppColors.textPrimary,
          tooltip: 'Back',
        ),
      ),
    );
  }
}
