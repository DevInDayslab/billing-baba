import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/features/sales/providers/delivery_challan_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DeliveryChallanFooter extends ConsumerWidget {
  const DeliveryChallanFooter({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(deliveryChallanFormProvider);
    final notifier = ref.read(deliveryChallanFormProvider.notifier);
    final grandTotal = ref.watch(deliveryChallanGrandTotalProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SaleFormAttachmentsSection(
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
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _promptAddImage(
    BuildContext context,
    DeliveryChallanFormNotifier notifier,
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
    DeliveryChallanFormNotifier notifier,
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
      text: widget.value == 0 ? '0.00' : widget.value.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(_AmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.value == 0
        ? '0.00'
        : widget.value.toStringAsFixed(2);
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
      textAlign: TextAlign.right,
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
