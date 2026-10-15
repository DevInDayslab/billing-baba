import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/bank_accounts/application/bank_account_providers.dart';
import 'package:billing_baba/features/bank_accounts/models/bank_account_models.dart';
import 'package:billing_baba/shared/widgets/bank_account_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Future<void> showAccountTransferDialog(BuildContext context, WidgetRef ref) async {
  final accounts = await ref.read(bankAccountsStreamProvider.future);
  if (accounts.length < 2) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Need at least two accounts to transfer')),
    );
    return;
  }
  String? fromId = accounts.firstWhere((a) => !a.isCash, orElse: () => accounts.first).id;
  String? toId = accounts.firstWhere((a) => a.isCash).id;
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  var transferDate = DateTime.now();
  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
      title: const Text('Transfer between accounts'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BankAccountPicker(
              hint: 'From account',
              selectedAccountId: fromId,
              onChanged: (id) => setState(() => fromId = id),
            ),
            const SizedBox(height: AppSpacing.sm),
            BankAccountPicker(
              hint: 'To account',
              selectedAccountId: toId,
              onChanged: (id) => setState(() => toId = id),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat.yMMMd().format(transferDate)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: transferDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => transferDate = picked);
              },
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Transfer')),
      ],
    ),
    ),
  );
  if (saved != true || fromId == null || toId == null) return;
  final amount = amountController.text.trim();
  if (amount.isEmpty) return;
  final remote = await ref.read(bankAccountRemoteProvider.future);
  await remote.createTransfer({
    'from_account_id': fromId,
    'to_account_id': toId,
    'amount': amount,
    'transfer_date': _dateKey(transferDate),
    if (notesController.text.trim().isNotEmpty) 'notes': notesController.text.trim(),
  });
  ref.invalidate(bankAccountBalancesProvider);
}

Future<void> showAccountAdjustmentDialog(
  BuildContext context,
  WidgetRef ref, {
  BankAccountDto? account,
}) async {
  String? accountId = account?.id;
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  var kind = 'increase';
  var adjustmentDate = DateTime.now();
  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Adjust balance'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BankAccountPicker(
                hint: 'Account',
                selectedAccountId: accountId,
                onChanged: (id) => setState(() => accountId = id),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                value: kind,
                decoration: const InputDecoration(labelText: 'Kind'),
                items: const [
                  DropdownMenuItem(value: 'increase', child: Text('Increase')),
                  DropdownMenuItem(value: 'decrease', child: Text('Decrease')),
                ],
                onChanged: (v) => setState(() => kind = v ?? 'increase'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(adjustmentDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: adjustmentDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => adjustmentDate = picked);
                },
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    ),
  );
  if (saved != true || accountId == null) return;
  final amount = amountController.text.trim();
  if (amount.isEmpty) return;
  final remote = await ref.read(bankAccountRemoteProvider.future);
  await remote.createAdjustment({
    'bank_account_id': accountId,
    'kind': kind,
    'amount': amount,
    'adjustment_date': _dateKey(adjustmentDate),
    if (notesController.text.trim().isNotEmpty) 'notes': notesController.text.trim(),
  });
  ref.invalidate(bankAccountBalancesProvider);
}

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
