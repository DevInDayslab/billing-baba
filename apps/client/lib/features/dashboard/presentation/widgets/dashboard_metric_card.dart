import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';

class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    required this.child,
    this.onTap,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;

  static const borderColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(DashboardSpacing.cardPadding),
        child: child,
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: card,
      ),
    );
  }
}
