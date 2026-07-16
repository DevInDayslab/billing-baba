import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/company_menu_button.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/global_search_field.dart';
import 'package:billing_baba/features/dashboard/providers/dashboard_provider.dart';
import 'package:billing_baba/features/dashboard/providers/shell_sidebar_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppTopBar extends ConsumerWidget {
  const AppTopBar({
    required this.pageTitle,
    this.showMenuButton = false,
    this.isHomeRoute = false,
    super.key,
  });

  final String pageTitle;
  final bool showMenuButton;
  final bool isHomeRoute;

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
                if (!isHomeRoute)
                  Expanded(
                    child: Text(
                      pageTitle,
                      style: DashboardTypography.pageTitle.copyWith(fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const Spacer(),
                _TopBarActions(
                  isHomeRoute: isHomeRoute,
                  showQuickButtons: false,
                ),
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
              if (!isHomeRoute) ...[
                SizedBox(
                  width: isCompact ? 140 : 180,
                  child: Text(
                    pageTitle,
                    style: DashboardTypography.pageTitle.copyWith(
                      fontSize: isCompact ? 20 : 22,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
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
              _TopBarActions(
                isHomeRoute: isHomeRoute,
                showQuickButtons: !isCompact,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBarActions extends ConsumerWidget {
  const _TopBarActions({
    required this.isHomeRoute,
    this.showQuickButtons = true,
  });

  final bool isHomeRoute;
  final bool showQuickButtons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isHomeRoute && showQuickButtons) ...[
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
        ] else ...[
          const _QuickAddMenu(),
          const SizedBox(width: AppSpacing.xs),
        ],
        if (isHomeRoute) ...[
          const CompanyMenuButton(),
          const SizedBox(width: AppSpacing.xs),
        ],
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

class _QuickAddMenu extends StatefulWidget {
  const _QuickAddMenu();

  @override
  State<_QuickAddMenu> createState() => _QuickAddMenuState();
}

class _QuickAddMenuState extends State<_QuickAddMenu> {
  final _menuController = MenuController();

  static const _menuWidth = 230.0;

  static const _items = <_QuickAddItem>[
    _QuickAddItem(
      value: 'sale',
      label: 'Add Sale',
      icon: Icons.receipt_outlined,
      color: AppColors.error,
    ),
    _QuickAddItem(
      value: 'purchase',
      label: 'Add Purchase',
      icon: Icons.shopping_cart_outlined,
      color: AppColors.primary,
    ),
    _QuickAddItem(
      value: 'party',
      label: 'Add Party',
      icon: Icons.people_outlined,
      color: AppColors.secondary,
    ),
    _QuickAddItem(
      value: 'item',
      label: 'Add Item',
      icon: Icons.inventory_2_outlined,
      color: Color(0xFF2E7D32),
    ),
  ];

  void _toggleMenu() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
  }

  void _closeMenu() {
    if (_menuController.isOpen) {
      _menuController.close();
    }
  }

  void _navigate(BuildContext context, String value) {
    _closeMenu();
    switch (value) {
      case 'sale':
        context.push(AppRoutes.addSale);
      case 'purchase':
        context.push(AppRoutes.addPurchase);
      case 'party':
        context.go(AppRoutes.partyDetails);
      case 'item':
        context.go(AppRoutes.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        elevation: WidgetStateProperty.all(8),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        ),
        backgroundColor: WidgetStateProperty.all(AppColors.surface),
        minimumSize: WidgetStateProperty.all(
          const Size(_menuWidth, 0),
        ),
        maximumSize: WidgetStateProperty.all(
          const Size(_menuWidth, double.infinity),
        ),
      ),
      menuChildren: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            'Quick Add',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Divider(height: 1, color: DashboardColors.border),
        for (final item in _items)
          MenuItemButton(
            onPressed: () => _navigate(context, item.value),
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(
                const Size(_menuWidth, 44),
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
              ),
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.pressed)) {
                  return AppColors.background;
                }
                return null;
              }),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 18, color: item.color),
                const SizedBox(width: AppSpacing.sm + 4),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
      ],
      child: _TopBarIconButton(
        tooltip: 'Quick add',
        icon: Icons.add_circle_outline,
        iconColor: AppColors.primary,
        onPressed: _toggleMenu,
      ),
    );
  }
}

class _QuickAddItem {
  const _QuickAddItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
}
