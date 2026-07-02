import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_transaction_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:flutter/material.dart';

const _transactionTypes = ['Sale', 'Payment In', 'Purchase', 'Payment Out'];
const _statusLabels = {
  SaleInvoiceStatus.paid: 'Paid',
  SaleInvoiceStatus.unpaid: 'Unpaid',
  SaleInvoiceStatus.partiallyPaid: 'Partially Paid',
  SaleInvoiceStatus.overdue: 'Overdue',
  SaleInvoiceStatus.cancelled: 'Cancelled',
};

Future<PartyTransactionModel?> showEditPartyTransactionDialog(
  BuildContext context, {
  required PartyTransactionModel transaction,
}) {
  return showDialog<PartyTransactionModel>(
    context: context,
    builder: (context) => EditPartyTransactionDialog(transaction: transaction),
  );
}

class EditPartyTransactionDialog extends StatefulWidget {
  const EditPartyTransactionDialog({required this.transaction, super.key});

  final PartyTransactionModel transaction;

  @override
  State<EditPartyTransactionDialog> createState() =>
      _EditPartyTransactionDialogState();
}

class _EditPartyTransactionDialogState extends State<EditPartyTransactionDialog> {
  final _invoiceController = TextEditingController();
  final _amountController = TextEditingController();
  final _balanceController = TextEditingController();
  final _datePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  late DateTime _selectedDate;
  late String _transactionType;
  late String _paymentType;
  late String _statusLabel;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _invoiceController.text = transaction.invoiceNo;
    _amountController.text = transaction.amount.toStringAsFixed(0);
    _balanceController.text = transaction.balance.toStringAsFixed(0);
    _selectedDate = transaction.date;
    _transactionType = transaction.transactionType;
    _paymentType = transaction.paymentType;
    _statusLabel = _statusLabels[transaction.status] ?? 'Paid';
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _amountController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  SaleInvoiceStatus get _selectedStatus {
    return _statusLabels.entries
        .firstWhere((entry) => entry.value == _statusLabel)
        .key;
  }

  void _save() {
    final invoiceNo = _invoiceController.text.trim();
    if (invoiceNo.isEmpty) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0;

    Navigator.of(context).pop(
      widget.transaction.copyWith(
        invoiceNo: invoiceNo,
        date: _selectedDate,
        transactionType: _transactionType,
        paymentType: _paymentType,
        status: _selectedStatus,
        amount: amount,
        balance: balance,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Transaction'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LabeledField(
              label: 'Invoice No',
              child: TextField(
                controller: _invoiceController,
                style: saleFieldTextStyle,
                decoration: buildSaleFieldDecoration(hint: 'Invoice number'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _LabeledField(
              label: 'Date',
              child: SaleSingleDatePickerAnchor(
                key: _datePickerKey,
                selectedDate: _selectedDate,
                onDateSelected: (date) => setState(() => _selectedDate = date),
                child: SaleFieldTrigger(
                  onTap: () => _datePickerKey.currentState?.toggle(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatSaleSingleDate(_selectedDate),
                          style: saleFieldTextStyle,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Type',
                    child: SaleGenericSelectDropdown(
                      value: _transactionType,
                      options: _transactionTypes,
                      onSelected: (value) =>
                          setState(() => _transactionType = value),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LabeledField(
                    label: 'Payment',
                    child: SaleGenericSelectDropdown(
                      value: _paymentType,
                      options: SaleDropdownOptions.paymentTypes,
                      onSelected: (value) =>
                          setState(() => _paymentType = value),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Amount',
                    child: TextField(
                      controller: _amountController,
                      style: saleFieldTextStyle,
                      decoration: buildSaleFieldDecoration(hint: '0'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LabeledField(
                    label: 'Balance',
                    child: TextField(
                      controller: _balanceController,
                      style: saleFieldTextStyle,
                      decoration: buildSaleFieldDecoration(hint: '0'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _LabeledField(
              label: 'Status',
              child: SaleGenericSelectDropdown(
                value: _statusLabel,
                options: _statusLabels.values.toList(),
                onSelected: (value) => setState(() => _statusLabel = value),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: saleFieldLabelStyle),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
