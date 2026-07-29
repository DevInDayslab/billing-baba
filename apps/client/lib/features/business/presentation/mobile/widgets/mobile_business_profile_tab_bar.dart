import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum MobileBusinessProfileTab { basicDetails, businessDetails }

extension MobileBusinessProfileTabLabel on MobileBusinessProfileTab {
  String get label => switch (this) {
    MobileBusinessProfileTab.basicDetails => 'Basic Details',
    MobileBusinessProfileTab.businessDetails => 'Business Details',
  };
}

/// Underline tab bar used on the mobile business profile screen.
class MobileBusinessProfileTabBar extends StatelessWidget {
  const MobileBusinessProfileTabBar({
    required this.activeTab,
    required this.onChanged,
    super.key,
  });

  final MobileBusinessProfileTab activeTab;
  final ValueChanged<MobileBusinessProfileTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (final tab in MobileBusinessProfileTab.values) ...[
            Expanded(
              child: _TabButton(
                label: tab.label,
                isActive: tab == activeTab,
                onTap: () => onChanged(tab),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isActive ? AppColors.error : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? AppColors.error : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
