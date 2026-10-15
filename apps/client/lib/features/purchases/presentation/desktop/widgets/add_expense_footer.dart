import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/add_expense_form_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/payment_account_field.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _linkColor = Color(0xFF1565C0);

class AddExpenseFooter extends ConsumerWidget {
  const AddExpenseFooter({this.expenseId, super.key});

  final String? expenseId;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addExpenseFormProvider(expenseId: expenseId));
    final notifier = ref.read(
      addExpenseFormProvider(expenseId: expenseId).notifier,
    );
    final totalTax = ref.watch(
      addExpenseTotalTaxProvider(expenseId: expenseId),
    );
    final grandTotal = ref.watch(
      addExpenseGrandTotalProvider(expenseId: expenseId),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: SaleGenericSelectDropdown(
                      value: form.paymentType,
                      options: SaleDropdownOptions.paymentTypes,
                      highlight: SaleDropdownHighlight.blue,
                      compact: true,
                      onSelected: notifier.updatePaymentType,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: _AmountField(
                      value: form.paymentAmount,
                      onChanged: notifier.updatePaymentAmount,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ReferenceField(
                      initialValue: form.payments.isNotEmpty
                          ? form.payments.first.referenceNo
                          : '',
                      onChanged: notifier.updatePaymentReference,
                    ),
                  ),
                ],
              ),
              PaymentAccountField(
                paymentMode: PurchasePaymentModes.toApi(form.paymentType),
                selectedAccountId: form.payments.isNotEmpty
                    ? form.payments.first.bankAccountId
                    : null,
                onChanged: notifier.updatePaymentBankAccountId,
              ),
              const SizedBox(height: 8),
              _ActionLink(
                label: '+ Add Payment type',
                onTap: notifier.addPaymentType,
              ),
              const SizedBox(height: 12),
              transactionAttachmentsSection(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.expense.apiValue,
                entityId: form.expenseId,
                description: form.description,
                images: form.attachedImages,
                documents: form.attachedDocuments,
                onDescriptionChanged: notifier.updateDescription,
                addImage: notifier.addImage,
                addDocument: notifier.addDocument,
                removeImage: notifier.removeImage,
                removeDocument: notifier.removeDocument,
                updateImage: notifier.updateImage,
                updateDocument: notifier.updateDocument,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (form.gstEnabled)
                Row(
                  children: [
                    const Text(
                      'Tax',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 72,
                      child: _AmountField(
                        value: totalTax,
                        readOnly: true,
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              if (form.gstEnabled) const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: form.roundOff,
                    onChanged: (value) =>
                        notifier.toggleRoundOff(value: value ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Text(
                    'Round Off',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 72,
                    child: _AmountField(
                      value: form.roundOffAmount,
                      readOnly: !form.roundOff,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: _cardBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _currencyFormat.format(grandTotal),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReferenceField extends StatefulWidget {
  const _ReferenceField({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_ReferenceField> createState() => _ReferenceFieldState();
}

class _ReferenceFieldState extends State<_ReferenceField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_ReferenceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: saleFieldTextStyle.copyWith(fontSize: 13),
      decoration: buildSaleFieldDecoration(hint: 'Reference No.'),
      onChanged: widget.onChanged,
    );
  }
}

class _AmountField extends StatefulWidget {
  const _AmountField({
    required this.value,
    required this.onChanged,
    this.readOnly = false,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final bool readOnly;

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 0 ? '0' : widget.value.toString(),
    );
  }

  @override
  void didUpdateWidget(_AmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.value == 0 ? '0' : widget.value.toString();
    if (widget.value != oldWidget.value && newText != _controller.text) {
      _controller.text = newText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: widget.readOnly,
      style: saleFieldTextStyle.copyWith(fontSize: 13),
      decoration: buildSaleFieldDecoration(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (text) => widget.onChanged(double.tryParse(text) ?? 0),
    );
  }
}

class _ActionLink extends StatelessWidget {
  const _ActionLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: _linkColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
