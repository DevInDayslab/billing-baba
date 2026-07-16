import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';

class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    required this.child,
    this.onTap,
    this.padding,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  static const Color borderColor = DashboardColors.border;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: DashboardDecor.cardRadius,
        border: Border.all(color: borderColor),
        boxShadow: DashboardDecor.cardShadow,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.sm + 4),
        child: child,
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: DashboardDecor.cardRadius,
        child: card,
      ),
    );
  }
}
