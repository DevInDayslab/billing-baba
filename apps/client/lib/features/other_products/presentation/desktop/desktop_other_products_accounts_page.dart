import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/bank_accounts/presentation/cash_and_bank_page.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/loans/presentation/loan_accounts_page.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/other_incomes_page.dart';
import 'package:billing_baba/features/other_products/application/other_products_accounts_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _accountsTabActiveColor = Color(0xFF38BDF8);

class _AccountsTabSpec {
  const _AccountsTabSpec({
    required this.icon,
    required this.label,
    required this.tabIndex,
  });

  final IconData icon;
  final String label;
  final int tabIndex;
}

const _accountsTabs = [
  _AccountsTabSpec(
    icon: LucideIcons.circlePlus,
    label: 'Other Income',
    tabIndex: otherProductsAccountsTabOtherIncomeIndex,
  ),
  _AccountsTabSpec(
    icon: LucideIcons.landmark,
    label: 'Cash & Bank',
    tabIndex: otherProductsAccountsTabCashAndBankIndex,
  ),
  _AccountsTabSpec(
    icon: LucideIcons.handCoins,
    label: 'Loan Accounts',
    tabIndex: otherProductsAccountsTabLoanAccountsIndex,
  ),
];

class DesktopOtherProductsAccountsPage extends ConsumerStatefulWidget {
  const DesktopOtherProductsAccountsPage({super.key});

  @override
  ConsumerState<DesktopOtherProductsAccountsPage> createState() =>
      _DesktopOtherProductsAccountsPageState();
}

class _DesktopOtherProductsAccountsPageState
    extends ConsumerState<DesktopOtherProductsAccountsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _lastRouteLocation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _accountsTabs.length, vsync: this);
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

    final tab = _accountsTabs[_tabController.index];
    ref.read(otherProductsAccountsTabIndexProvider.notifier).tabIndex =
        tab.tabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final routeTabIndex = otherProductsAccountsTabIndexForRoute(location);

    if (_lastRouteLocation != location) {
      _lastRouteLocation = location;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(otherProductsAccountsTabIndexProvider.notifier).tabIndex =
            routeTabIndex;
        final targetIndex = _accountsTabs.indexWhere(
          (tab) => tab.tabIndex == routeTabIndex,
        );
        if (targetIndex >= 0 && _tabController.index != targetIndex) {
          _tabController.animateTo(targetIndex);
        }
      });
    }

    ref.listen<int>(otherProductsAccountsTabIndexProvider, (previous, next) {
      if (!mounted) return;
      final targetIndex =
          _accountsTabs.indexWhere((tab) => tab.tabIndex == next);
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
                      for (var i = 0; i < _accountsTabs.length; i++)
                        Expanded(
                          child: _AccountsTabButton(
                            spec: _accountsTabs[i],
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
                _AccountsTabKeepAlive(
                  child: DesktopOtherIncomesPage(embeddedInAccountsHub: true),
                ),
                _AccountsTabKeepAlive(
                  child: CashAndBankPage(embeddedInAccountsHub: true),
                ),
                _AccountsTabKeepAlive(
                  child: LoanAccountsPage(embeddedInAccountsHub: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountsTabKeepAlive extends StatefulWidget {
  const _AccountsTabKeepAlive({required this.child});

  final Widget child;

  @override
  State<_AccountsTabKeepAlive> createState() => _AccountsTabKeepAliveState();
}

class _AccountsTabKeepAliveState extends State<_AccountsTabKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _AccountsTabButton extends StatelessWidget {
  const _AccountsTabButton({
    required this.spec,
    required this.isSelected,
    required this.onTap,
  });

  final _AccountsTabSpec spec;
  final bool isSelected;
  final VoidCallback onTap;

  static const _iconTextGap = 8.0;

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? _accountsTabActiveColor : AppColors.textSecondary;

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
                color: isSelected ? _accountsTabActiveColor : Colors.transparent,
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
