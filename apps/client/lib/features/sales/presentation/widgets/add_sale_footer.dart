import 'package:billing_baba/core/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/core/attachments/document_attachment_providers.dart';
import 'package:billing_baba/core/attachments/transaction_attachment_actions.dart';
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

const _cardBorder = Color(0xFFE0E0E0);
const _compactBreakpoint = 900.0;

class AddSaleFooter extends ConsumerStatefulWidget {
  const AddSaleFooter({this.sessionKey = 'default', super.key});

  final String sessionKey;

  @override
  ConsumerState<AddSaleFooter> createState() => _AddSaleFooterState();
}

class _AddSaleFooterState extends ConsumerState<AddSaleFooter> {
  var _showDescription = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = ref.read(
        addSaleFormProvider(sessionKey: widget.sessionKey),
      );
      if (form.description.isNotEmpty && mounted) {
        setState(() => _showDescription = true);
      }
    });
  }

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(
      addSaleFormProvider(sessionKey: widget.sessionKey),
    );
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: widget.sessionKey).notifier,
    );
    final totalTax = ref.watch(
      addSaleTotalTaxProvider(sessionKey: widget.sessionKey),
    );
    final grandTotal = ref.watch(
      addSaleGrandTotalProvider(sessionKey: widget.sessionKey),
    );
    final isCredit = form.saleType == SaleType.credit;
    final attachmentService = ref.watch(documentAttachmentServiceProvider).value;

    final termsSection = _TermsSection(
      title: form.termsTitle,
      notes: form.termsText,
      onTitleChanged: notifier.updateTermsTitle,
      onNotesChanged: notifier.updateTermsText,
    );
    final attachmentsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          SaleFormAttachmentChipList(
            attachments: form.attachedImages,
            attachmentService: attachmentService,
            onRemove: (id) => transactionRemoveAttachment(
              ref: ref,
              attachments: form.attachedImages,
              id: id,
              onRemoved: notifier.removeImage,
            ),
            onRename: (id, name) => transactionRenameAttachment(
              ref: ref,
              attachments: form.attachedImages,
              id: id,
              name: name,
              onRenamed: notifier.updateImage,
            ),
          ),
        ],
        if (form.attachedDocuments.isNotEmpty) ...[
          const SizedBox(height: 8),
          SaleFormAttachmentChipList(
            attachments: form.attachedDocuments,
            attachmentService: attachmentService,
            onRemove: (id) => transactionRemoveAttachment(
              ref: ref,
              attachments: form.attachedDocuments,
              id: id,
              onRemoved: notifier.removeDocument,
            ),
            onRename: (id, name) => transactionRenameAttachment(
              ref: ref,
              attachments: form.attachedDocuments,
              id: id,
              name: name,
              onRenamed: notifier.updateDocument,
            ),
          ),
        ],
      ],
    );
    final totalsSection = _TotalsSection(
      form: form,
      notifier: notifier,
      totalTax: totalTax,
      grandTotal: grandTotal,
      isCredit: isCredit,
      currencyFormat: _currencyFormat,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < _compactBreakpoint;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              termsSection,
              const SizedBox(height: 16),
              attachmentsSection,
              const SizedBox(height: 16),
              totalsSection,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: termsSection),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: attachmentsSection),
            const SizedBox(width: 16),
            SizedBox(width: 260, child: totalsSection),
          ],
        );
      },
    );
  }

  Future<void> _promptAddImage(
    BuildContext context,
    AddSaleForm notifier,
    int currentCount,
  ) async {
    await transactionAddImage(
      context: context,
      ref: ref,
      entityType: DocumentAttachmentEntityType.sale.apiValue,
      entityId: ref
          .read(addSaleFormProvider(sessionKey: widget.sessionKey))
          .documentId,
      onAdded: notifier.addImage,
    );
  }

  Future<void> _promptAddDocument(
    BuildContext context,
    AddSaleForm notifier,
    int currentCount,
  ) async {
    await transactionAddDocument(
      context: context,
      ref: ref,
      entityType: DocumentAttachmentEntityType.sale.apiValue,
      entityId: ref
          .read(addSaleFormProvider(sessionKey: widget.sessionKey))
          .documentId,
      onAdded: notifier.addDocument,
    );
  }
}

