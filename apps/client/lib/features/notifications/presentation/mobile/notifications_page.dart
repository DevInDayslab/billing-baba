import 'package:billing_baba/core/widgets/mobile/mobile_outlined_pill_tabs.dart';
import 'package:billing_baba/features/notifications/application/mobile_notifications_models.dart';
import 'package:billing_baba/features/notifications/application/mobile_notifications_provider.dart';import 'package:billing_baba/features/notifications/presentation/mobile/mobile_notifications_theme.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/widgets/mobile_notifications_app_bar.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/widgets/mobile_notifications_empty_state.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/widgets/mobile_notifications_tab_bar.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/widgets/mobile_stay_updated_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mobile notifications center — mock UI only (no backend).
class MobileNotificationsPage extends ConsumerWidget {
  const MobileNotificationsPage({super.key});

  static const _tabs = [
    MobileOutlinedPillTab(
      id: 'appNotifications',
      label: 'App Notifications',
    ),
    MobileOutlinedPillTab(
      id: 'allTransactions',
      label: 'All Transactions',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileNotificationsProvider);
    final controller = ref.read(mobileNotificationsProvider.notifier);

    return Scaffold(
      backgroundColor: MobileNotificationsTheme.headerBackground,
      appBar: const MobileNotificationsAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobileNotificationsTabBar(
            tabs: _tabs,
            activeTabId: state.activeTab.id,
            onChanged: controller.setActiveTabById,
          ),
          Expanded(
            child: ColoredBox(
              color: MobileNotificationsTheme.contentBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.showStayUpdatedBanner)
                    MobileStayUpdatedBanner(
                      onEnable: () {
                        controller.enableNotifications();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notifications enabled'),
                          ),
                        );
                      },
                    ),
                  Expanded(
                    child: MobileNotificationsEmptyState(
                      message: state.activeTab.emptyTitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
