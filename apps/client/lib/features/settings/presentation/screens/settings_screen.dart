import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings hub — entry point for device-local and business configuration.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _items = <_SettingsNavItem>[
    _SettingsNavItem(
      icon: Icons.print_outlined,
      title: 'Print Settings',
      subtitle: 'Printer type, layout, and invoice content',
      route: AppRoutes.settingsPrint,
      push: true,
    ),
    _SettingsNavItem(
      icon: Icons.people_outline,
      title: 'Users & Roles',
      route: AppRoutes.settingsUsers,
    ),
    _SettingsNavItem(
      icon: Icons.receipt_long_outlined,
      title: 'Taxes',
      route: AppRoutes.settingsTaxes,
    ),
    _SettingsNavItem(
      icon: Icons.description_outlined,
      title: 'Invoice Templates',
      route: AppRoutes.settingsInvoiceTemplates,
    ),
    _SettingsNavItem(
      icon: Icons.backup_outlined,
      title: 'Backup & Restore',
      route: AppRoutes.settingsBackup,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        color: listPanelCardBorder,
      ),
      itemBuilder: (context, index) {
        final item = _items[index];
        return _SettingsNavTile(
          item: item,
          onTap: () {
            if (item.push) {
              context.push(item.route);
            } else {
              context.go(item.route);
            }
          },
        );
      },
    );
  }
}

class _SettingsNavItem {
  const _SettingsNavItem({
    required this.icon,
    required this.title,
    required this.route,
    this.subtitle,
    this.push = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String route;
  final bool push;
}

class _SettingsNavTile extends StatelessWidget {
  const _SettingsNavTile({
    required this.item,
    required this.onTap,
  });

  final _SettingsNavItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: item.subtitle != null ? AppSpacing.md : 18,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 24,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodyLargeSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySmallSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
