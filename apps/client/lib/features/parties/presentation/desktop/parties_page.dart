import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/hidden_ledger_list_page.dart';
import 'package:billing_baba/features/parties/application/parties_tab_provider.dart';
import 'package:billing_baba/features/settings/application/party_settings_provider.dart';
import 'package:billing_baba/features/parties/presentation/desktop/party_details_page.dart';
import 'package:billing_baba/features/parties/presentation/desktop/party_groups_page.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_page_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Matches inventory tab accent.
const _partiesTabActiveColor = Color(0xFF7C3AED);

class _PartiesTabSpec {
  const _PartiesTabSpec({
    required this.icon,
    required this.label,
    required this.route,
    required this.tabIndex,
  });

  final IconData icon;
  final String label;
  final String route;
  final int tabIndex;
}

class DesktopPartiesPage extends ConsumerStatefulWidget {
  const DesktopPartiesPage({super.key});

  @override
  ConsumerState<DesktopPartiesPage> createState() => _DesktopPartiesPageState();
}

class _DesktopPartiesPageState extends ConsumerState<DesktopPartiesPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _lastTabCount = 0;
  List<_PartiesTabSpec> _visibleTabs = const [];
  String? _lastRouteLocation;

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  List<_PartiesTabSpec> _buildVisibleTabs(
    bool showHiddenLedger,
    bool partyGroupingEnabled,
  ) {
    return [
      const _PartiesTabSpec(
        icon: LucideIcons.users,
        label: 'Parties',
        route: AppRoutes.partyDetails,
        tabIndex: partiesTabPartiesIndex,
      ),
      if (partyGroupingEnabled)
        const _PartiesTabSpec(
          icon: LucideIcons.folder,
          label: 'Groups',
          route: AppRoutes.partyGroups,
          tabIndex: partiesTabGroupsIndex,
        ),
      if (showHiddenLedger)
        const _PartiesTabSpec(
          icon: LucideIcons.eyeOff,
          label: 'Hidden Ledger',
          route: AppRoutes.partyHiddenLedger,
          tabIndex: partiesTabHiddenLedgerIndex,
        ),
    ];
  }

  void _ensureTabController(List<_PartiesTabSpec> tabs, int tabIndex) {
    final resolvedIndex = tabs.indexWhere((tab) => tab.tabIndex == tabIndex);
    final safeIndex = resolvedIndex >= 0 ? resolvedIndex : 0;

    if (_tabController == null || _lastTabCount != tabs.length) {
      _tabController?.removeListener(_onTabChanged);
      _tabController?.dispose();
      _tabController = TabController(
        length: tabs.length,
        vsync: this,
        initialIndex: safeIndex,
      );
      _tabController!.addListener(_onTabChanged);
      _lastTabCount = tabs.length;
    }
  }

  void _onTabChanged() {
    final controller = _tabController;
    if (controller == null || controller.indexIsChanging) return;

    final tab = _visibleTabs[controller.index];
    ref.read(partiesTabIndexProvider.notifier).tabIndex = tab.tabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionServiceProvider);
    final showHiddenLedger = permissions.canViewHiddenLedger;
    final partyGroupingEnabled = ref.watch(partyGroupingEnabledProvider);
    final tabs = _buildVisibleTabs(showHiddenLedger, partyGroupingEnabled);
    _visibleTabs = tabs;

    final location = GoRouterState.of(context).uri.path;
    final routeTabIndex = partiesTabIndexForRoute(location);
    final providerTabIndex = ref.watch(partiesTabIndexProvider);

    var routeJustChanged = false;
    if (_lastRouteLocation != location) {
      _lastRouteLocation = location;
      routeJustChanged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(partiesTabIndexProvider.notifier).tabIndex = routeTabIndex;
        final targetIndex = tabs.indexWhere(
          (tab) => tab.tabIndex == routeTabIndex,
        );
        if (targetIndex >= 0 && _tabController?.index != targetIndex) {
          _tabController?.animateTo(targetIndex);
        }
      });
    }

    final tabIndex = routeJustChanged ? routeTabIndex : providerTabIndex;

    ref.listen<int>(partiesTabIndexProvider, (previous, next) {
      final controller = _tabController;
      if (controller == null || !mounted) return;
      final targetIndex = tabs.indexWhere((tab) => tab.tabIndex == next);
      if (targetIndex < 0) return;
      if (controller.index != targetIndex) {
        controller.animateTo(targetIndex);
      }
    });

    _ensureTabController(tabs, tabIndex);

    final controller = _tabController!;
    final currentRoute = partiesRouteForTabIndex(tabIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: DashboardColors.border)),
            ),
            child: SizedBox(
              height: DashboardSpacing.topBarHeight,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return Row(
                    children: [
                      for (var i = 0; i < tabs.length; i++)
                        Expanded(
                          child: _PartiesTabButton(
                            spec: tabs[i],
                            isSelected: controller.index == i,
                            onTap: () => controller.animateTo(i),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PartyPageTitleBar(
                    currentRoute: currentRoute,
                    onAddParty: () => openDesktopAddPartyDialog(context),
                    onAddGroup: () => openDesktopAddGroupDialog(context, ref),
                    onSettingsTap: () => context.push(AppRoutes.settingsParty),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: controller,
                      children: [
                        for (final tab in tabs)
                          switch (tab.tabIndex) {
                            partiesTabPartiesIndex =>
                              const DesktopPartyDetailsPage(embedded: true),
                            partiesTabGroupsIndex =>
                              const DesktopPartyGroupsPage(embedded: true),
                            partiesTabHiddenLedgerIndex =>
                              const DesktopHiddenLedgerListPage(embedded: true),
                            _ => const SizedBox.shrink(),
                          },
                      ],
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

class _PartiesTabButton extends StatelessWidget {
  const _PartiesTabButton({
    required this.spec,
    required this.isSelected,
    required this.onTap,
  });

  final _PartiesTabSpec spec;
  final bool isSelected;
  final VoidCallback onTap;

  static const _iconTextGap = 8.0;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _partiesTabActiveColor : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.background.withValues(alpha: 0.6),
        child: Container(
          height: DashboardSpacing.topBarHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? _partiesTabActiveColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(spec.icon, size: 18, color: color),
              const SizedBox(width: _iconTextGap),
              Text(
                spec.label,
                style: DashboardTypography.tabLabel.copyWith(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
