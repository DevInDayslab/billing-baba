import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/settings/application/settings_nav_catalog.dart';
import 'package:billing_baba/features/settings/models/settings_nav_item.dart';
import 'package:billing_baba/features/settings/models/settings_tab.dart';
import 'package:billing_baba/features/settings/presentation/desktop/about_settings_tab.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_settings_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile global settings hub — lists all business and app-wide settings.
class MobileSettingsScreen extends ConsumerStatefulWidget {
  const MobileSettingsScreen({super.key});

  @override
  ConsumerState<MobileSettingsScreen> createState() =>
      _MobileSettingsScreenState();
}

class _MobileSettingsScreenState extends ConsumerState<MobileSettingsScreen> {
  String? _handledTabQuery;
  var _isLoggingOut = false;

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
    if (route == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.push(route);
    });
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    try {
      await ref.read(authProvider.notifier).logout();
      if (!mounted) return;
      context.go(AppRoutes.login);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  void _onItemTap(SettingsNavItem item) {
    if (item.id == SettingsTab.profile.id) {
      context.push(AppRoutes.editProfile);
      return;
    }
    context.push(item.route);
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              children: [
                for (final group in SettingsNavGroup.values)
                  if ((grouped[group] ?? []).isNotEmpty) ...[
                    _GroupHeader(label: group.label),
                    ..._buildGroupTiles(
                      grouped[group]!
                          .where(
                            (item) => item.id != SettingsNavCatalog.logoutId,
                          )
                          .toList(),
                    ),
                  ],
              ],
            ),
          ),
          Material(
            color: AppColors.surface,
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: _LogoutTile(
                isLoading: _isLoggingOut,
                onTap: () => unawaited(_logout()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupTiles(List<SettingsNavItem> items) {
    if (items.isEmpty) return const [];
    return [
      for (var i = 0; i < items.length; i++) ...[
        MobileSettingsListTile(
          item: items[i],
          onTap: () => _onItemTap(items[i]),
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

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({
    required this.onTap,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 18,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.logout_rounded,
                        size: 22,
                        color: AppColors.error,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sign out of this device',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
