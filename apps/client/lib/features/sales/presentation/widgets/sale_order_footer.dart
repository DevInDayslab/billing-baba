import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/providers/sale_order_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _linkColor = Color(0xFF1565C0);

class SaleOrderFooter extends ConsumerStatefulWidget {
  const SaleOrderFooter({this.sessionKey = 'default', super.key});

  final String sessionKey;

  @override
  ConsumerState<SaleOrderFooter> createState() => _SaleOrderFooterState();
}

class _SaleOrderFooterState extends ConsumerState<SaleOrderFooter> {
  var _showDescription = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = ref.read(
        saleOrderFormProvider(sessionKey: widget.sessionKey),
      );
      if (form.description.isNotEmpty && mounted) {
        setState(() => _showDescription = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(
      saleOrderFormProvider(sessionKey: widget.sessionKey),
    );
    final notifier = ref.read(
      saleOrderFormProvider(sessionKey: widget.sessionKey).notifier,
    );
    final totalTax = form.taxAmount;
    final grandTotal = form.total;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _TermsSection(
            title: form.termsTitle,
            notes: form.termsText,
            onTitleChanged: notifier.updateTermsTitle,
            onNotesChanged: notifier.updateTermsText,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('Payment Type', style: TextStyle(fontSize: 13)),
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
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(4),
                child: const Text(
                  '+ Add Payment type',
                  style: TextStyle(fontSize: 13, color: _linkColor),
                ),
              ),
              const SizedBox(height: 12),
              _AttachmentActionButton(
                icon: Icons.description_outlined,
                label: 'ADD DESCRIPTION',
                onPressed: () => setState(() => _showDescription = true),
              ),
              if (_showDescription) ...[
                const SizedBox(height: 8),
                _DescriptionField(
                  initialValue: form.description,
                  onChanged: notifier.updateDescription,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _AttachmentActionButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'ADD IMAGE',
                      onPressed: () => _promptAddImage(
                        context,
                        notifier,
                        form.attachedImages.length,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AttachmentActionButton(
                      icon: Icons.attach_file_outlined,
                      label: 'ADD DOCUMENT',
                      filled: true,
                      onPressed: () => _promptAddDocument(
                        context,
                        notifier,
                        form.attachedDocuments.length,
                      ),
                    ),
                  ),
                ],
              ),
              if (form.attachedImages.isNotEmpty) ...[
                const SizedBox(height: 8),
                _AttachmentChips(
                  attachments: form.attachedImages,
                  onRemove: notifier.removeImage,
                  onRename: notifier.updateImage,
                ),
              ],
              if (form.attachedDocuments.isNotEmpty) ...[
                const SizedBox(height: 8),
                _AttachmentChips(
                  attachments: form.attachedDocuments,
                  onRemove: notifier.removeDocument,
                  onRename: notifier.updateDocument,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Tax',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: SaleGenericSelectDropdown(
                      value: totalTax > 0
                          ? taxLabelForPercent(
                              form.items.isNotEmpty
                                  ? form.items.first.taxPercent
                                  : 0,
                            )
                          : 'NONE',
                      options: SaleDropdownOptions.taxSlabs,
                      highlight: SaleDropdownHighlight.red,
                      compact: true,
                      onSelected: (_) {},
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
              const SizedBox(height: 8),
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
                    SizedBox(
                      width: 100,
                      child: _AmountField(
                        value: grandTotal,
                        readOnly: true,
                        onChanged: (_) {},
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

  Future<void> _promptAddImage(
    BuildContext context,
    SaleOrderFormNotifier notifier,
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
    SaleOrderFormNotifier notifier,
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

class _TermsSection extends StatelessWidget {
  const _TermsSection({
    required this.title,
    required this.notes,
    required this.onTitleChanged,
    required this.onNotesChanged,
  });

  final String title;
  final String notes;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onNotesChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms & Conditions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SaleGenericSelectDropdown(
              value: title,
              options: SaleDropdownOptions.termsTitles,
              hintText: 'Title',
              onSelected: onTitleChanged,
            ),
            const SizedBox(height: 8),
            _NotesField(
              initialValue: notes,
              onChanged: onNotesChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesField extends StatefulWidget {
  const _NotesField({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<_NotesField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_NotesField oldWidget) {
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
      decoration: buildSaleFieldDecoration(
        hint: 'Thanks for doing business with us!',
      ),
      minLines: 3,
      maxLines: 4,
      onChanged: widget.onChanged,
    );
  }
}

class _AttachmentActionButton extends StatelessWidget {
  const _AttachmentActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: filled ? const Color(0xFFF5F8FA) : null,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          side: const BorderSide(color: _cardBorder),
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

class _DescriptionField extends StatefulWidget {
  const _DescriptionField({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_DescriptionField oldWidget) {
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
      decoration: buildSaleFieldDecoration(hint: 'Add description'),
      minLines: 2,
      maxLines: 3,
      onChanged: widget.onChanged,
    );
  }
}

class _AttachmentChips extends StatelessWidget {
  const _AttachmentChips({
    required this.attachments,
    required this.onRemove,
    required this.onRename,
  });

  final List<SaleFormAttachment> attachments;
  final ValueChanged<String> onRemove;
  final void Function(String id, String name) onRename;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final attachment in attachments)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        attachment.displayName,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => onRemove(attachment.id),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
      text: widget.value == 0 ? '0' : widget.value.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(_AmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText =
        widget.value == 0 ? '0' : widget.value.toStringAsFixed(2);
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
      textAlign: TextAlign.right,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (text) => widget.onChanged(double.tryParse(text) ?? 0),
    );
  }
}
