import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_type.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_outlined_pill_tabs.dart';
import 'package:flutter/material.dart';

class NotificationFilterTabs extends StatelessWidget {
  const NotificationFilterTabs({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelected;

  static const _tabs = [
    MobileOutlinedPillTab(
      id: 'appNotifications',
      label: 'App Notifications',
    ),
    MobileOutlinedPillTab(
      id: 'transactions',
      label: 'Transactions',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileOutlinedPillTabs(
      tabs: _tabs,
      activeTabId: selected.name,
      activeColor: AppColors.primary,
      activeBackgroundColor: AppColors.tabActiveTint,
      inactiveBorderColor: AppColors.chipBorder,
      inactiveTextColor: AppColors.textSecondary,
      onChanged: (id) {
        final filter = NotificationFilter.values.firstWhere(
          (value) => value.name == id,
        );
        onSelected(filter);
      },
    );
  }
}
