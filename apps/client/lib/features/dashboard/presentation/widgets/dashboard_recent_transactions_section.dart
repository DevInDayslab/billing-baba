import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/presentation/utils/dashboard_transaction_navigation.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_empty_state.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardRecentTransactionsSection extends StatelessWidget {
  const DashboardRecentTransactionsSection({
    required this.transactions,
    super.key,
  });

  final List<DashboardRecentTransactionModel> transactions;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _dateFormat = DateFormat('d MMM, h:mm a');

  @override
  Widget build(BuildContext context) {
    return DashboardMetricCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Transactions',
                  style: DashboardTypography.cardTitle,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.reports),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All →',
                  style: DashboardTypography.link,
                ),
              ),
            ],
          ),
          const SizedBox(height: DashboardSpacing.headerGap),
          if (transactions.isEmpty)
            DashboardEmptyState(
              icon: Icons.history,
              title: 'No recent transactions',
              subtitle:
                  'Transactions will appear here once you start creating invoices, purchases or payments.',
              actionLabel: 'Create Sale',
              onAction: () => context.push(AppRoutes.addSale),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth >= 560;
                if (!useTwoColumns) {
                  return Column(
                    children: [
                      for (final tx in transactions)
                        _TransactionRow(
                          tx: tx,
                          currencyFormat: _currencyFormat,
                          dateFormat: _dateFormat,
                        ),
                    ],
                  );
                }

                final midpoint = (transactions.length / 2).ceil();
                final left = transactions.sublist(0, midpoint);
                final right = transactions.sublist(midpoint);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          for (final tx in left)
                            _TransactionRow(
                              tx: tx,
                              currencyFormat: _currencyFormat,
                              dateFormat: _dateFormat,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: DashboardSpacing.widgetGap),
                    Expanded(
                      child: Column(
                        children: [
                          for (final tx in right)
                            _TransactionRow(
                              tx: tx,
                              currencyFormat: _currencyFormat,
                              dateFormat: _dateFormat,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.tx,
    required this.currencyFormat,
    required this.dateFormat,
  });

  final DashboardRecentTransactionModel tx;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;

  bool get _isIncoming => dashboardTransactionIsIncoming(tx.type);

  String get _detailLine {
    final typeLabel = dashboardTransactionTypeLabel(tx.type);
    if (tx.referenceNumber.isNotEmpty) {
      return '$typeLabel • ${tx.referenceNumber}';
    }
    return typeLabel;
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = _isIncoming
        ? DashboardColors.incoming
        : DashboardColors.outgoing;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => navigateToDashboardTransaction(context, tx),
        borderRadius: AppRadius.smBorder,
        hoverColor: AppColors.background,
        splashColor: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeBadge(type: tx.type),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.partyName.isEmpty
                          ? dashboardTransactionTypeLabel(tx.type)
                          : tx.partyName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _detailLine,
                      style: DashboardTypography.metadata.copyWith(
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(tx.date),
                      style: DashboardTypography.metadata,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                currencyFormat.format(tx.amount),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final DashboardTransactionType type;

  @override
  Widget build(BuildContext context) {
    final isIncoming = dashboardTransactionIsIncoming(type);

    final color = isIncoming
        ? DashboardColors.incoming
        : DashboardColors.outgoing;

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        dashboardTransactionBadgeLabel(type),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
