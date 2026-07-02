import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

class SidebarProfileMenu extends StatelessWidget {
  const SidebarProfileMenu({
    required this.companyName,
    required this.onEditProfile,
    required this.onSwitchCompany,
    required this.onLogout,
    super.key,
  });

  final String companyName;
  final VoidCallback onEditProfile;
  final VoidCallback onSwitchCompany;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      shadowColor: Colors.black26,
      borderRadius: AppRadius.mdBorder,
      color: AppColors.surface,
      child: SizedBox(
        width: 240,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Company',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    companyName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            _ProfileMenuItem(
              icon: LucideIcons.userPen,
              label: 'Edit Profile',
              onTap: onEditProfile,
            ),
            _ProfileMenuItem(
              icon: LucideIcons.refreshCw,
              label: 'Switch Company',
              onTap: onSwitchCompany,
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            _ProfileMenuItem(
              icon: LucideIcons.logOut,
              label: 'Logout',
              color: AppColors.error,
              onTap: onLogout,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: itemColor),
            const SizedBox(width: AppSpacing.sm + 4),
            Text(
              label,
              style: TextStyle(
                color: itemColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
