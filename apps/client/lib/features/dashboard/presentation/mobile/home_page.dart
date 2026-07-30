import 'dart:async';

import 'package:billing_baba/core/platform/mobile_platform_scope.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_transaction_more_options_sheet.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_controller.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_mock_data.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_header.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_party_section.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_quick_links.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_search_bar.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_transaction_card.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_view_toggle.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/reports/application/reports_nav_intent_provider.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_more_options_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_share_transaction_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_transaction_menu_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_transaction_type_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Vyapar-style mobile home screen with transactions feed.
class MobileHomePage extends ConsumerStatefulWidget {
  const MobileHomePage({super.key});

  @override
  ConsumerState<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends ConsumerState<MobileHomePage> {
  late final TextEditingController _searchController;

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

  void _showFilterSheet() {
    final currentFilters = ref
        .read(mobileHomeControllerProvider)
        .transactionTypeFilters;
    unawaited(
      showMobileTransactionTypeFilterSheet(
        context: context,
        selected: currentFilters,
      ).then((value) {
        if (value == null || !mounted) return;
        ref
            .read(mobileHomeControllerProvider.notifier)
            .setTransactionTypeFilters(value);
      }),
    );
  }

  void _showAddTxnSheet() {
    unawaited(showMobileTransactionMenuSheet(context: context));
  }

  void _showMoreOptionsSheet() {
    final activeView = ref.read(mobileHomeControllerProvider).activeView;
    final scope = activeView == MobileHomeView.partyDetails
        ? MobileMoreOptionsScope.party
        : MobileMoreOptionsScope.transaction;

    unawaited(
      showMobileMoreOptionsSheet(
        context: context,
        scope: scope,
        onPushRoute: (route) => context.push(route),
        onOpenReport: (intent) {
          ref.read(reportsNavIntentProvider.notifier).setIntent(intent);
          context.go(AppRoutes.reports);
        },
        onImportParty: () => showAddPartyDialog(context),
        onInviteParty: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invite party coming soon')),
          );
        },
      ),
    );
  }

  void _showShareSheet(MobileHomeTransactionItem item) {
    unawaited(
      showMobileShareTransactionSheet(
        context: context,
        onShareAsImage: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sharing ${item.documentNumber} as image…'),
            ),
          );
        },
        onShareAsPdf: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sharing ${item.documentNumber} as PDF…'),
            ),
          );
        },
      ),
    );
  }

  void _showMoreActions(MobileHomeTransactionItem item) {
    unawaited(
      showMobileTransactionMoreOptionsSheet(
        context: context,
        onDuplicate: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicating ${item.documentNumber}…'),
            ),
          );
        },
        onShareAsPdf: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sharing ${item.documentNumber} as PDF…'),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(mobileHomeControllerProvider);
    final isPartyView = homeState.activeView == MobileHomeView.partyDetails;
    final transactions = filterHomeTransactions(
      MobileHomeMockData.transactions,
      homeState.searchQuery,
      typeFilters: homeState.transactionTypeFilters,
    );

    return MobilePlatformScope(
      child: ColoredBox(
        color: AppColors.background,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  MobileHomeHeader(
                    onAvatarTap: () => context.push(AppRoutes.editProfile),
                    onBusinessTap: () => context.push(AppRoutes.businessList),
                    onSettingsTap: () => context.push(AppRoutes.settings),
                    onNotificationTap: () =>
                        context.push(AppRoutes.notifications),
                    onSyncTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Syncing…')),
                      );
                    },
                  ),
                  MobileHomeViewToggle(
                    activeView: homeState.activeView,
                    onChanged: ref
                        .read(mobileHomeControllerProvider.notifier)
                        .setView,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: MobileHomeQuickLinks(
                            links: isPartyView
                                ? MobileHomeMockData.partyQuickLinks(
                                    onNetwork: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Network coming soon'),
                                        ),
                                      );
                                    },
                                    onPartyStatement: () =>
                                        context.push(AppRoutes.reports),
                                    onPartySettings: () =>
                                        context.push(AppRoutes.settings),
                                    onShowAll: _showMoreOptionsSheet,
                                  )
                                : MobileHomeMockData.quickLinks(
                                    onTxnSettings: () => context.push(
                                      AppRoutes.settingsTransactionMessages,
                                    ),
                                    onAddTxn: _showAddTxnSheet,
                                    onSaleReport: () =>
                                        context.push(AppRoutes.reports),
                                    onShowAll: _showMoreOptionsSheet,
                                  ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: MobileHomeSearchBar(
                            controller: _searchController,
                            onChanged: ref
                                .read(mobileHomeControllerProvider.notifier)
                                .setSearch,
                            onFilterTap: _showFilterSheet,
                            hint: isPartyView
                                ? 'Search any party'
                                : 'Search for a transaction...',
                            showFilter: !isPartyView,
                          ),
                        ),
                        if (isPartyView)
                          SliverFillRemaining(
                            child: MobileHomePartySection(
                              searchQuery: homeState.searchQuery,
                              onSelectParty: (partyId) {
                                ref
                                        .read(selectedPartyIdProvider.notifier)
                                        .selected =
                                    partyId;
                                unawaited(context.push(AppRoutes.partyDetails));
                              },
                            ),
                          )
                        else if (transactions.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: MobileEmptyState(
                              title: 'No transactions found',
                              message: 'Try a different search term.',
                              icon: Icons.receipt_long_outlined,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.sm,
                              AppSpacing.lg,
                              AppSpacing.md,
                            ),
                            sliver: SliverList.separated(
                              itemCount: transactions.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final item = transactions[index];
                                return MobileHomeTransactionCard(
                                  item: item,
                                  onPrint: () {},
                                  onShare: () => _showShareSheet(item),
                                  onMore: () => _showMoreActions(item),
                                );
                              },
                            ),
                          ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height:
                                MobileBottomNavigation.fabBottomInset +
                                52 +
                                AppSpacing.md,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: MobileBottomNavigation.fabBottomInset,
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: MobileHomeAddSaleFab(
                      onPressed: () => context.push(AppRoutes.addSale),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
