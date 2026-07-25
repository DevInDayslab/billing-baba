import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PartyLedgerSummaryCards extends StatelessWidget {
  const PartyLedgerSummaryCards({
    required this.summary,
    required this.party,
    super.key,
  });

  final PartyLedgerSummaryModel summary;
  final PartyModel party;

  static final _dateFormat = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _SummaryCard(
        label: 'Opening Balance',
        value: PartyModel.displayCurrency(summary.openingBalance),
      ),
      _SummaryCard(
        label: 'Outstanding',
        value: PartyModel.displayOutstanding(summary.outstanding),
      ),
      _SummaryCard(
        label: 'Credit Limit',
        value: PartyModel.displayCreditLimit(
          hasCustomCreditLimit: party.hasCustomCreditLimit,
          creditLimit: party.creditLimit,
        ),
      ),
      _SummaryCard(
        label: 'Status',
        value: summary.isActive ? 'Active' : 'Inactive',
      ),
      if (summary.hasReceivable)
        _SummaryCard(
          label: 'To Receive',
          value: PartyModel.displayCurrency(summary.receiveAmount),
          valueColor: listPanelPositiveColor,
        )
      else if (summary.hasPayable)
        _SummaryCard(
          label: 'To Pay',
          value: PartyModel.displayCurrency(summary.payableAmount),
          valueColor: listPanelNegativeColor,
        ),
      if (summary.lastTransactionDate != null)
        _SummaryCard(
          label: 'Last Transaction',
          value: _dateFormat.format(summary.lastTransactionDate!),
        ),
      _SummaryCard(
        label: 'Total Sales',
        value: PartyModel.displayCurrency(summary.totalSales),
      ),
      _SummaryCard(
        label: 'Total Purchases',
        value: PartyModel.displayCurrency(summary.totalPurchases),
      ),
      _SummaryCard(
        label: 'Total Payments',
        value: PartyModel.displayCurrency(summary.totalPayments),
      ),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: cards,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: listPanelCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
