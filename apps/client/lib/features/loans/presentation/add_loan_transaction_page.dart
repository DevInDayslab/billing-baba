import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/bank_accounts/application/bank_account_providers.dart';
import 'package:billing_baba/features/loans/application/loan_providers.dart';
import 'package:billing_baba/features/loans/models/loan_models.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/shared/widgets/bank_account_picker.dart';
import 'package:billing_baba/shared/widgets/loan_account_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddLoanTransactionPage extends StatelessWidget {
  const AddLoanTransactionPage({
    super.key,
    this.loanAccountId,
    this.transactionType,
    this.transactionId,
  });

  final String? loanAccountId;
  final String? transactionType;
  final String? transactionId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: _AddLoanTransactionForm(
        loanAccountId: loanAccountId,
        initialType: transactionType,
        transactionId: transactionId,
      ),
      mobile: _AddLoanTransactionForm(
        loanAccountId: loanAccountId,
        initialType: transactionType,
        transactionId: transactionId,
      ),
    );
  }
}

class _AddLoanTransactionForm extends ConsumerStatefulWidget {
  const _AddLoanTransactionForm({
    this.loanAccountId,
    this.initialType,
    this.transactionId,
  });

  final String? loanAccountId;
  final String? initialType;
  final String? transactionId;

  @override
  ConsumerState<_AddLoanTransactionForm> createState() =>
      _AddLoanTransactionFormState();
}

class _AddLoanTransactionFormState
    extends ConsumerState<_AddLoanTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _interestController = TextEditingController();
  final _chargesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();

  LoanTransactionType _type = LoanTransactionType.increase;
  String? _loanAccountId;
  String? _bankAccountId;
  DateTime _txnDate = DateTime.now();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loanAccountId = widget.loanAccountId;
    final parsed = LoanTransactionType.fromApi(widget.initialType);
    if (parsed != null) _type = parsed;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final defaultBank = ref.read(defaultBankAccountProvider);
      if (defaultBank != null) {
        setState(() => _bankAccountId = defaultBank.id);
      }
    });
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestController.dispose();
    _chargesController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  String _dateKey(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date.toLocal());

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_loanAccountId == null || _loanAccountId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a loan account')),
      );
      return;
    }
    if (_bankAccountId == null || _bankAccountId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a bank account')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final commands = await ref.read(loanCommandRepositoryProvider.future);
      final body = <String, dynamic>{
        'loan_account_id': _loanAccountId,
        'transaction_type': _type.apiValue,
        'transaction_date': _dateKey(_txnDate),
        'bank_account_id': _bankAccountId,
        'principal_amount': _principalController.text.trim().isEmpty
            ? '0'
            : _principalController.text.trim(),
        'interest_amount': _interestController.text.trim().isEmpty
            ? '0'
            : _interestController.text.trim(),
        'charges_amount': _chargesController.text.trim().isEmpty
            ? '0'
            : _chargesController.text.trim(),
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        if (_referenceController.text.trim().isNotEmpty)
          'reference_number': _referenceController.text.trim(),
      };

      await commands.createTransaction(body);
      ref.invalidate(loanTransactionsForAccountProvider(_loanAccountId!));
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockAccount = widget.loanAccountId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_type.label),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (!lockAccount) ...[
              const Text(
                'Loan account *',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              LoanAccountPicker(
                selectedAccountId: _loanAccountId,
                onChanged: (id) => setState(() => _loanAccountId = id),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            DropdownButtonFormField<LoanTransactionType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Transaction type'),
              items: LoanTransactionType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.label),
                    ),
                  )
                  .toList(),
              onChanged: lockAccount && widget.initialType != null
                  ? null
                  : (value) {
                      if (value != null) setState(() => _type = value);
                    },
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date *'),
              subtitle: Text(DateFormat.yMMMd().format(_txnDate)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _txnDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _txnDate = picked);
              },
            ),
            if (_type != LoanTransactionType.charges) ...[
              TextFormField(
                controller: _principalController,
                decoration: InputDecoration(
                  labelText: _type == LoanTransactionType.increase
                      ? 'Principal amount *'
                      : 'Principal amount',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (_type == LoanTransactionType.increase) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (_type == LoanTransactionType.repayment) ...[
              TextFormField(
                controller: _interestController,
                decoration: const InputDecoration(labelText: 'Interest amount'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (_type == LoanTransactionType.charges) ...[
              TextFormField(
                controller: _chargesController,
                decoration: const InputDecoration(labelText: 'Charges amount *'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const Text(
              'Bank account *',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            BankAccountPicker(
              selectedAccountId: _bankAccountId,
              onChanged: (id) => setState(() => _bankAccountId = id),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(labelText: 'Reference number'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
