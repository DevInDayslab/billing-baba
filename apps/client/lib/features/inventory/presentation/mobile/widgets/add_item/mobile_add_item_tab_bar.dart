import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:flutter/material.dart';

/// Vyapar-style tab bar for mobile Add Item (red active indicator).
class MobileAddItemTabBar extends StatelessWidget {
  const MobileAddItemTabBar({
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
    super.key,
  });

  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: MobileAddItemTheme.sectionSpacing),
          SizedBox(
            height: 44,
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: _TabItem(
                      label: tabs[i],
                      isActive: i == activeIndex,
                      onTap: () => onTabSelected(i),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? MobileAddItemTheme.tabActiveRed
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 3,
            color: isActive
                ? MobileAddItemTheme.tabActiveRed
                : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
