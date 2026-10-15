import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/loans/application/loan_providers.dart';
import 'package:billing_baba/features/loans/models/loan_models.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/models/loan_accounts_report_subsection.dart';
import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class LoanAccountDetailPage extends ConsumerWidget {
  const LoanAccountDetailPage({super.key, required this.loanAccountId});

  final String loanAccountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(loanAccountByIdProvider(loanAccountId));
    final txnsAsync = ref.watch(loanTransactionsForAccountProvider(loanAccountId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: accountAsync.when(
          data: (a) => Text(a?.name ?? 'Loan account'),
          loading: () => const Text('Loan account'),
          error: (_, __) => const Text('Loan account'),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(
              '${AppRoutes.editLoanAccount}/$loanAccountId',
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _openTransaction(context, value),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'increase',
                child: Text('Loan increase'),
              ),
              PopupMenuItem(
                value: 'repayment',
                child: Text('Repayment'),
              ),
              PopupMenuItem(
                value: 'charges',
                child: Text('Charges'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTransaction(context, 'increase'),
        icon: const Icon(Icons.add),
        label: const Text('Transaction'),
      ),
      body: accountAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (account) {
          if (account == null) {
            return const Center(child: Text('Loan account not found'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (account.lenderName != null &&
                            account.lenderName!.isNotEmpty)
                          Text(
                            'Lender: ${account.lenderName}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        Text(
                          'Opening outstanding: ${account.openingOutstanding}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'As of ${account.openingBalanceAsOf}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton.icon(
                          onPressed: () {
                            ref
                                .read(reportFiltersProvider.notifier)
                                .setLoanAccount(loanAccountId);
                            context.push(
                              AppRoutes.reports,
                              extra: ReportsNavIntent.loanAccounts(
                                LoanAccountsReportSubSection.loanStatement,
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('View loan statement'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Expanded(
                child: txnsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (txns) {
                    if (txns.isEmpty) {
                      return const Center(
                        child: Text('No transactions yet'),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: txns.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) =>
                          _TransactionTile(txn: txns[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openTransaction(BuildContext context, String type) {
    context.push(
      '${AppRoutes.addLoanTransaction}?loanAccountId=$loanAccountId&type=$type',
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.txn});

  final LoanTransactionDto txn;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(txn.transactionDate);
    return Card(
      child: ListTile(
        title: Text(txn.typeLabel),
        subtitle: Text(
          [
            if (txn.description != null && txn.description!.isNotEmpty)
              txn.description!,
            if (txn.referenceNumber != null && txn.referenceNumber!.isNotEmpty)
              'Ref ${txn.referenceNumber}',
          ].join(' · '),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              txn.totalAmount.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (date != null)
              Text(
                DateFormat.yMMMd().format(date),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
