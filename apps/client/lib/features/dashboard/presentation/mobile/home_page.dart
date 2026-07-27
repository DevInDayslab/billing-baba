import 'dart:async';

import 'package:billing_baba/core/platform/mobile_platform_scope.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_option_sheet.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_sheets.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_controller.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_mock_data.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_header.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_quick_links.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_search_bar.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_transaction_card.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_view_toggle.dart';
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
  String _activeFilterKey = 'all';

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
    unawaited(
      showMobileFilterSheet<String>(
        context: context,
        title: 'Filter Transactions',
        selected: _activeFilterKey,
        options: const [
          MobileOption(
            value: 'all',
            label: 'All Transactions',
            subtitle: 'Show every transaction type',
          ),
          MobileOption(
            value: 'payment_in',
            label: 'Payment In',
            subtitle: 'Received payments',
          ),
          MobileOption(
            value: 'sale',
            label: 'Sales',
            subtitle: 'Sale invoices',
          ),
          MobileOption(
            value: 'estimate',
            label: 'Estimates',
            subtitle: 'Open estimates',
          ),
        ],
      ).then((value) {
        if (value == null || !mounted) return;
        setState(() => _activeFilterKey = value);
      }),
    );
  }

  void _showAddTxnSheet() {
    unawaited(
      showMobileAddOptionsSheet(
        context: context,
        title: 'Add Transaction',
        options: [
          MobileAddOption(
            label: 'Sale Invoice',
            subtitle: 'Create a new sale',
            icon: Icons.receipt_long_outlined,
            iconColor: const Color(0xFF43A047),
            backgroundColor: const Color(0xFFE8F5E9),
            onTap: () => context.push(AppRoutes.addSale),
          ),
          MobileAddOption(
            label: 'Purchase Bill',
            subtitle: 'Record a purchase',
            icon: Icons.shopping_bag_outlined,
            iconColor: const Color(0xFF1565C0),
            backgroundColor: const Color(0xFFE3F2FD),
            onTap: () => context.push(AppRoutes.addPurchase),
          ),
          MobileAddOption(
            label: 'Expense',
            subtitle: 'Log a business expense',
            icon: Icons.payments_outlined,
            iconColor: const Color(0xFFFF9800),
            backgroundColor: const Color(0xFFFFF3E0),
            onTap: () => context.push(AppRoutes.purchaseExpenses),
          ),
          MobileAddOption(
            label: 'Estimate',
            subtitle: 'Create a quotation',
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF5D5FEF),
            backgroundColor: const Color(0xFFEDE7F6),
            onTap: () => context.push(AppRoutes.addEstimate),
          ),
        ],
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
            onTap: () {},
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

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(mobileHomeControllerProvider);
    final transactions = filterHomeTransactions(
      MobileHomeMockData.transactions,
      homeState.searchQuery,
    );

    return MobilePlatformScope(
      child: ColoredBox(
        color: AppColors.background,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              MobileHomeHeader(
                onBusinessTap: () => context.push(AppRoutes.businessList),
                onSettingsTap: () => context.push(AppRoutes.settingsPreferences),
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon')),
                  );
                },
                onSyncTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Syncing…')),
                  );
                },
              ),
              MobileHomeViewToggle(
                activeView: homeState.activeView,
                onChanged: (view) {
                  ref.read(mobileHomeControllerProvider.notifier).setView(view);
                  if (view == MobileHomeView.partyDetails) {
                    unawaited(context.push(AppRoutes.partyDetails));
                    ref
                        .read(mobileHomeControllerProvider.notifier)
                        .setView(MobileHomeView.transactionDetails);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: MobileHomeQuickLinks(
                        links: MobileHomeMockData.quickLinks(
                          onTxnSettings: () => context.push(
                            AppRoutes.settingsTransactionMessages,
                          ),
                          onAddTxn: _showAddTxnSheet,
                          onSaleReport: () => context.push(AppRoutes.reports),
                          onShowAll: () {
                            unawaited(
                              showMobileMenuSheet(
                                context: context,
                                title: 'Show All',
                                items: [
                                  MobileSheetAction(
                                    icon: Icons.receipt_long_outlined,
                                    label: 'Sales',
                                    showChevron: true,
                                    onTap: () =>
                                        context.push(AppRoutes.saleInvoices),
                                  ),
                                  MobileSheetAction(
                                    icon: Icons.shopping_bag_outlined,
                                    label: 'Purchases',
                                    showChevron: true,
                                    onTap: () =>
                                        context.push(AppRoutes.purchaseBills),
                                  ),
                                  MobileSheetAction(
                                    icon: Icons.people_outline_rounded,
                                    label: 'Parties',
                                    showChevron: true,
                                    onTap: () =>
                                        context.push(AppRoutes.partyDetails),
                                  ),
                                  MobileSheetAction(
                                    icon: Icons.bar_chart_rounded,
                                    label: 'Reports',
                                    showChevron: true,
                                    onTap: () => context.push(AppRoutes.reports),
                                  ),
                                ],
                              ),
                            );
                          },
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
                      ),
                    ),
                    if (transactions.isEmpty)
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
                              onShare: () {},
                              onMore: () => _showMoreActions(item),
                            );
                          },
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: MobileBottomNavigation.barHeight + AppSpacing.md,
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
