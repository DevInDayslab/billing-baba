import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/bank_accounts/application/bank_account_providers.dart';
import 'package:billing_baba/features/loans/application/loan_providers.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/shared/widgets/bank_account_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddLoanAccountPage extends StatelessWidget {
  const AddLoanAccountPage({super.key, this.loanAccountId});

  final String? loanAccountId;

  bool get isEdit => loanAccountId != null && loanAccountId!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: _AddLoanAccountForm(loanAccountId: loanAccountId),
      mobile: _AddLoanAccountForm(loanAccountId: loanAccountId),
    );
  }
}

class _AddLoanAccountForm extends ConsumerStatefulWidget {
  const _AddLoanAccountForm({this.loanAccountId});

  final String? loanAccountId;

  @override
  ConsumerState<_AddLoanAccountForm> createState() =>
      _AddLoanAccountFormState();
}

class _AddLoanAccountFormState extends ConsumerState<_AddLoanAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lenderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _openingController = TextEditingController(text: '0');
  final _interestController = TextEditingController();
  final _termController = TextEditingController();

  DateTime _openingAsOf = DateTime.now();
  String? _receivedBankAccountId;
  bool _loading = false;
  bool _loadedExisting = false;

  bool get isEdit =>
      widget.loanAccountId != null && widget.loanAccountId!.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _lenderController.dispose();
    _accountNumberController.dispose();
    _descriptionController.dispose();
    _openingController.dispose();
    _interestController.dispose();
    _termController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final defaultBank = ref.read(defaultBankAccountProvider);
        if (defaultBank != null) {
          setState(() => _receivedBankAccountId = defaultBank.id);
        }
      });
    }
  }

  Future<void> _loadExisting() async {
    final account = await ref.read(
      loanAccountByIdProvider(widget.loanAccountId!).future,
    );
    if (account == null || !mounted) return;
    _nameController.text = account.name;
    _lenderController.text = account.lenderName ?? '';
    _accountNumberController.text = account.accountNumber ?? '';
    _descriptionController.text = account.description ?? '';
    _openingController.text = account.openingOutstanding;
    _interestController.text = account.interestRate ?? '';
    if (account.termMonths != null) {
      _termController.text = account.termMonths.toString();
    }
    _openingAsOf = DateTime.tryParse(account.openingBalanceAsOf) ?? DateTime.now();
    _receivedBankAccountId = account.receivedBankAccountId;
    setState(() => _loadedExisting = true);
  }

  String _dateKey(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date.toLocal());

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final commands = await ref.read(loanCommandRepositoryProvider.future);
      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'opening_balance_as_of': _dateKey(_openingAsOf),
        if (_lenderController.text.trim().isNotEmpty)
          'lender_name': _lenderController.text.trim(),
        if (_accountNumberController.text.trim().isNotEmpty)
          'account_number': _accountNumberController.text.trim(),
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        if (_openingController.text.trim().isNotEmpty)
          'opening_outstanding': _openingController.text.trim(),
        if (_interestController.text.trim().isNotEmpty)
          'interest_rate': _interestController.text.trim(),
        if (_termController.text.trim().isNotEmpty)
          'term_months': int.parse(_termController.text.trim()),
        if (_receivedBankAccountId != null)
          'received_bank_account_id': _receivedBankAccountId,
      };

      if (isEdit) {
        await commands.updateAccount(widget.loanAccountId!, body);
      } else {
        await commands.createAccount(body);
      }
      ref.invalidate(loanAccountsStreamProvider);
      ref.invalidate(loanAccountsHydrationProvider);
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
    if (isEdit && !_loadedExisting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit loan account' : 'Add loan account'),
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Loan name *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _lenderController,
              decoration: const InputDecoration(labelText: 'Lender name'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(labelText: 'Account number'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _openingController,
              decoration: const InputDecoration(
                labelText: 'Opening outstanding',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Opening balance as of *'),
              subtitle: Text(DateFormat.yMMMd().format(_openingAsOf)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _openingAsOf,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _openingAsOf = picked);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _interestController,
              decoration: const InputDecoration(labelText: 'Interest rate %'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _termController,
              decoration: const InputDecoration(labelText: 'Term (months)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Funds received in',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            BankAccountPicker(
              hint: 'Bank account (optional)',
              selectedAccountId: _receivedBankAccountId,
              onChanged: (id) => setState(() => _receivedBankAccountId = id),
            ),
          ],
        ),
      ),
    );
  }
}
