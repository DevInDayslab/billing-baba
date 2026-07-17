import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_side_widget.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/dashboard/providers/dashboard_widget_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardTabBar extends ConsumerWidget {
  const DashboardTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(dashboardActiveTabProvider);

    return Container(
      width: double.infinity,
      height: DashboardSpacing.tabBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final tab in DashboardHomeTab.values)
              _DashboardTabItem(
                label: tab.label,
                isActive: activeTab == tab,
                onTap: () =>
                    ref.read(dashboardActiveTabProvider.notifier).select(tab),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTabItem extends StatefulWidget {
  const _DashboardTabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_DashboardTabItem> createState() => _DashboardTabItemState();
}

class _DashboardTabItemState extends State<_DashboardTabItem> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: AppColors.background,
        child: Container(
          height: DashboardSpacing.tabBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: _hovered && !widget.isActive
                ? AppColors.background.withValues(alpha: 0.6)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: widget.isActive ? AppColors.error : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: DashboardTypography.tabLabel.copyWith(
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
              color: widget.isActive
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
