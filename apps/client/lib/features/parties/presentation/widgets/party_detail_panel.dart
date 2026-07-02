import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_transaction_model.dart';
import 'package:billing_baba/features/parties/presentation/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/parties/presentation/widgets/edit_party_transaction_dialog.dart';
import 'package:billing_baba/features/parties/providers/parties_provider.dart';
import 'package:billing_baba/features/parties/providers/party_transactions_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _invoiceColWidth = 120.0;
const _dateColWidth = 150.0;
const _typeColWidth = 110.0;
const _paymentColWidth = 100.0;
const _amountColWidth = 110.0;
const _balanceColWidth = 110.0;
const _statusColWidth = 100.0;

const _actionsColWidth = 44.0;
const _tableHorizontalPadding = 32.0;

const _minTableWidth =
    _invoiceColWidth +
    _dateColWidth +
    _typeColWidth +
    _paymentColWidth +
    _amountColWidth +
    _balanceColWidth +
    _statusColWidth +
    _actionsColWidth +
    _tableHorizontalPadding;

const _successSnackBarColor = Color(0xFF2E7D32);

class PartyDetailPanel extends ConsumerWidget {
  const PartyDetailPanel({required this.party, super.key});

  final PartyModel party;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(allPartyTransactionsProvider);
    final transactions = allTransactions
        .where((txn) => txn.partyId == party.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return LayoutBuilder(
      builder: (context, constraints) {
        final useFlexibleSummary = constraints.maxHeight < 520;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (useFlexibleSummary)
              Flexible(
                flex: 2,
                child: SingleChildScrollView(
                  child: _PartySummaryHeader(party: party),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: _PartySummaryHeader(party: party),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Flexible(
                    child: Text(
                      'TRANSACTIONS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: transactions.isEmpty
                        ? null
                        : () => _onPrintTransactions(context, party.name),
                    icon: const Icon(Icons.print_outlined, size: 20),
                    color: AppColors.textSecondary,
                    tooltip: 'Print',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: transactions.isEmpty
                  ? const Center(
                      child: Text(
                        'No transactions found',
                        style: ListPanelStyles.emptyStateStyle,
                      ),
                    )
                  : _TransactionsTable(
                      transactions: transactions,
                      onEdit: (transaction) async {
                        final updated = await showEditPartyTransactionDialog(
                          context,
                          transaction: transaction,
                        );
                        if (updated == null) return;

                        ref
                            .read(allPartyTransactionsProvider.notifier)
                            .updateTransaction(updated);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _onPrintTransactions(BuildContext context, String partyName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Print transactions for $partyName')),
    );
  }
}

class _PartySummaryHeader extends ConsumerWidget {
  const _PartySummaryHeader({required this.party});

  final PartyModel party;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailRows = _buildDetailRows();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: listPanelCardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  party.name,
                  style: ListPanelStyles.panelTitleStyle,
                ),
              ),
              IconButton(
                onPressed: () => _editParty(context, ref),
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.primary,
                tooltip: 'Edit party',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  party.phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (detailRows.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: listPanelCardBorder),
            const SizedBox(height: AppSpacing.md),
            _PartyDetailsTable(rows: detailRows),
          ],
        ],
      ),
    );
  }

  List<_PartyDetailItem> _buildDetailRows() {
    final rows = <_PartyDetailItem>[];

    void add(String label, String? value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) {
        rows.add(_PartyDetailItem(label: label, value: trimmed));
      }
    }

    rows.insert(
      0,
      _PartyDetailItem(
        label: 'Party Group',
        value: party.partyGroup.isNotEmpty ? party.partyGroup : 'Not set',
      ),
    );

    add('GSTIN', party.gstin);
    if (party.gstType.isNotEmpty &&
        party.gstType != 'Unregistered/Consumer') {
      add('GST Type', party.gstType);
    }
    if (party.state.isNotEmpty && party.state != 'Andhra Pradesh') {
      add('State', party.state);
    }
    add('Email', party.email);
    add('Billing Address', party.billingAddress);
    add('Shipping Address', party.shippingAddress);

    if (party.balance != 0 || party.openingBalanceAsOfDate != null) {
      final asOf = party.openingBalanceAsOfDate != null
          ? ' (as of ${_dateFormat.format(party.openingBalanceAsOfDate!)})'
          : '';
      rows.add(_PartyDetailItem(
        label: 'Opening Balance',
        value: '${_currencyFormat.format(party.balance)}$asOf',
      ));
    }

    if (party.loyaltyPointsOpeningBalance.isNotEmpty) {
      final asOf = party.loyaltyPointsAsOfDate != null
          ? ' (as of ${_dateFormat.format(party.loyaltyPointsAsOfDate!)})'
          : '';
      rows.add(_PartyDetailItem(
        label: 'Loyalty Points Opening Balance',
        value: '${party.loyaltyPointsOpeningBalance}$asOf',
      ));
    }

    rows.add(_PartyDetailItem(
      label: 'Credit Limit',
      value: party.hasCustomCreditLimit && party.creditLimit.isNotEmpty
          ? _currencyFormat.format(double.tryParse(party.creditLimit) ?? 0)
          : 'No limit',
    ));

    add('Additional Field 1', party.additionalField1);
    add('Additional Field 2', party.additionalField2);

    return rows;
  }

  Future<void> _editParty(BuildContext context, WidgetRef ref) async {
    final result = await showEditPartyDialog(context, party: party);
    if (result == null || !context.mounted) return;

    final saved = ref
        .read(partiesProvider.notifier)
        .updatePartyFromResult(party.id, result);

    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (saved) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'Party "${result.partyName}" updated successfully',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: _successSnackBarColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          'Could not update party "${result.partyName}"',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _PartyDetailItem {
  const _PartyDetailItem({required this.label, required this.value});

  final String label;
  final String value;
}

class _PartyDetailsTable extends StatelessWidget {
  const _PartyDetailsTable({required this.rows});

  final List<_PartyDetailItem> rows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelWidth = constraints.maxWidth < 400 ? 120.0 : 168.0;

        return Table(
          columnWidths: {
            0: FixedColumnWidth(labelWidth),
            1: const FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            for (final row in rows)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                    ),
                    child: Text(
                      row.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      row.value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _TransactionsTable extends StatelessWidget {
  const _TransactionsTable({
    required this.transactions,
    required this.onEdit,
  });

  final List<PartyTransactionModel> transactions;
  final ValueChanged<PartyTransactionModel> onEdit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < _minTableWidth
            ? _minTableWidth
            : constraints.maxWidth;

        return Scrollbar(
          thumbVisibility: constraints.maxWidth < _minTableWidth,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              height: constraints.maxHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _TransactionTableHeader(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return SizedBox(
                          width: tableWidth,
                          child: _TransactionTableRow(
                            key: ValueKey(
                              '${transaction.id}-'
                              '${transaction.invoiceNo}-'
                              '${transaction.date.millisecondsSinceEpoch}-'
                              '${transaction.amount}-'
                              '${transaction.balance}',
                            ),
                            transaction: transaction,
                            onEdit: () => onEdit(transaction),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TransactionTableHeader extends StatelessWidget {
  const _TransactionTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: listPanelCardBorder)),
      ),
      child: const Row(
        children: [
          _HeaderCell(width: _invoiceColWidth, label: 'INVOICE NO'),
          _HeaderCell(width: _dateColWidth, label: 'DATE'),
          _HeaderCell(width: _typeColWidth, label: 'TYPE'),
          _HeaderCell(width: _paymentColWidth, label: 'PAYMENT'),
          _HeaderCell(width: _amountColWidth, label: 'AMOUNT'),
          _HeaderCell(width: _balanceColWidth, label: 'BALANCE'),
          _HeaderCell(width: _statusColWidth, label: 'STATUS'),
          _HeaderCell(width: _actionsColWidth, label: ''),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.width, required this.label});

  final double width;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: ListPanelStyles.listHeaderStyle,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TransactionTableRow extends StatelessWidget {
  const _TransactionTableRow({
    required this.transaction,
    required this.onEdit,
    super.key,
  });

  final PartyTransactionModel transaction;
  final VoidCallback onEdit;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: listPanelCardBorder)),
      ),
      child: Row(
        children: [
          _DataCell(
            width: _invoiceColWidth,
            text: transaction.invoiceNo,
            fontWeight: FontWeight.w500,
          ),
          _DataCell(
            width: _dateColWidth,
            text: _dateFormat.format(transaction.date),
          ),
          _DataCell(width: _typeColWidth, text: transaction.transactionType),
          _DataCell(width: _paymentColWidth, text: transaction.paymentType),
          _DataCell(
            width: _amountColWidth,
            text: _currencyFormat.format(transaction.amount),
          ),
          _DataCell(
            width: _balanceColWidth,
            text: _currencyFormat.format(transaction.balance),
            color: transaction.balance > 0
                ? listPanelNegativeColor
                : AppColors.textPrimary,
          ),
          SizedBox(
            width: _statusColWidth,
            child: SaleInvoiceStatusBadge(status: transaction.status),
          ),
          SizedBox(
            width: _actionsColWidth,
            child: IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.primary,
              tooltip: 'Edit transaction',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.width,
    required this.text,
    this.fontWeight,
    this.color,
  });

  final double width;
  final String text;
  final FontWeight? fontWeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: fontWeight,
          color: color ?? AppColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
