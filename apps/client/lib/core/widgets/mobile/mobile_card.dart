import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Rounded surface container for mobile cards and grouped content.
class MobileCard extends StatelessWidget {
  const MobileCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.selected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final resolvedBorderColor = selected
        ? AppColors.primary
        : (borderColor ?? const Color(0xFFE8EAED));

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(
          color: resolvedBorderColor,
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: selected ? 0.08 : 0.04),
            blurRadius: selected ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgBorder,
        child: card,
      ),
    );
  }
}
