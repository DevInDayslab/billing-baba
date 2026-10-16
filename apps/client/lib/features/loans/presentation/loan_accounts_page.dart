import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/loans/application/loan_providers.dart';
import 'package:billing_baba/features/loans/models/loan_models.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoanAccountsPage extends StatelessWidget {
  const LoanAccountsPage({this.embeddedInAccountsHub = false, super.key});

  final bool embeddedInAccountsHub;

  @override
  Widget build(BuildContext context) {
    if (embeddedInAccountsHub) {
      return ColoredBox(
        color: AppColors.background,
        child: const _LoanAccountsListBody(showMobileAppBar: false),
      );
    }
    return const AdaptivePage(
      desktop: _LoanAccountsListBody(showMobileAppBar: false),
      mobile: _LoanAccountsListBody(showMobileAppBar: true),
    );
  }
}

class _LoanAccountsListBody extends ConsumerWidget {
  const _LoanAccountsListBody({required this.showMobileAppBar});

  final bool showMobileAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(loanAccountsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showMobileAppBar ? AppBar(title: const Text('Loan accounts')) : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addLoanAccount),
        icon: const Icon(Icons.add),
        label: const Text('Add loan'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: accountsAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No loan accounts yet. Add one or sync from the server.',
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: accounts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) =>
                      _LoanAccountCard(account: accounts[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanAccountCard extends StatelessWidget {
  const _LoanAccountCard({required this.account});

  final LoanAccountDto account;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (account.lenderName != null && account.lenderName!.isNotEmpty)
        account.lenderName!,
      if (account.accountNumber != null && account.accountNumber!.isNotEmpty)
        account.accountNumber!,
      'As of ${account.openingBalanceAsOf}',
    ].join(' · ');

    return Card(
      child: ListTile(
        title: Text(account.name),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: Text(
          account.openingOutstanding,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: () => context.push(
          '${AppRoutes.loanAccountDetail}/${account.id}',
        ),
      ),
    );
  }
}
