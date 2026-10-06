import 'package:billing_baba/core/platform/mobile_platform_scope.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_controller.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_app_header.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_alerts_tab.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_business_overview_tab.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_tab_bar.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_transaction_details_tab.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_search_bar.dart';
import 'package:billing_baba/features/tasks/application/tasks_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Purple-themed mobile home with Business Overview, Transactions, and Alerts.
///
/// App header stays pinned (like Items). Search + home tabs scroll with each
/// tab's content inside that tab's [CustomScrollView].
class MobileHomePage extends ConsumerStatefulWidget {
  const MobileHomePage({super.key});

  @override
  ConsumerState<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends ConsumerState<MobileHomePage> {
  late final TextEditingController _searchController;
  int _slideDirection = 1;

  static int _viewIndex(MobileHomeView view) => switch (view) {
    MobileHomeView.businessOverview => 0,
    MobileHomeView.transactionDetails => 1,
    MobileHomeView.alerts => 2,
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(mobileHomeControllerProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncSearchBarFromController() {
    final query = ref.read(mobileHomeControllerProvider).searchQuery;
    if (_searchController.text == query) return;
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  void _onViewChanged(MobileHomeView view) {
    final homeState = ref.read(mobileHomeControllerProvider);
    final currentIndex = _viewIndex(homeState.activeView);
    final targetIndex = _viewIndex(view);
    if (currentIndex != targetIndex) {
      setState(() {
        _slideDirection = targetIndex > currentIndex ? 1 : -1;
      });
    }
    ref.read(mobileHomeControllerProvider.notifier).setView(view);
  }

  Widget _buildScrollChrome({
    required MobileHomeView activeView,
    required int alertsBadge,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MobileHomeSearchBar(
          controller: _searchController,
          onChanged: ref.read(mobileHomeControllerProvider.notifier).setSearch,
          hint: activeView == MobileHomeView.transactionDetails
              ? 'Search by item, party or number'
              : 'Search transactions, parties, invoices...',
        ),
        MobileHomeTabBar(
          activeView: activeView,
          onChanged: _onViewChanged,
          alertsBadgeCount: alertsBadge,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(mobileHomeControllerProvider);
    final tasks = ref.watch(tasksProvider).value ?? const [];
    final alertsBadge = mobileHomeAlertsBadgeCount(tasks);

    ref.listen(mobileHomeControllerProvider, (previous, next) {
      if (previous?.searchQuery == next.searchQuery) return;
      if (_searchController.text == next.searchQuery) return;
      _syncSearchBarFromController();
    });

    // Fresh chrome per tab so AnimatedSwitcher never parents the same element
    // twice during the cross-fade.
    Widget chromeFor(MobileHomeView view) => _buildScrollChrome(
      activeView: view,
      alertsBadge: alertsBadge,
    );

    return MobilePlatformScope(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.lightSystemUi,
        child: ColoredBox(
          color: AppColors.background,
          child: Column(
            children: [
              ColoredBox(
                color: AppColors.surface,
                child: SafeArea(
                  bottom: false,
                  child: MobileAppHeader(
                    onBusinessTap: () => context.push(AppRoutes.businessList),
                    onSettingsTap: () => context.push(AppRoutes.settings),
                    onNotificationTap: () =>
                        context.push(AppRoutes.notifications),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  // Only keep the active tab mounted so the shared search
                  // TextEditingController is never attached to two fields.
                  layoutBuilder: (currentChild, previousChildren) {
                    return currentChild ?? const SizedBox.shrink();
                  },
                  transitionBuilder: (child, animation) {
                    final enterOffset = Offset(0.14 * _slideDirection, 0);
                    final slideAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                      reverseCurve: Curves.easeInCubic,
                    );

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: enterOffset,
                        end: Offset.zero,
                      ).animate(slideAnimation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: switch (homeState.activeView) {
                    MobileHomeView.businessOverview =>
                      MobileHomeBusinessOverviewTab(
                        key: const ValueKey('overview'),
                        scrollChrome: chromeFor(
                          MobileHomeView.businessOverview,
                        ),
                      ),
                    MobileHomeView.transactionDetails =>
                      MobileHomeTransactionDetailsTab(
                        key: const ValueKey('transactions'),
                        scrollChrome: chromeFor(
                          MobileHomeView.transactionDetails,
                        ),
                      ),
                    MobileHomeView.alerts => MobileHomeAlertsTab(
                      key: const ValueKey('alerts'),
                      scrollChrome: chromeFor(MobileHomeView.alerts),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
