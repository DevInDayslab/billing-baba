import 'package:billing_baba/features/dashboard/models/dashboard_side_widget.dart';
import 'package:billing_baba/features/dashboard/presentation/coming_soon_page.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_tab_bar.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_tab_content.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_widget_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopHomePage extends ConsumerWidget {
  const DesktopHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(dashboardActiveTabProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashboardTabBar(),
        Expanded(
          child: switch (activeTab) {
            DashboardHomeTab.dashboard => const DashboardTabContent(),
            DashboardHomeTab.searchProductOnline => const ComingSoonPage(
              title: 'Search Product Online',
            ),
            DashboardHomeTab.myOnlineStore => const ComingSoonPage(
              title: 'My Online Store',
            ),
            DashboardHomeTab.messages => const ComingSoonPage(
              title: 'Messages',
            ),
          },
        ),
      ],
    );
  }
}
