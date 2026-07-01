import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/providers/add_sale_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _linkColor = Color(0xFF1565C0);
const _mutedLinkColor = Color(0xFF616161);

class AddSaleFooter extends ConsumerWidget {
  const AddSaleFooter({this.invoiceId, super.key});

  final String? invoiceId;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addSaleFormProvider(invoiceId: invoiceId));
    final notifier = ref.read(
      addSaleFormProvider(invoiceId: invoiceId).notifier,
    );
    final totalTax = ref.watch(addSaleTotalTaxProvider(invoiceId: invoiceId));
    final grandTotal = ref.watch(
      addSaleGrandTotalProvider(invoiceId: invoiceId),
    );
    final isCredit = form.saleType == SaleType.credit;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
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
                ],
              ),
              const SizedBox(height: 8),
              _ActionLink(
                label: '+ Add Payment type',
                onTap: notifier.addPaymentType,
                isPrimary: true,
              ),
              const SizedBox(height: 12),
              SaleFormAttachmentsSection(
                description: form.description,
                images: form.attachedImages,
                documents: form.attachedDocuments,
                onDescriptionChanged: notifier.updateDescription,
                onAddImage: () => _promptAddImage(
                  context,
                  notifier,
                  form.attachedImages.length,
                ),
                onRemoveImage: notifier.removeImage,
                onUpdateImage: notifier.updateImage,
                onAddDocument: () => _promptAddDocument(
                  context,
                  notifier,
                  form.attachedDocuments.length,
                ),
                onRemoveDocument: notifier.removeDocument,
                onUpdateDocument: notifier.updateDocument,
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
              _SummaryRow(
                label: 'Tax',
                value: _currencyFormat.format(totalTax),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: form.roundOff,
                    onChanged: (value) =>
                        notifier.toggleRoundOff(value ?? false),
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
              if (isCredit) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Loyalty Point Used',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: _AmountField(
                        value: form.loyaltyPointsUsed,
                        onChanged: (value) {
                          if (!form.loyaltyPointsEnabled) {
                            notifier.toggleLoyaltyPoints(true);
                          }
                          notifier.updateLoyaltyPointsUsed(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '= ${_currencyFormat.format(form.loyaltyPointsValue)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Remaining Amount',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _currencyFormat.format(form.remainingAmount),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: form.receivedEnabled,
                      onChanged: (value) =>
                          notifier.toggleReceived(value ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const Text('Received', style: TextStyle(fontSize: 13)),
                    const Spacer(),
                    if (form.receivedEnabled)
                      SizedBox(
                        width: 100,
                        child: _AmountField(
                          value: form.receivedAmount,
                          onChanged: notifier.updateReceivedAmount,
                        ),
                      )
                    else
                      Text(
                        _currencyFormat.format(0),
                        style: const TextStyle(fontSize: 13),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _currencyFormat.format(form.balanceAmount),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Point Awarded',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${form.pointsAwarded}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Received',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _currencyFormat.format(form.displayReceivedAmount),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _currencyFormat.format(form.balanceAmount),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _promptAddImage(
    BuildContext context,
    AddSaleForm notifier,
    int currentCount,
  ) async {
    final attachment = await promptSaleFormAttachment(
      context,
      title: 'Add image',
      defaultName: 'image_${currentCount + 1}.png',
    );
    if (attachment != null) notifier.addImage(attachment);
  }

  Future<void> _promptAddDocument(
    BuildContext context,
    AddSaleForm notifier,
    int currentCount,
  ) async {
    final attachment = await promptSaleFormAttachment(
      context,
      title: 'Add document',
      defaultName: 'document_${currentCount + 1}.pdf',
    );
    if (attachment != null) notifier.addDocument(attachment);
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13)),
      ],
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
  const _ActionLink({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? _linkColor : _mutedLinkColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: isPrimary ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}
