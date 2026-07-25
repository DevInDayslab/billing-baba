import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/global_search_field.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/quick_create_menu.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_provider.dart';
import 'package:billing_baba/features/dashboard/application/shell_sidebar_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Shared shell header — search and quick actions on every page.
class AppTopBar extends ConsumerWidget {
  const AppTopBar({this.showMenuButton = false, super.key});

  final bool showMenuButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: DashboardSpacing.topBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;
          final isCompact = constraints.maxWidth < 900;

          if (isNarrow) {
            return Row(
              children: [
                if (showMenuButton) ...[
                  _TopBarIconButton(
                    tooltip: 'Open menu',
                    icon: Icons.menu,
                    onPressed: () =>
                        ref.read(shellSidebarProvider.notifier).openDrawer(),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                const Expanded(child: GlobalSearchField()),
                const SizedBox(width: AppSpacing.xs),
                const _TopBarActions(showQuickButtons: false),
              ],
            );
          }

          return Row(
            children: [
              if (showMenuButton) ...[
                _TopBarIconButton(
                  tooltip: 'Open menu',
                  icon: Icons.menu,
                  onPressed: () =>
                      ref.read(shellSidebarProvider.notifier).openDrawer(),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 320,
                      maxWidth: 600,
                    ),
                    child: const GlobalSearchField(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _TopBarActions(showQuickButtons: !isCompact),
            ],
          );
        },
      ),
    );
  }
}

class _TopBarActions extends ConsumerWidget {
  const _TopBarActions({this.showQuickButtons = true});

  final bool showQuickButtons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showQuickButtons) ...[
          _QuickActionButton(
            label: 'Add Sale',
            icon: Icons.add,
            backgroundColor: AppColors.error,
            onPressed: () => context.push(AppRoutes.addSale),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickActionButton(
            label: 'Add Purchase',
            icon: Icons.add,
            backgroundColor: AppColors.primary,
            onPressed: () => context.push(AppRoutes.addPurchase),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        const QuickCreateMenuButton(),
        const SizedBox(width: AppSpacing.xs),
        _TopBarIconButton(
          tooltip: 'Refresh',
          icon: Icons.refresh,
          onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
        ),
        _TopBarIconButton(
          tooltip: 'Cloud Sync',
          icon: Icons.cloud_done_outlined,
          iconColor: Colors.green.shade600,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
      onPressed: onPressed,
      padding: const EdgeInsets.all(AppSpacing.sm),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        minimumSize: const Size(0, 34),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
