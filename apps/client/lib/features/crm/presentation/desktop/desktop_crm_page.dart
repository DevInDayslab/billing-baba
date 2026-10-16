import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/application/crm_tab_provider.dart';
import 'package:billing_baba/features/crm/presentation/desktop/contacts_screen.dart';
import 'package:billing_baba/features/crm/presentation/desktop/deals_screen.dart';
import 'package:billing_baba/features/crm/presentation/desktop/leads_screen.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Matches inventory / parties tab accent.
const _crmTabActiveColor = Color(0xFF7C3AED);

class _CrmTabSpec {
  const _CrmTabSpec({
    required this.icon,
    required this.label,
    required this.tabIndex,
  });

  final IconData icon;
  final String label;
  final int tabIndex;
}

const _crmTabs = [
  _CrmTabSpec(
    icon: LucideIcons.userPlus,
    label: 'Leads',
    tabIndex: crmTabLeadsIndex,
  ),
  _CrmTabSpec(
    icon: LucideIcons.contact,
    label: 'Contacts',
    tabIndex: crmTabContactsIndex,
  ),
  _CrmTabSpec(
    icon: LucideIcons.handshake,
    label: 'Deals',
    tabIndex: crmTabDealsIndex,
  ),
];

class DesktopCrmPage extends ConsumerStatefulWidget {
  const DesktopCrmPage({super.key});

  @override
  ConsumerState<DesktopCrmPage> createState() => _DesktopCrmPageState();
}

class _DesktopCrmPageState extends ConsumerState<DesktopCrmPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _lastRouteLocation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _crmTabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final tab = _crmTabs[_tabController.index];
    ref.read(crmTabIndexProvider.notifier).tabIndex = tab.tabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final routeTabIndex = crmTabIndexForRoute(location);

    if (_lastRouteLocation != location) {
      _lastRouteLocation = location;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(crmTabIndexProvider.notifier).tabIndex = routeTabIndex;
        final targetIndex = _crmTabs.indexWhere(
          (tab) => tab.tabIndex == routeTabIndex,
        );
        if (targetIndex >= 0 && _tabController.index != targetIndex) {
          _tabController.animateTo(targetIndex);
        }
      });
    }

    ref.listen<int>(crmTabIndexProvider, (previous, next) {
      if (!mounted) return;
      final targetIndex = _crmTabs.indexWhere((tab) => tab.tabIndex == next);
      if (targetIndex < 0) return;
      if (_tabController.index != targetIndex) {
        _tabController.animateTo(targetIndex);
      }
    });

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
                animation: _tabController,
                builder: (context, _) {
                  return Row(
                    children: [
                      for (var i = 0; i < _crmTabs.length; i++)
                        Expanded(
                          child: _CrmTabButton(
                            spec: _crmTabs[i],
                            isSelected: _tabController.index == i,
                            onTap: () => _tabController.animateTo(i),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _CrmTabKeepAlive(child: DesktopLeadsScreen()),
                _CrmTabKeepAlive(child: DesktopContactsScreen()),
                _CrmTabKeepAlive(child: DesktopDealsScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps tab content mounted so switching tabs does not reload lists.
class _CrmTabKeepAlive extends StatefulWidget {
  const _CrmTabKeepAlive({required this.child});

  final Widget child;

  @override
  State<_CrmTabKeepAlive> createState() => _CrmTabKeepAliveState();
}

class _CrmTabKeepAliveState extends State<_CrmTabKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _CrmTabButton extends StatelessWidget {
  const _CrmTabButton({
    required this.spec,
    required this.isSelected,
    required this.onTap,
  });

  final _CrmTabSpec spec;
  final bool isSelected;
  final VoidCallback onTap;

  static const _iconTextGap = 8.0;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _crmTabActiveColor : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.background.withValues(alpha: 0.6),
        child: Container(
          width: double.infinity,
          height: DashboardSpacing.topBarHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? _crmTabActiveColor : Colors.transparent,
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
