import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/global_search_field.dart';
import 'package:billing_baba/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppTopBar extends ConsumerWidget {
  const AppTopBar({required this.pageTitle, super.key});

  final String pageTitle;

  static const _barHeight = 60.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: _barHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;

          return Row(
            children: [
              SizedBox(
                width: isNarrow ? 120 : 180,
                child: Text(
                  pageTitle,
                  style: DashboardTypography.pageTitle.copyWith(
                    fontSize: isNarrow ? 20 : 24,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 280,
                      maxWidth: 560,
                    ),
                    child: const GlobalSearchField(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              const _QuickAddMenu(),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh, size: 20),
                color: AppColors.textSecondary,
                onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
              ),
              IconButton(
                tooltip: 'Cloud Sync',
                icon: Icon(
                  Icons.cloud_done_outlined,
                  size: 20,
                  color: Colors.green.shade600,
                ),
                onPressed: () {},
              ),
            ],
          );
        },
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
        const Divider(height: 1, color: Color(0xFFE0E0E0)),
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
      child: GestureDetector(
        onTap: _toggleMenu,
        behavior: HitTestBehavior.opaque,
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            Icons.add_circle_outline,
            size: 22,
            color: AppColors.primary,
          ),
        ),
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
