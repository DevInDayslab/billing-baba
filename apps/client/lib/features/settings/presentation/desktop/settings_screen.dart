import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/backup/presentation/desktop/backup_restore_page.dart';
import 'package:billing_baba/features/business/presentation/desktop/edit_profile_page.dart';
import 'package:billing_baba/features/settings/application/print_settings_provider.dart';
import 'package:billing_baba/features/settings/application/transaction_message_settings_provider.dart';
import 'package:billing_baba/features/settings/models/settings_tab.dart';
import 'package:billing_baba/features/settings/presentation/desktop/about_settings_tab.dart';
import 'package:billing_baba/features/settings/presentation/desktop/print_settings_screen.dart';
import 'package:billing_baba/features/settings/presentation/desktop/transaction_messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Desktop Settings hub — equal-width tabs; no per-tab route pushes.
class DesktopSettingsScreen extends ConsumerStatefulWidget {
  const DesktopSettingsScreen({super.key});

  @override
  ConsumerState<DesktopSettingsScreen> createState() =>
      _DesktopSettingsScreenState();
}

class _DesktopSettingsScreenState extends ConsumerState<DesktopSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _appliedTabQuery;
  var _isLoggingOut = false;
  var _didPrefetchSettings = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: SettingsTab.values.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefetchSettings());
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _prefetchSettings() {
    if (!mounted || _didPrefetchSettings) return;
    _didPrefetchSettings = true;
    // Kick local prefs load without awaiting — tabs open with data ready.
    unawaited(
      ref.read(printSettingsProvider.future).then<void>((_) {}, onError: (_) {}),
    );
    unawaited(
      ref
          .read(transactionMessageSettingsProvider.future)
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabQuery = GoRouterState.of(context).uri.queryParameters['tab'];
    if (tabQuery == _appliedTabQuery) return;
    _appliedTabQuery = tabQuery;
    final index = SettingsTab.fromQuery(tabQuery).index;
    if (_tabController.index != index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController.index != index) {
          _tabController.index = index;
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
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

  Widget _tabBody(int index) {
    return switch (SettingsTab.values[index]) {
      SettingsTab.profile => const DesktopEditProfilePage(embedded: true),
      SettingsTab.print => const DesktopPrintSettingsScreen(embedded: true),
      SettingsTab.transactionMessages =>
        const DesktopTransactionMessagesScreen(embedded: true),
      SettingsTab.backup => const BackupRestorePage(embedded: true),
      SettingsTab.about => const AboutSettingsTab(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            labelPadding: EdgeInsets.zero,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            dividerColor: listPanelCardBorder,
            labelStyle: AppTypography.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: AppTypography.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              for (final tab in SettingsTab.values)
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(tab.label, textAlign: TextAlign.center),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          // Build only the active tab — IndexedStack was mounting all five.
          child: KeyedSubtree(
            key: ValueKey<int>(_tabController.index),
            child: _tabBody(_tabController.index),
          ),
        ),
        const Divider(height: 1, color: listPanelCardBorder),
        Material(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _isLoggingOut ? null : () => unawaited(_logout()),
                icon: _isLoggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Logout'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
