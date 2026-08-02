import 'dart:async';

import 'package:billing_baba/core/platform/mobile_platform_scope.dart';
import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/sync/application/sync_ui_state_provider.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_controller.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_transactions_provider.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_header.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_party_section.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_quick_links.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_search_bar.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_transaction_card.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_view_toggle.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/reports/application/reports_nav_intent_provider.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_more_options_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_share_transaction_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
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
    final currentFilters =
        ref.read(mobileHomeControllerProvider).transactionTypeFilters;
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
      showMobileMoreActionsSheet(
        context: context,
        title: item.documentNumber,
        actions: [
          MobileSheetAction(
            icon: Icons.visibility_outlined,
            label: 'View',
            onTap: () {},
          ),
          MobileSheetAction(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: () {},
          ),
          MobileSheetAction(
            icon: Icons.print_outlined,
            label: 'Print',
            onTap: () {},
          ),
          MobileSheetAction(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () => _showShareSheet(item),
          ),
          MobileSheetAction(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            isDestructive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  List<MobileHomeQuickLink> _txnQuickLinks() {
    return [
      MobileHomeQuickLink(
        label: 'Add Txn',
        icon: Icons.add_rounded,
        backgroundColor: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF42A5F5),
        onTap: _showAddTxnSheet,
      ),
      MobileHomeQuickLink(
        label: 'Sale Report',
        icon: Icons.description_outlined,
        backgroundColor: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF43A047),
        onTap: () => context.push(AppRoutes.reports),
      ),
      MobileHomeQuickLink(
        label: 'Txn Settings',
        icon: Icons.settings_outlined,
        backgroundColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFFF9800),
        onTap: () => context.push(AppRoutes.settingsTransactionMessages),
      ),
      MobileHomeQuickLink(
        label: 'Show All',
        icon: Icons.arrow_forward_rounded,
        backgroundColor: const Color(0xFFEDE7F6),
        iconColor: const Color(0xFF5D5FEF),
        onTap: _showMoreOptionsSheet,
      ),
    ];
  }

  List<MobileHomeQuickLink> _partyQuickLinks() {
    return [
      MobileHomeQuickLink(
        label: 'Network',
        icon: Icons.hub_outlined,
        backgroundColor: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF42A5F5),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Network coming soon')),
          );
        },
      ),
      MobileHomeQuickLink(
        label: 'Party Statement',
        icon: Icons.description_outlined,
        backgroundColor: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF43A047),
        onTap: () => context.push(AppRoutes.reports),
      ),
      MobileHomeQuickLink(
        label: 'Party Settings',
        icon: Icons.settings_outlined,
        backgroundColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFFF9800),
        onTap: () => context.push(AppRoutes.settings),
      ),
      MobileHomeQuickLink(
        label: 'Show All',
        icon: Icons.arrow_forward_rounded,
        backgroundColor: const Color(0xFFEDE7F6),
        iconColor: const Color(0xFF5D5FEF),
        onTap: _showMoreOptionsSheet,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(mobileHomeControllerProvider);
    final isPartyView = homeState.activeView == MobileHomeView.partyDetails;
    final transactionsAsync = ref.watch(mobileHomeTransactionsProvider);

    return MobilePlatformScope(
      child: ColoredBox(
        color: AppColors.background,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              MobileHomeHeader(
                onAvatarTap: () => context.push(AppRoutes.editProfile),
                onBusinessTap: () => switchCompanyFromMobile(context, ref),
                onSettingsTap: () => context.push(AppRoutes.settings),
                onNotificationTap: () => context.push(AppRoutes.notifications),
                onSyncTap: () {
                  unawaited(
                    ref
                        .read(manualSyncVisualStateProvider.notifier)
                        .syncNow(),
                  );
                },
              ),
              MobileHomeViewToggle(
                activeView: homeState.activeView,
                onChanged: ref.read(mobileHomeControllerProvider.notifier).setView,
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (isPartyView) {
                      await ref.read(partyListProvider.notifier).refresh();
                    } else {
                      await refreshMobileHomeTransactions(ref);
                    }
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: MobileHomeQuickLinks(
                          links: isPartyView
                              ? _partyQuickLinks()
                              : _txnQuickLinks(),
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
                              ref.read(selectedPartyIdProvider.notifier).selected =
                                  partyId;
                              unawaited(context.push(AppRoutes.partyDetails));
                            },
                          ),
                        )
                      else
                        transactionsAsync.when(
                          loading: () => const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, _) => SliverFillRemaining(
                            child: AppError(
                              message: error.toString(),
                              onRetry: () =>
                                  unawaited(refreshMobileHomeTransactions(ref)),
                            ),
                          ),
                          data: (allTransactions) {
                            final transactions = filterHomeTransactions(
                              allTransactions,
                              homeState.searchQuery,
                              typeFilters: homeState.transactionTypeFilters,
                            );

                            if (transactions.isEmpty) {
                              return const SliverFillRemaining(
                                hasScrollBody: false,
                                child: MobileEmptyState(
                                  title: 'No transactions found',
                                  message: 'Try a different search term.',
                                  icon: Icons.receipt_long_outlined,
                                ),
                              );
                            }

                            return SliverPadding(
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
                            );
                          },
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: MobileBottomNavigation.barHeight + AppSpacing.md,
                        ),
                      ),
                    ],
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
