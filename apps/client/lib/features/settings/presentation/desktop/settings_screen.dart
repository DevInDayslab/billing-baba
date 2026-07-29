import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/backup/presentation/desktop/backup_restore_page.dart';
import 'package:billing_baba/features/business/presentation/desktop/edit_profile_page.dart';
import 'package:billing_baba/features/settings/models/settings_tab.dart';
import 'package:billing_baba/features/settings/presentation/desktop/about_settings_tab.dart';
import 'package:billing_baba/features/settings/presentation/desktop/print_settings_screen.dart';
import 'package:billing_baba/features/settings/presentation/desktop/transaction_messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Desktop Settings hub — equal-width tabs; no per-tab route pushes.
class DesktopSettingsScreen extends StatefulWidget {
  const DesktopSettingsScreen({super.key});

  @override
  State<DesktopSettingsScreen> createState() => _DesktopSettingsScreenState();
}

class _DesktopSettingsScreenState extends State<DesktopSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _appliedTabQuery;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: SettingsTab.values.length,
      vsync: this,
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
    _tabController.dispose();
    super.dispose();
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
          child: AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              return IndexedStack(
                index: _tabController.index,
                sizing: StackFit.expand,
                children: const [
                  DesktopEditProfilePage(embedded: true),
                  DesktopPrintSettingsScreen(embedded: true),
                  DesktopTransactionMessagesScreen(embedded: true),
                  BackupRestorePage(embedded: true),
                  AboutSettingsTab(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
