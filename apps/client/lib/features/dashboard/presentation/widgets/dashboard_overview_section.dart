import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardOverviewSection extends StatelessWidget {
  const DashboardOverviewSection({
    required this.overview,
    required this.finance,
    required this.onReceivableTap,
    required this.onPayableTap,
    super.key,
  });

  final DashboardOverviewModel overview;
  final DashboardFinanceModel finance;
  final VoidCallback onReceivableTap;
  final VoidCallback onPayableTap;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 992
            ? 4
            : width >= 480
            ? 2
            : 1;
        const gap = DashboardSpacing.widgetGap;

        final cards = [
          _OverviewMetricCard(
            title: 'Total Receivable',
            amount: overview.totalReceivable,
            subtitle: overview.receivablePartyCount == 0
                ? "You don't have any receivables as of now."
                : _partyCountLabel(overview.receivablePartyCount),
            trailing: const Icon(
              Icons.account_balance_wallet_outlined,
              color: DashboardColors.incoming,
              size: 20,
            ),
            onTap: onReceivableTap,
            currencyFormat: _currencyFormat,
          ),
          _OverviewMetricCard(
            title: 'Total Payable',
            amount: overview.totalPayable,
            subtitle: overview.payablePartyCount == 0
                ? "You don't have any payables as of now."
                : _partyCountLabel(overview.payablePartyCount),
            trailing: const Icon(
              Icons.account_balance_wallet_outlined,
              color: DashboardColors.outgoing,
              size: 20,
            ),
            onTap: onPayableTap,
            currencyFormat: _currencyFormat,
          ),
          _OverviewMetricCard(
            title: 'Cash In (Today)',
            amount: finance.cashIn,
            subtitle: 'Today',
            trailing: const Icon(
              Icons.payments_outlined,
              color: DashboardColors.incoming,
              size: 20,
            ),
            currencyFormat: _currencyFormat,
          ),
          _OverviewMetricCard(
            title: 'Cash Out (Today)',
            amount: finance.cashOut,
            subtitle: 'Today',
            trailing: const Icon(
              Icons.payments_outlined,
              color: DashboardColors.outgoing,
              size: 20,
            ),
            currencyFormat: _currencyFormat,
          ),
        ];

        if (columns == 1) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: gap),
                cards[i],
              ],
            ],
          );
        }

        if (columns == 2) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: gap),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: gap),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: gap),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: gap),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.trailing,
    required this.currencyFormat,
    this.onTap,
  });

  final String title;
  final double amount;
  final String subtitle;
  final Widget trailing;
  final NumberFormat currencyFormat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DashboardMetricCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: DashboardTypography.supportingLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing,
            ],
          ),
          const SizedBox(height: DashboardSpacing.titleToValue),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              currencyFormat.format(amount),
              style: DashboardTypography.mainValue,
            ),
          ),
          const SizedBox(height: DashboardSpacing.valueToContent),
          Text(
            subtitle,
            style: DashboardTypography.metadata,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

String _partyCountLabel(int count) {
  if (count == 1) return 'From 1 Party';
  return 'From $count Parties';
}
