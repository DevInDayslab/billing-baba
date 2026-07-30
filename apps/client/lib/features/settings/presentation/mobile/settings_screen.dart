import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/application/settings_nav_catalog.dart';
import 'package:billing_baba/features/settings/models/settings_nav_item.dart';
import 'package:billing_baba/features/settings/models/settings_tab.dart';
import 'package:billing_baba/features/settings/presentation/desktop/about_settings_tab.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_settings_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mobile global settings hub — lists all business and app-wide settings.
class MobileSettingsScreen extends StatefulWidget {
  const MobileSettingsScreen({super.key});

  @override
  State<MobileSettingsScreen> createState() => _MobileSettingsScreenState();
}

class _MobileSettingsScreenState extends State<MobileSettingsScreen> {
  String? _handledTabQuery;

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
      SettingsTab.transactionMessages =>
        AppRoutes.settingsTransactionMessages,
      SettingsTab.backup => AppRoutes.settingsBackup,
    };
    if (route == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.push(route);
    });
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

    final grouped = SettingsNavCatalog.grouped();

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
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          for (final group in SettingsNavGroup.values)
            if ((grouped[group] ?? []).isNotEmpty) ...[
              _GroupHeader(label: group.label),
              ..._buildGroupTiles(context, grouped[group]!),
            ],
        ],
      ),
    );
  }

  List<Widget> _buildGroupTiles(
    BuildContext context,
    List<SettingsNavItem> items,
  ) {
    return [
      for (var i = 0; i < items.length; i++) ...[
        MobileSettingsListTile(
          item: items[i],
          onTap: () {
            final item = items[i];
            if (item.id == SettingsTab.profile.id) {
              context.push(AppRoutes.editProfile);
              return;
            }
            context.push(item.route);
          },
        ),
        if (i < items.length - 1)
          const Divider(height: 1, indent: 72, color: Color(0xFFE8ECF1)),
      ],
      const SizedBox(height: AppSpacing.md),
    ];
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
