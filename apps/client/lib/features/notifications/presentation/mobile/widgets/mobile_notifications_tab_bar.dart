import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_outlined_pill_tabs.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/mobile_notifications_theme.dart';
import 'package:flutter/material.dart';

/// Notifications screen pill tabs — reference colors and spacing.
class MobileNotificationsTabBar extends StatelessWidget {
  const MobileNotificationsTabBar({
    required this.tabs,
    required this.activeTabId,
    required this.onChanged,
    super.key,
  });

  final List<MobileOutlinedPillTab> tabs;
  final String activeTabId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MobileNotificationsTheme.headerBackground,
      child: MobileOutlinedPillTabs(
        tabs: tabs,
        activeTabId: activeTabId,
        onChanged: onChanged,
        activeColor: MobileNotificationsTheme.accentRed,
        activeBackgroundColor: MobileNotificationsTheme.activeTabBackground,
        inactiveBorderColor: MobileNotificationsTheme.inactiveTabBorder,
        inactiveTextColor: MobileNotificationsTheme.inactiveTabText,
        borderWidth: MobileNotificationsTheme.tabBorderWidth,
        fontSize: MobileNotificationsTheme.tabFontSize,
        fontWeight: MobileNotificationsTheme.tabFontWeight,
        padding: MobileNotificationsTheme.tabSectionPadding,
        gap: AppSpacing.sm,
      ),
    );
  }
}
