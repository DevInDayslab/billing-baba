import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_transaction_navigation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PartyLedgerFilterBar extends StatelessWidget {
  const PartyLedgerFilterBar({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final PartyLedgerFilter selected;
  final ValueChanged<PartyLedgerFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in PartyLedgerFilter.values) ...[
            if (filter != PartyLedgerFilter.values.first)
              const SizedBox(width: AppSpacing.sm),
            ChoiceChip(
              label: Text(filter.label),
              selected: selected == filter,
              onSelected: (_) => onSelected(filter),
              selectedColor: AppColors.primary.withValues(alpha: 0.12),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected == filter
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: selected == filter
                    ? AppColors.primary
                    : listPanelCardBorder,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ],
        ],
      ),
    );
  }
}

class PartyLedgerTransactionsTable extends StatelessWidget {
  const PartyLedgerTransactionsTable({
    required this.transactions,
    this.isFiltered = false,
    super.key,
  });

  final List<PartyLedgerTransactionModel> transactions;
  final bool isFiltered;

  static final _dateFormat = DateFormat('d MMM yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _TransactionsEmptyState(isFiltered: isFiltered);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _TransactionRow(
          transaction: tx,
          dateFormat: _dateFormat,
          currencyFormat: _currencyFormat,
          onTap: () => navigateToPartyLedgerTransaction(context, tx),
        );
      },
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onTap,
  });

  final PartyLedgerTransactionModel transaction;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final refNo = transaction.referenceNumber?.trim();
    final description = transaction.description?.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 88,
                child: Text(
                  dateFormat.format(transaction.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.type,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (refNo != null && refNo.isNotEmpty)
                      Text(
                        refNo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (description != null && description.isNotEmpty)
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  transaction.debit > 0
                      ? currencyFormat.format(transaction.debit)
                      : '-',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  transaction.credit > 0
                      ? currencyFormat.format(transaction.credit)
                      : '-',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(
                width: 88,
                child: Text(
                  currencyFormat.format(transaction.balanceAfter),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class PartyLedgerTableHeader extends StatelessWidget {
  const PartyLedgerTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              'Date',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Type / Ref / Description',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(
              'Debit',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(
              'Credit',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 88,
            child: Text(
              'Balance',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsEmptyState extends StatelessWidget {
  const _TransactionsEmptyState({this.isFiltered = false});

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isFiltered
                  ? 'No matching transactions'
                  : 'No transactions yet',
              style: ListPanelStyles.emptyStateStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isFiltered
                  ? 'Try a different filter or clear the current selection.'
                  : 'Sales, purchases and payments involving this party will appear here.',
              style: ListPanelStyles.emptyStateStyle.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
