import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/bank_accounts/application/bank_account_providers.dart';
import 'package:billing_baba/features/bank_accounts/models/bank_account_models.dart';
import 'package:billing_baba/features/reports/models/business_status_report_subsection.dart';
import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:billing_baba/features/bank_accounts/presentation/bank_account_action_dialogs.dart';
import 'package:billing_baba/shared/utils/validate_ifsc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CashAndBankPage extends ConsumerWidget {
  const CashAndBankPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(bankAccountsStreamProvider);
    final balancesAsync = ref.watch(bankAccountBalancesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cash & Bank'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'transfer':
                  await showAccountTransferDialog(context, ref);
                case 'adjust':
                  await showAccountAdjustmentDialog(context, ref);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'transfer', child: Text('Transfer')),
              PopupMenuItem(value: 'adjust', child: Text('Adjust balance')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBankDialog(context, ref),
        label: const Text('Add bank'),
        icon: const Icon(Icons.add),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          final balanceMap = {
            for (final b in balancesAsync.asData?.value ??
                <BankAccountBalanceDto>[])
              b.accountId: b.balance,
          };
          if (accounts.isEmpty) {
            return const Center(child: Text('No accounts yet. Sync or add a bank.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: accounts.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final account = accounts[index];
              final balance = balanceMap[account.id] ?? account.openingBalance;
              return Card(
                child: ListTile(
                  title: Text(account.label),
                  subtitle: Text(
                    account.isCash
                        ? 'Cash in hand'
                        : [account.ifsc, account.accountNumber]
                            .where((e) => e != null && e.isNotEmpty)
                            .join(' · '),
                  ),
                  trailing: Text(
                    balance,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  onTap: account.isCash
                      ? null
                      : () {
                          context.push(
                            AppRoutes.reports,
                            extra: ReportsNavIntent.businessStatus(
                              BusinessStatusReportSubSection.bankStatement,
                              bankAccountId: account.id,
                            ),
                          );
                        },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showAddBankDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final ifscController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add bank account'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Display name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: ifscController,
                decoration: const InputDecoration(labelText: 'IFSC (optional)'),
                validator: (v) =>
                    validateIfsc(v) ? null : 'Invalid IFSC',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    final remote = await ref.read(bankAccountRemoteProvider.future);
    await remote.createBank({
      'display_name': nameController.text.trim(),
      if (ifscController.text.trim().isNotEmpty)
        'ifsc': normalizeIfsc(ifscController.text),
      'is_default': true,
    });
    ref.invalidate(bankAccountBalancesProvider);
  }
}
