import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_transaction_card.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/hidden_ledger_history_section.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/hidden_ledger_summary_tile.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_actions.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_avatar.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_whatsapp_actions.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_more_actions_sheet.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_payment_sheets.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_ledger_print_actions.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_ledger_transaction_table_actions.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_transaction_navigation.dart';
import 'package:billing_baba/shared/utils/date_time_utils.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Mobile party detail view (info, quick actions, transactions).
class MobilePartyDetailScreen extends ConsumerWidget {
  const MobilePartyDetailScreen({
    required this.partyId,
    required this.onBack,
    super.key,
  });

  final String partyId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(partyDetailProvider(partyId));

    return detailAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: MobileAppBar(
          title: 'Party Details',
          showBackButton: true,
          onBack: onBack,
          showBusinessHeader: false,
          showNotification: false,
          showSettings: false,
        ),
        body: _PartyDetailError(
          message: PartyErrorMapper.messageFor(error),
          onRetry: () => ref.invalidate(partyDetailProvider(partyId)),
        ),
      ),
      data: (party) => _PartyDetailBody(
        party: party,
        onBack: onBack,
      ),
    );
  }
}

class _PartyDetailBody extends ConsumerStatefulWidget {
  const _PartyDetailBody({
    required this.party,
    required this.onBack,
  });

  final PartyModel party;
  final VoidCallback onBack;

  @override
  ConsumerState<_PartyDetailBody> createState() => _PartyDetailBodyState();
}

class _PartyDetailBodyState extends ConsumerState<_PartyDetailBody> {
  static const _pageSize = 15;

  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  var _searchQuery = '';
  PartyLedgerFilter _filter = PartyLedgerFilter.all;
  int _visibleCount = _pageSize;
  var _isLoadingMore = false;

