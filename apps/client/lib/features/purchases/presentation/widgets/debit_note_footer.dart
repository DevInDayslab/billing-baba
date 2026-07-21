import 'package:billing_baba/core/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/core/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/providers/debit_note_form_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _linkColor = Color(0xFF1565C0);

class DebitNoteFooter extends ConsumerWidget {
  const DebitNoteFooter({this.debitNoteId, super.key});

  final String? debitNoteId;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(debitNoteFormProvider(debitNoteId: debitNoteId));
    final notifier = ref.read(
      debitNoteFormProvider(debitNoteId: debitNoteId).notifier,
    );
    final grandTotal = ref.watch(
      debitNoteGrandTotalProvider(debitNoteId: debitNoteId),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Payment Type',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
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
                ],
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
                entityType: DocumentAttachmentEntityType.purchase.apiValue,
                entityId: form.documentId,
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
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: form.roundOff,
                    onChanged: (value) =>
                        notifier.toggleRoundOff(value: value ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Text('Round Off', style: TextStyle(fontSize: 13)),
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
              Row(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ],
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
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: _linkColor,
          fontWeight: FontWeight.w500,
        ),
      ),
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
      text: widget.value == 0 ? '0' : widget.value.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(_AmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = widget.value == 0 ? '0' : widget.value.toStringAsFixed(2);
    if (widget.value != oldWidget.value && text != _controller.text) {
      _controller.text = text;
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
      decoration: buildSaleFieldDecoration(compact: true),
      textAlign: TextAlign.right,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (value) => widget.onChanged(double.tryParse(value) ?? 0),
    );
  }
}
