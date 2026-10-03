import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/application/mobile_menu_expansion_provider.dart';
import 'package:billing_baba/features/settings/models/settings_tab.dart';
import 'package:billing_baba/features/settings/presentation/desktop/about_settings_tab.dart';
import 'package:billing_baba/features/settings/presentation/mobile/widgets/mobile_menu_body.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile Menu hub — single entry point for app navigation and configuration.
///
/// Opened from the gear icon. Settings is an inline accordion section here,
/// not a separate page.
class MobileSettingsScreen extends ConsumerStatefulWidget {
  const MobileSettingsScreen({super.key});

  @override
  ConsumerState<MobileSettingsScreen> createState() =>
      _MobileSettingsScreenState();
}

class _MobileSettingsScreenState extends ConsumerState<MobileSettingsScreen> {
  String? _handledTabQuery;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _expandSettingsFromQuery();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabQuery = GoRouterState.of(context).uri.queryParameters['tab'];
    if (tabQuery == null || tabQuery == _handledTabQuery) return;
    _handledTabQuery = tabQuery;
    final tab = SettingsTab.fromQuery(tabQuery);
    final route = switch (tab) {
      SettingsTab.profile || SettingsTab.about => null,
      SettingsTab.print => AppRoutes.settingsPrint,
      SettingsTab.transactionMessages => AppRoutes.settingsTransactionMessages,
      SettingsTab.backup => AppRoutes.settingsBackup,
    };
    if (route == null) {
      if (tab != SettingsTab.about) {
        _expandSettingsFromQuery();
      }
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.push(route));
    });
  }

  void _expandSettingsFromQuery() {
    final tabQuery = GoRouterState.of(context).uri.queryParameters['tab'];
    if (tabQuery == null || tabQuery.isEmpty) return;
    if (tabQuery == SettingsTab.about.id) return;
    unawaited(
      ref
          .read(mobileMenuExpandedSectionProvider.notifier)
          .setExpanded('settings'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tab = SettingsTab.fromQuery(
      GoRouterState.of(context).uri.queryParameters['tab'],
    );
    if (tab == SettingsTab.about) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: MobileAppBar(
          title: 'About',
          showBusinessHeader: false,
          showNotification: false,
          showSettings: false,
          onBack: () => context.go(AppRoutes.settingsPreferences),
        ),
        body: const AboutSettingsTab(),
      );
    }

    final bottomInset = MobileBottomNavigation.contentBottomPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: 'Settings',
        showBackButton: Navigator.canPop(context),
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: bottomInset + AppSpacing.md),
        children: const [
          MobileMenuBody(),
        ],
      ),
    );
  }
}