class _TotalsSection extends StatelessWidget {
  const _TotalsSection({
    required this.form,
    required this.notifier,
    required this.totalTax,
    required this.grandTotal,
    required this.isCredit,
    required this.currencyFormat,
  });

  final AddSaleFormState form;
  final AddSaleForm notifier;
  final double totalTax;
  final double grandTotal;
  final bool isCredit;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                value: form.taxOption,
                options: SaleDropdownOptions.taxSlabs,
                highlight: SaleDropdownHighlight.red,
                compact: true,
                onSelected: notifier.updateTaxOption,
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
        if (form.showLoyaltySection) ...[
          const SizedBox(height: 8),
          _LoyaltyPointsSection(
            form: form,
            notifier: notifier,
            currencyFormat: currencyFormat,
          ),
        ],
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
        if (isCredit) ...[
          const SizedBox(height: 8),
          _CreditSummarySection(
            form: form,
            notifier: notifier,
            currencyFormat: currencyFormat,
          ),
        ] else ...[
          const SizedBox(height: 8),
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
              Expanded(
                child: _AmountField(
                  value: form.paymentAmount,
                  onChanged: notifier.updatePaymentAmount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: notifier.addPaymentType,
            borderRadius: BorderRadius.circular(4),
            child: const Text(
              '+ Add Payment type',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
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
      decoration: buildSaleFieldDecoration(
        hint: 'Write your description here',
      ),
      minLines: 3,
      maxLines: 4,
      onChanged: widget.onChanged,
    );
  }
}

class _LoyaltyPointsSection extends StatelessWidget {
  const _LoyaltyPointsSection({
    required this.form,
    required this.notifier,
    required this.currencyFormat,
  });

  final AddSaleFormState form;
  final AddSaleForm notifier;
  final NumberFormat currencyFormat;

  static const _sectionBackground = Color(0xFFFFF8E7);
  static const _sectionBorder = Color(0xFFFFE082);

  @override
  Widget build(BuildContext context) {
    final available = form.loyaltyPointsAvailable;
    final discount = form.loyaltyDiscount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _sectionBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _sectionBorder.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Loyalty Points',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Available',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                available == available.roundToDouble()
                    ? '${available.toInt()}'
                    : available.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Redeem',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 56,
                child: _PointsInputField(
                  value: form.loyaltyPointsUsed
                      .clamp(0, form.maxRedeemablePoints)
                      .toDouble(),
                  onChanged: notifier.updateLoyaltyPointsUsed,
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: form.maxRedeemablePoints > 0
                    ? notifier.useMaxLoyaltyPoints
                    : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text(
                  'Use Max',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Loyalty Discount',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                currencyFormat.format(discount),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointsInputField extends StatefulWidget {
  const _PointsInputField({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_PointsInputField> createState() => _PointsInputFieldState();
}

class _PointsInputFieldState extends State<_PointsInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(_PointsInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = _formatValue(widget.value);
    if (widget.value != oldWidget.value && newText != _controller.text) {
      _controller.text = newText;
    }
  }

  String _formatValue(double value) =>
      value == 0 ? '0' : value.round().toString();

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
      decoration: buildSaleFieldDecoration(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (text) {
        final parsed = double.tryParse(text) ?? 0;
        widget.onChanged(parsed);
      },
    );
  }
}

class _CreditSummarySection extends StatelessWidget {
  const _CreditSummarySection({
    required this.form,
    required this.notifier,
    required this.currencyFormat,
  });

  final AddSaleFormState form;
  final AddSaleForm notifier;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              'Remaining Amount',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              currencyFormat.format(form.remainingAmount),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: form.receivedEnabled,
              onChanged: (value) =>
                  notifier.toggleReceived(enabled: value ?? false),
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
                currencyFormat.format(0),
                style: const TextStyle(fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Balance',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              currencyFormat.format(form.balanceAmount),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
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
