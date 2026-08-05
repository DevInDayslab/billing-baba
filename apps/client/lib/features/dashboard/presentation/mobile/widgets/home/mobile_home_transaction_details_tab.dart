import 'dart:async';

import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_controller.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_transactions_provider.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_transaction_date_filters.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_transaction_type_tabs.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_transaction_card.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_ledger_transaction_table_actions.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_transaction_type_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileHomeTransactionDetailsTab extends ConsumerStatefulWidget {
  const MobileHomeTransactionDetailsTab({super.key});

  @override
  ConsumerState<MobileHomeTransactionDetailsTab> createState() =>
      _MobileHomeTransactionDetailsTabState();
}

class _MobileHomeTransactionDetailsTabState
    extends ConsumerState<MobileHomeTransactionDetailsTab>
    with AutomaticKeepAliveClientMixin {
  late DateTimeRange _dateRange;
  MobileHomeTransactionQuickPeriod _quickPeriod =
      MobileHomeTransactionQuickPeriod.today;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _dateRange = dateRangeForHomeQuickPeriod(_quickPeriod);
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

  void _handlePrint(MobileHomeTransactionItem item) {
    final transaction = item.ledgerTransaction;
    if (transaction == null) return;
    unawaited(
      PartyLedgerTransactionTableActions.handleAction(
        context: context,
        ref: ref,
        transaction: transaction,
        action: 'print',
      ),
    );
  }

  void _handleShare(MobileHomeTransactionItem item) {
    final transaction = item.ledgerTransaction;
    if (transaction == null) return;
    unawaited(
      PartyLedgerTransactionTableActions.handleAction(
        context: context,
        ref: ref,
        transaction: transaction,
        action: 'share',
      ),
    );
  }

  void _exportTransactions(List<MobileHomeTransactionItem> transactions) {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    reportExportTable(
      context: context,
      title: 'Transactions',
      filename: 'home-transactions',
      headers: const [
        'Type',
        'Document',
        'Party',
        'Date',
        'Time',
        'Amount',
        'Payment',
      ],
      rows: [
        for (final item in transactions)
          [
            item.title ?? item.filterType.label,
            item.documentNumber,
            item.partyName,
            item.dateLabel,
            item.timeLabel ?? '',
            item.totalLabel,
            item.paymentMethod ?? '',
          ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final homeState = ref.watch(mobileHomeControllerProvider);
    final transactionsAsync = ref.watch(mobileHomeTransactionsProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Details',
                      style: AppTypography.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Overview of your business transactions',
                      style: AppTypography.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showFilterSheet,
                icon: Icon(Icons.tune_rounded, color: primary, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                tooltip: 'Filter',
              ),
              IconButton(
                onPressed: () {
                  final data = transactionsAsync.value ?? const [];
                  final filtered = resolveMobileHomeDisplayTransactions(
                    source: data,
                    query: homeState.searchQuery,
                    typeFilters: homeState.transactionTypeFilters,
                    dateRange: _dateRange,
                  );
                  _exportTransactions(filtered);
                },
                icon: Icon(Icons.download_rounded, color: primary, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                tooltip: 'Download',
              ),
            ],
          ),
        ),
        MobileHomeTransactionTypeTabs(
          selected: homeState.transactionTypeFilters,
          onChanged: ref
              .read(mobileHomeControllerProvider.notifier)
              .setTransactionTypeFilters,
        ),
        MobileHomeTransactionDateFilters(
          dateRange: _dateRange,
          quickPeriod: _quickPeriod,
          onDateRangeChanged: (range) => setState(() => _dateRange = range),
          onQuickPeriodChanged: (period) =>
              setState(() => _quickPeriod = period),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => refreshMobileHomeTransactions(ref),
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppError(
                message: OfflineUiMessages.messageFor(error),
                onRetry: () => unawaited(refreshMobileHomeTransactions(ref)),
              ),
              data: (allTransactions) {
                final transactions = resolveMobileHomeDisplayTransactions(
                  source: allTransactions,
                  query: homeState.searchQuery,
                  typeFilters: homeState.transactionTypeFilters,
                  dateRange: _dateRange,
                );

                if (transactions.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      MobileEmptyState(
                        title: 'No transactions found',
                        message: 'Try a different search or filter.',
                        icon: Icons.receipt_long_outlined,
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    MobileBottomNavigation.contentBottomPadding(context),
                  ),
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = transactions[index];
                    return MobileHomeTransactionCard(
                      item: item,
                      onPrint: () => _handlePrint(item),
                      onShare: () => _handleShare(item),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
