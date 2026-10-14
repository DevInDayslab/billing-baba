import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/application/sale_document_form_provider.dart';
import 'package:billing_baba/features/settings/application/gst_tax_settings_provider.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_form_footer_shared.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/document_attachment_providers.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaleDocumentFooter extends ConsumerStatefulWidget {
  const SaleDocumentFooter({
    required this.documentType,
    super.key,
  });

  final SaleDocumentType documentType;

  @override
  ConsumerState<SaleDocumentFooter> createState() => _SaleDocumentFooterState();
}

class _SaleDocumentFooterState extends ConsumerState<SaleDocumentFooter> {
  var _showDescription = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = ref.read(saleDocumentFormProvider(widget.documentType));
      if (form.description.isNotEmpty && mounted) {
        setState(() => _showDescription = true);
      }
    });
  }

  static const _attachmentEntityType = DocumentAttachmentEntityType.estimate;

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(saleDocumentFormProvider(widget.documentType));
    final notifier = ref.read(
      saleDocumentFormProvider(widget.documentType).notifier,
    );
    final totalTax = ref.watch(
      saleDocumentTotalTaxProvider(widget.documentType),
    );
    final grandTotal = ref.watch(
      saleDocumentGrandTotalProvider(widget.documentType),
    );
    final attachmentService = ref
        .watch(documentAttachmentServiceProvider)
        .value;

    void onAddDescription() => setState(() => _showDescription = true);
    void onAddImage() => unawaited(_promptAddImage(context, notifier));
    void onAddDocument() => unawaited(_promptAddDocument(context, notifier));

    return SaleFormFooterThreeColumnLayout(
      termsSection: SaleFormFooterTermsSection(
        title: form.termsTitle,
        notes: form.termsText,
        onTitleChanged: notifier.updateTermsTitle,
        onNotesChanged: notifier.updateTermsText,
      ),
      attachmentActionsBox: SaleFormFooterAttachmentActionsBox(
        expandVertically: false,
        onAddDescription: onAddDescription,
        onAddImage: onAddImage,
        onAddDocument: onAddDocument,
      ),
      attachmentActionsBoxTall: SaleFormFooterAttachmentActionsBox(
        expandVertically: true,
        onAddDescription: onAddDescription,
        onAddImage: onAddImage,
        onAddDocument: onAddDocument,
      ),
      attachmentExtras: SaleFormFooterAttachmentExtras(
        showDescription: _showDescription,
        description: form.description,
        attachedImages: form.attachedImages,
        attachedDocuments: form.attachedDocuments,
        attachmentService: attachmentService,
        onDescriptionChanged: notifier.updateDescription,
        onRemoveImage: (id) => transactionRemoveAttachment(
          ref: ref,
          attachments: form.attachedImages,
          id: id,
          onRemoved: notifier.removeImage,
        ),
        onRenameImage: (id, name) => transactionRenameAttachment(
          ref: ref,
          attachments: form.attachedImages,
          id: id,
          name: name,
          onRenamed: notifier.updateImage,
        ),
        onRemoveDocument: (id) => transactionRemoveAttachment(
          ref: ref,
          attachments: form.attachedDocuments,
          id: id,
          onRemoved: notifier.removeDocument,
        ),
        onRenameDocument: (id, name) => transactionRenameAttachment(
          ref: ref,
          attachments: form.attachedDocuments,
          id: id,
          name: name,
          onRenamed: notifier.updateDocument,
        ),
      ),
      totalsSection: _TotalsSection(
        form: form,
        notifier: notifier,
        totalTax: totalTax,
        grandTotal: grandTotal,
        showTransactionTaxes: ref.watch(gstAllowsTransactionTaxesProvider),
      ),
    );
  }

  Future<void> _promptAddImage(
    BuildContext context,
    SaleDocumentFormNotifier notifier,
  ) async {
    await transactionAddImage(
      context: context,
      ref: ref,
      entityType: _attachmentEntityType.apiValue,
      entityId: ref.read(saleDocumentFormProvider(widget.documentType)).documentId,
      onAdded: notifier.addImage,
    );
  }

  Future<void> _promptAddDocument(
    BuildContext context,
    SaleDocumentFormNotifier notifier,
  ) async {
    await transactionAddDocument(
      context: context,
      ref: ref,
      entityType: _attachmentEntityType.apiValue,
      entityId: ref.read(saleDocumentFormProvider(widget.documentType)).documentId,
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
    required this.showTransactionTaxes,
  });

  final SaleDocumentFormState form;
  final SaleDocumentFormNotifier notifier;
  final double totalTax;
  final double grandTotal;
  final bool showTransactionTaxes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTransactionTaxes)
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
        if (showTransactionTaxes) const SizedBox(height: 8),
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
            border: Border.all(color: saleFormFooterCardBorder),
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
    final newText = widget.value == 0 ? '0' : widget.value.toStringAsFixed(2);
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
      style: saleFieldTextStyle.copyWith(
        fontSize: widget.readOnly ? 15 : 13,
        fontWeight: widget.readOnly ? FontWeight.bold : FontWeight.normal,
      ),
      decoration: buildSaleFieldDecoration(
        filled: widget.readOnly,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (text) => widget.onChanged(double.tryParse(text) ?? 0),
    );
  }
}