  PartyModel get party => widget.party;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openAddSale() {
    final uri = Uri(
      path: AppRoutes.addSale,
      queryParameters: {
        'partyId': party.id,
        'partyName': party.name,
      },
    );
    unawaited(context.push(uri.toString()));
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 240) return;
    _loadMore();
  }

  void _loadMore() {
    final ledger = ref.read(partyTimelineProvider(party.id)).value;
    if (ledger == null) return;

    final filtered = _filterTransactions(ledger.transactions);
    if (_visibleCount >= filtered.length) return;

    setState(() {
      _isLoadingMore = true;
      _visibleCount = (_visibleCount + _pageSize).clamp(0, filtered.length);
    });

    // Brief delay so the footer spinner is visible on fast devices.
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    });
  }

  void _resetPagination() {
    _visibleCount = _pageSize;
    _isLoadingMore = false;
  }

  List<PartyLedgerTransactionModel> _filterTransactions(
    List<PartyLedgerTransactionModel> transactions,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    return transactions.where((tx) {
      if (!_filter.matches(tx)) return false;
      if (query.isEmpty) return true;
      final haystack = [
        tx.type,
        tx.sourceType,
        tx.referenceNumber ?? '',
        tx.description ?? '',
        tx.status ?? '',
        tx.paymentStatus ?? '',
        tx.total.toStringAsFixed(2),
        tx.balance.toStringAsFixed(2),
        DateTimeUtils.formatDisplayDateTime(tx.createdAt),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> _openFilterSheet() async {
    final selected = await showMobileFilterSheet<PartyLedgerFilter>(
      context: context,
      title: 'Filter transactions',
      selected: _filter,
      options: [
        for (final filter in PartyLedgerFilter.values)
          MobileOption(value: filter, label: filter.label),
      ],
    );
    if (selected == null || !mounted) return;
    setState(() {
      _filter = selected;
      _resetPagination();
    });
  }

  Future<void> _printLedger({
    required PartyModel party,
    required double outstanding,
    double? creditLimit,
  }) async {
    final ledger = ref.read(partyTimelineProvider(party.id)).value;
    final transactions = ledger?.transactions ?? const [];
    await PartyLedgerPrintActions.previewLedger(
      context: context,
      ref: ref,
      party: party,
      transactions: transactions,
      outstanding: outstanding,
      creditLimit: creditLimit ?? ledger?.summary.creditLimit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(partyTimelineProvider(party.id));
    final permissions = ref.watch(permissionServiceProvider);
    final canEditParty = permissions.canEdit(PermissionModule.party);
    final canViewHiddenLedger = permissions.canViewHiddenLedger;
    final canShareMessaging =
        permissions.canShare(PermissionModule.party) ||
        permissions.canShare(PermissionModule.sale);
    final outstanding = ledgerAsync.maybeWhen(
      data: (ledger) => ledger.summary.outstanding,
      orElse: () => party.balance,
    );
    final outstandingLabel = ledgerAsync.maybeWhen(
      data: (ledger) =>
          PartyModel.displayOutstanding(ledger.summary.outstanding),
      orElse: () => PartyModel.displayOutstanding(party.balance),
    );
    final creditLimit = ledgerAsync.maybeWhen(
      data: (ledger) => ledger.summary.creditLimit,
      orElse: () => null,
    );
    final creditLimitLabel = ledgerAsync.maybeWhen(
      data: (ledger) {
        final limit = ledger.summary.creditLimit;
        if (limit != null) return PartyModel.formatCurrency(limit);
        return PartyModel.displayCreditLimit(
          hasCustomCreditLimit: party.hasCustomCreditLimit,
          creditLimit: party.creditLimit,
        );
      },
      orElse: () => PartyModel.displayCreditLimit(
        hasCustomCreditLimit: party.hasCustomCreditLimit,
        creditLimit: party.creditLimit,
      ),
    );

    final filtered = ledgerAsync.maybeWhen(
      data: (ledger) => _filterTransactions(ledger.transactions),
      orElse: () => const <PartyLedgerTransactionModel>[],
    );
    final visible = filtered.take(_visibleCount).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      extendBody: true,
      appBar: MobileAppBar(
        title: 'Party Details',
        showBackButton: true,
        onBack: widget.onBack,
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
        backgroundColor: const Color(0xFFEAF4FF),
        actions: [
          MobileIconActionButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit party',
            onPressed: canEditParty
                ? () => PartyActions.edit(context, ref, party)
                : null,
          ),
          MobileIconActionButton(
            icon: Icons.more_horiz_rounded,
            tooltip: 'More actions',
            onPressed: () => showPartyMoreActionsSheet(
              context: context,
              ref: ref,
              party: party,
              outstanding: outstanding,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: PartyActions.canReceivePayment(party)
                        ? () => showMobileReceivePaymentSheet(
                            context: context,
                            ref: ref,
                            party: party,
                          )
                        : PartyActions.canRecordPayment(party)
                        ? () => showMobileRecordPaymentSheet(
                            context: context,
                            ref: ref,
                            party: party,
                          )
                        : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text('Take Payment'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: _openAddSale,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text('Add Sale'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final detail = partyDetailProvider(party.id);
          ref
            ..invalidate(detail)
            ..invalidate(partyTimelineProvider(party.id));
          await ref.read(partyDetailProvider(party.id).future);
          if (mounted) setState(_resetPagination);
        },
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            120,
          ),
          children: [
            _MinimalPartySummaryCard(
              party: party,
              outstandingLabel: outstandingLabel,
              creditLimitLabel: creditLimitLabel,
              onAvatarTap: canEditParty
                  ? () => PartyActions.edit(context, ref, party)
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _MinimalActionRow(
              onReminderTap: canShareMessaging
                  ? () => PartyWhatsAppActions.sendPaymentReminderNow(
                      context,
                      ref,
                      party,
                      outstanding: outstanding,
                    )
                  : null,
              onStatementTap: () => unawaited(
                _printLedger(
                  party: party,
                  outstanding: outstanding,
                  creditLimit: creditLimit,
                ),
              ),
            ),
            if (canViewHiddenLedger) ...[
              const SizedBox(height: AppSpacing.md),
              HiddenLedgerSummaryTile(partyId: party.id),
              HiddenLedgerHistorySection(partyId: party.id),
            ],
            const SizedBox(height: AppSpacing.md),
            _TransactionSearchBar(
              controller: _searchController,
              isFilterActive: _filter != PartyLedgerFilter.all,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _resetPagination();
                });
              },
              onFilterTap: () => unawaited(_openFilterSheet()),
              onPrintTap: () => unawaited(
                _printLedger(
                  party: party,
                  outstanding: outstanding,
                  creditLimit: creditLimit,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PartyTransactionsSection(
              party: party,
              ledgerAsync: ledgerAsync,
              visibleTransactions: visible,
              filteredCount: filtered.length,
              hasActiveQuery:
                  _searchQuery.trim().isNotEmpty ||
                  _filter != PartyLedgerFilter.all,
            ),
            if (_isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TransactionSearchBar extends StatelessWidget {
  const _TransactionSearchBar({
    required this.controller,
    required this.onSearchChanged,
    required this.onFilterTap,
    this.onPrintTap,
    this.isFilterActive = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback? onPrintTap;
  final bool isFilterActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MobileSearchField(
            controller: controller,
            hint: 'Search Transactions',
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Material(
          color: isFilterActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFilterActive
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : const Color(0xFFD9E7F6),
                ),
              ),
              child: Icon(
                Icons.filter_list_rounded,
                color: isFilterActive
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        if (onPrintTap != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onPrintTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD9E7F6)),
                ),
                child: const Icon(
                  Icons.print_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PartyTransactionsSection extends ConsumerWidget {
  const _PartyTransactionsSection({
    required this.party,
    required this.ledgerAsync,
    required this.visibleTransactions,
    required this.filteredCount,
    required this.hasActiveQuery,
  });

  final PartyModel party;
  final AsyncValue<PartyLedgerModel> ledgerAsync;
  final List<PartyLedgerTransactionModel> visibleTransactions;
  final int filteredCount;
  final bool hasActiveQuery;

  Future<void> _showTransactionMoreMenu(
    BuildContext context,
    WidgetRef ref,
    PartyLedgerTransactionModel transaction,
  ) async {
    final entries = PartyLedgerTransactionTableActions.menuEntriesFor(
      transaction,
      forMobile: true,
    );
    if (entries.isEmpty) return;

    await showMobileMoreActionsSheet(
      context: context,
      title: PartyModel.displayOrDash(transaction.referenceNumber),
      actions: [
        for (final entry in entries)
          MobileSheetAction(
            label: entry.label,
            onTap: () => unawaited(
              PartyLedgerTransactionTableActions.handleAction(
                context: context,
                ref: ref,
                transaction: transaction,
                action: entry.action,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ledgerAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          PartyErrorMapper.messageFor(error),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.error,
          ),
        ),
      ),
      data: (ledger) {
        if (ledger.transactions.isEmpty) {
          return _OpeningBalanceCard(party: party);
        }
        if (filteredCount == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                hasActiveQuery
                    ? 'No transactions match your search or filter.'
                    : 'No transactions yet.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }
        return Column(
          children: [
            for (final tx in visibleTransactions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: MobileHomeTransactionCard(
                  item: _mapLedgerTransaction(party: party, transaction: tx),
                  onTap: () =>
                      navigateToPartyLedgerTransaction(context, tx),
                  onPrint: () => unawaited(
                    PartyLedgerTransactionTableActions.handleAction(
                      context: context,
                      ref: ref,
                      transaction: tx,
                      action: 'print',
                    ),
                  ),
                  onShare: () => unawaited(
                    PartyLedgerTransactionTableActions.handleAction(
                      context: context,
                      ref: ref,
                      transaction: tx,
                      action: 'share',
                    ),
                  ),
                  onMore: () => unawaited(
                    _showTransactionMoreMenu(context, ref, tx),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

MobileHomeTransactionItem _mapLedgerTransaction({
  required PartyModel party,
  required PartyLedgerTransactionModel transaction,
}) {
  final kind = PartyLedgerTransactionTableActions.kindFor(transaction);
  final typeTag = _typeTag(kind, transaction);
  final status = _statusText(transaction);
  final statusLabel = status == null
      ? typeTag.toUpperCase()
      : '${typeTag.toUpperCase()} : ${status.toUpperCase()}';
  final statusType = _statusType(kind, status);
  final filterType = _filterType(kind);

  final total = transaction.total > 0
      ? transaction.total
      : (transaction.debit > 0 ? transaction.debit : transaction.credit);
  final balance = transaction.balance > 0 || transaction.balanceAfter == 0
      ? transaction.balance
      : transaction.balanceAfter;

  final dateLabel = DateFormat(
    'dd MMM, yy · hh:mm a',
  ).format(transaction.createdAt.toLocal());

  final dueDate = transaction.dueDate;
  final dueDateLabel = dueDate == null
      ? null
      : 'Due : ${DateTimeUtils.formatDisplayDate(dueDate)}';

  final currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  return MobileHomeTransactionItem(
    id: transaction.id,
    partyName: party.name,
    documentNumber: PartyModel.displayOrDash(transaction.referenceNumber),
    statusLabel: statusLabel,
    statusType: statusType,
    filterType: filterType,
    dateLabel: dateLabel,
    totalLabel: currency.format(total),
    balanceLabel: 'Balance',
    balanceValueLabel: currency.format(balance),
    dueDateLabel: dueDateLabel,
  );
}

String _typeTag(
  PartyLedgerTransactionKind kind,
  PartyLedgerTransactionModel transaction,
) {
  return switch (kind) {
    PartyLedgerTransactionKind.saleInvoice => 'Sale',
    PartyLedgerTransactionKind.saleReturn => 'Credit Note',
    PartyLedgerTransactionKind.estimate => 'Estimate',
    PartyLedgerTransactionKind.proforma => 'Proforma',
    PartyLedgerTransactionKind.saleOrder => 'Sale Order',
    PartyLedgerTransactionKind.deliveryChallan => 'Challan',
    PartyLedgerTransactionKind.saleFa => 'Sale FA',
    PartyLedgerTransactionKind.purchaseBill => 'Purchase',
    PartyLedgerTransactionKind.purchaseReturn => 'Debit Note',
    PartyLedgerTransactionKind.purchaseOrder => 'Purchase Order',
    PartyLedgerTransactionKind.purchaseFa => 'Purchase FA',
    PartyLedgerTransactionKind.jobWork => 'Job Work',
    PartyLedgerTransactionKind.paymentIn => 'Payment-In',
    PartyLedgerTransactionKind.paymentOut => 'Payment-Out',
    PartyLedgerTransactionKind.expense => 'Expense',
    PartyLedgerTransactionKind.unknown =>
      transaction.type.trim().isEmpty ? 'Txn' : transaction.type.trim(),
  };
}

String? _statusText(PartyLedgerTransactionModel transaction) {
  final status = transaction.status?.trim();
  if (status != null && status.isNotEmpty) return status;

  final paymentStatus = transaction.paymentStatus?.trim();
  if (paymentStatus != null && paymentStatus.isNotEmpty) return paymentStatus;

  return switch (transaction.entryType) {
    'payment' => transaction.isPayment ? 'Unused' : 'Paid',
    'return' => 'Returned',
    _ => null,
  };
}

MobileHomeTransactionStatusType _statusType(
  PartyLedgerTransactionKind kind,
  String? status,
) {
  final normalized = (status ?? '').toLowerCase();
  if (kind == PartyLedgerTransactionKind.paymentIn ||
      kind == PartyLedgerTransactionKind.paymentOut) {
    return MobileHomeTransactionStatusType.payinUnused;
  }
  if (normalized.contains('paid') || normalized.contains('closed')) {
    return MobileHomeTransactionStatusType.salePaid;
  }
  return MobileHomeTransactionStatusType.estimateOpen;
}

MobileHomeTransactionFilterType _filterType(PartyLedgerTransactionKind kind) {
  return switch (kind) {
    PartyLedgerTransactionKind.saleInvoice ||
    PartyLedgerTransactionKind.proforma ||
    PartyLedgerTransactionKind.deliveryChallan ||
    PartyLedgerTransactionKind.saleFa =>
      MobileHomeTransactionFilterType.sale,
    PartyLedgerTransactionKind.saleOrder =>
      MobileHomeTransactionFilterType.saleOrder,
    PartyLedgerTransactionKind.saleReturn =>
      MobileHomeTransactionFilterType.creditNote,
    PartyLedgerTransactionKind.estimate =>
      MobileHomeTransactionFilterType.estimate,
    PartyLedgerTransactionKind.purchaseBill ||
    PartyLedgerTransactionKind.purchaseFa ||
    PartyLedgerTransactionKind.expense ||
    PartyLedgerTransactionKind.jobWork =>
      MobileHomeTransactionFilterType.purchase,
    PartyLedgerTransactionKind.purchaseOrder =>
      MobileHomeTransactionFilterType.purchaseOrder,
    PartyLedgerTransactionKind.purchaseReturn =>
      MobileHomeTransactionFilterType.debitNote,
    PartyLedgerTransactionKind.paymentIn =>
      MobileHomeTransactionFilterType.paymentIn,
    PartyLedgerTransactionKind.paymentOut =>
      MobileHomeTransactionFilterType.paymentOut,
    PartyLedgerTransactionKind.unknown => MobileHomeTransactionFilterType.sale,
  };
}

class _MinimalPartySummaryCard extends StatelessWidget {
  const _MinimalPartySummaryCard({
    required this.party,
    required this.outstandingLabel,
    required this.creditLimitLabel,
    this.onAvatarTap,
  });

  final PartyModel party;
  final String outstandingLabel;
  final String creditLimitLabel;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final outstandingColor = party.hasReceivable
        ? const Color(0xFF20B283)
        : party.hasPayable
        ? AppColors.error
        : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E7F6)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              PartyAvatar(
                name: party.name,
                seed: party.id,
                partyId: party.id,
                diameter: 48,
                profileImageUrl: party.profileImageUrl,
                profileMediaAssetId: party.profileMediaAssetId,
                onTap: onAvatarTap,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      party.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      PartyModel.displayPhones(party),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    party.hasReceivable
                        ? 'Receivable: $outstandingLabel'
                        : 'Balance: $outstandingLabel',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: outstandingColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Credit Limit: $creditLimitLabel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MinimalActionRow extends StatelessWidget {
  const _MinimalActionRow({
    required this.onReminderTap,
    required this.onStatementTap,
  });

  final VoidCallback? onReminderTap;
  final VoidCallback? onStatementTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E7F6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: onReminderTap,
              icon: const Icon(Icons.notifications_none_rounded),
              label: const Text('Send Reminder'),
            ),
          ),
          Container(width: 1, height: 28, color: const Color(0xFFD9E7F6)),
          Expanded(
            child: TextButton.icon(
              onPressed: onStatementTap,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Send Statement'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningBalanceCard extends StatelessWidget {
  const _OpeningBalanceCard({required this.party});

  final PartyModel party;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E7F6)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opening balance',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _currency.format(party.balance),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyDetailError extends StatelessWidget {
  const _PartyDetailError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
