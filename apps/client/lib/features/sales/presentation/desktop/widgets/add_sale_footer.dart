import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/application/add_sale_form_provider.dart';
import 'package:billing_baba/features/sales/application/sale_transaction_features.dart';
import 'package:billing_baba/features/sales/application/sale_transaction_totals_settings.dart';
import 'package:billing_baba/features/sales/utils/sale_invoice_totals.dart';
import 'package:billing_baba/features/settings/application/gst_tax_settings_provider.dart';
import 'package:billing_baba/features/settings/application/party_settings_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/document_attachment_providers.dart';
import 'package:billing_baba/shared/attachments/document_attachment_service.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:billing_baba/shared/business/business_amount_format.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _compactBreakpoint = 900.0;
const _attachmentActionsWidthFactor = 0.5;
// Shared outer height for terms card + attachment panel (scroll-safe; no IntrinsicHeight).
const _termsSectionPadding = 12.0;
const _termsNotesMinLines = 3;
const _termsAndAttachmentPanelHeight =
    _termsSectionPadding * 2 +
    18.0 +
    8.0 +
    saleFieldHeight +
    8.0 +
    20.0 +
    13.0 * 1.2 * _termsNotesMinLines;

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

  @override
  Widget build(BuildContext context) {
    final currencyFormat = ref.watch(businessAmountFormatterProvider);
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
    final attachmentService = ref
        .watch(documentAttachmentServiceProvider)
        .value;

    final termsSection = _TermsSection(
      title: form.termsTitle,
      notes: form.termsText,
      onTitleChanged: notifier.updateTermsTitle,
      onNotesChanged: notifier.updateTermsText,
    );
    final attachmentExtras = _AttachmentExtras(
      showDescription: _showDescription,
      form: form,
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
    );
    final attachmentActionsBox = _AttachmentActionsBox(
      expandVertically: false,
      onAddDescription: () => setState(() => _showDescription = true),
      onAddImage: () => _promptAddImage(
        context,
        notifier,
        form.attachedImages.length,
      ),
      onAddDocument: () => _promptAddDocument(
        context,
        notifier,
        form.attachedDocuments.length,
      ),
    );
    final attachmentActionsBoxTall = _AttachmentActionsBox(
      expandVertically: true,
      onAddDescription: () => setState(() => _showDescription = true),
      onAddImage: () => _promptAddImage(
        context,
        notifier,
        form.attachedImages.length,
      ),
      onAddDocument: () => _promptAddDocument(
        context,
        notifier,
        form.attachedDocuments.length,
      ),
    );
    final loyaltyPointsEnabled = ref.watch(partyLoyaltyPointsEnabledProvider);
    final showTransactionTaxes = ref.watch(gstAllowsTransactionTaxesProvider);
    final transactionFeatures = ref.watch(saleTransactionFeaturesProvider);
    final totalsSettings = ref.watch(saleTransactionTotalsSettingsProvider);
    final computedTotals = computeSaleInvoiceTotals(
      form: form,
      settings: totalsSettings,
    );
    final showRepeatInvoices =
        !totalsSettings.isLiteSale && transactionFeatures.repeatInvoices;
    final showTerms =
        !totalsSettings.isLiteSale &&
        transactionFeatures.termsAndConditionsEnabled;
    final repeatSection = showRepeatInvoices
        ? _RepeatInvoiceSection(sessionKey: widget.sessionKey)
        : null;
    final totalsSection = _TotalsSection(
      form: form,
      notifier: notifier,
      totalsSettings: totalsSettings,
      totalTax: totalTax,
      roundOffAmount: computedTotals.roundOffAmount,
      grandTotal: grandTotal,
      isCredit: isCredit,
      currencyFormat: currencyFormat,
      loyaltyPointsEnabled: loyaltyPointsEnabled,
      showTransactionTaxes: showTransactionTaxes,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < _compactBreakpoint;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (repeatSection != null) ...[
                repeatSection,
                const SizedBox(height: 16),
              ],
              if (showTerms) ...[
                termsSection,
                const SizedBox(height: 16),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _attachmentActionsWidthFactor,
                  child: attachmentActionsBox,
                ),
              ),
              attachmentExtras,
              const SizedBox(height: 16),
              totalsSection,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (repeatSection != null) ...[
              repeatSection,
              const SizedBox(height: 16),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTerms) ...[
                  Expanded(flex: 2, child: termsSection),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FractionallySizedBox(
                      widthFactor: _attachmentActionsWidthFactor,
                      child: showTerms
                          ? SizedBox(
                              height: _termsAndAttachmentPanelHeight,
                              child: attachmentActionsBoxTall,
                            )
                          : attachmentActionsBox,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(width: 260, child: totalsSection),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 2, child: SizedBox.shrink()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: attachmentExtras),
                const SizedBox(width: 16),
                const SizedBox(width: 260),
              ],
            ),
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
    required this.totalsSettings,
    required this.totalTax,
    required this.roundOffAmount,
    required this.grandTotal,
    required this.isCredit,
    required this.currencyFormat,
    required this.loyaltyPointsEnabled,
    required this.showTransactionTaxes,
  });

  final AddSaleFormState form;
  final AddSaleForm notifier;
  final SaleTransactionTotalsSettings totalsSettings;
  final double totalTax;
  final double roundOffAmount;
  final double grandTotal;
  final bool isCredit;
  final NumberFormat currencyFormat;
  final bool loyaltyPointsEnabled;
  final bool showTransactionTaxes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (totalsSettings.transactionWiseDiscount) ...[
          Row(
            children: [
              const Text(
                'Discount %',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: _AmountField(
                  value: form.transactionDiscountPercent,
                  readOnly: false,
                  onChanged: (value) =>
                      notifier.updateTransactionDiscountPercent(value),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 72,
                child: _AmountField(
                  value: form.subtotal * form.transactionDiscountPercent / 100,
                  readOnly: true,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
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
              if (totalsSettings.transactionWiseTax) ...[
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
              ],
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
        if (totalsSettings.roundOffTransactionAmount) ...[
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
                  value: roundOffAmount,
                  readOnly: true,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ],
        if (loyaltyPointsEnabled && form.showLoyaltySection) ...[
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
    return SizedBox(
      height: _termsAndAttachmentPanelHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: _cardBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_termsSectionPadding),
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
        fixedHeight: false,
      ),
      minLines: 3,
      maxLines: 4,
      onChanged: widget.onChanged,
    );
  }
}

class _AttachmentActionsBox extends StatelessWidget {
  const _AttachmentActionsBox({
    required this.expandVertically,
    required this.onAddDescription,
    required this.onAddImage,
    required this.onAddDocument,
  });

  final bool expandVertically;
  final VoidCallback onAddDescription;
  final VoidCallback onAddImage;
  final VoidCallback onAddDocument;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _AttachmentActionButton(
        icon: Icons.description_outlined,
        label: 'ADD DESCRIPTION',
        onPressed: onAddDescription,
        expand: expandVertically,
      ),
      _AttachmentActionButton(
        icon: Icons.camera_alt_outlined,
        label: 'ADD IMAGE',
        onPressed: onAddImage,
        expand: expandVertically,
      ),
      _AttachmentActionButton(
        icon: Icons.attach_file_outlined,
        label: 'ADD DOCUMENT',
        filled: true,
        onPressed: onAddDocument,
        expand: expandVertically,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: expandVertically
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: buttons[0]),
                  const SizedBox(height: 8),
                  Expanded(child: buttons[1]),
                  const SizedBox(height: 8),
                  Expanded(child: buttons[2]),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buttons[0],
                  const SizedBox(height: 8),
                  buttons[1],
                  const SizedBox(height: 8),
                  buttons[2],
                ],
              ),
      ),
    );
  }
}

class _AttachmentExtras extends StatelessWidget {
  const _AttachmentExtras({
    required this.showDescription,
    required this.form,
    required this.attachmentService,
    required this.onDescriptionChanged,
    required this.onRemoveImage,
    required this.onRenameImage,
    required this.onRemoveDocument,
    required this.onRenameDocument,
  });

  final bool showDescription;
  final AddSaleFormState form;
  final DocumentAttachmentService? attachmentService;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onRemoveImage;
  final void Function(String id, String name) onRenameImage;
  final ValueChanged<String> onRemoveDocument;
  final void Function(String id, String name) onRenameDocument;

  @override
  Widget build(BuildContext context) {
    final hasExtras =
        showDescription ||
        form.attachedImages.isNotEmpty ||
        form.attachedDocuments.isNotEmpty;
    if (!hasExtras) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDescription) ...[
          const SizedBox(height: 8),
          _DescriptionField(
            initialValue: form.description,
            onChanged: onDescriptionChanged,
          ),
        ],
        if (form.attachedImages.isNotEmpty) ...[
          const SizedBox(height: 8),
          SaleFormAttachmentChipList(
            attachments: form.attachedImages,
            attachmentService: attachmentService,
            onRemove: onRemoveImage,
            onRename: onRenameImage,
          ),
        ],
        if (form.attachedDocuments.isNotEmpty) ...[
          const SizedBox(height: 8),
          SaleFormAttachmentChipList(
            attachments: form.attachedDocuments,
            attachmentService: attachmentService,
            onRemove: onRemoveDocument,
            onRename: onRenameDocument,
          ),
        ],
      ],
    );
  }
}

class _AttachmentActionButton extends StatelessWidget {
  const _AttachmentActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.expand = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: expand ? double.infinity : null,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          minimumSize: expand ? Size.zero : null,
          tapTargetSize: expand ? MaterialTapTargetSize.shrinkWrap : null,
          side: const BorderSide(color: _cardBorder),
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
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
        fixedHeight: false,
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

class _RepeatInvoiceSection extends ConsumerWidget {
  const _RepeatInvoiceSection({required this.sessionKey});

  final String sessionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addSaleFormProvider(sessionKey: sessionKey));
    final notifier = ref.read(addSaleFormProvider(sessionKey: sessionKey).notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: _cardBorder),
        borderRadius: AppRadius.lgBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Repeat invoice',
              style: AppTypography.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'Create repeat invoices on a schedule',
                style: AppTypography.inter(fontSize: 13),
              ),
              value: form.repeatInvoiceEnabled,
              onChanged: (value) =>
                  notifier.updateRepeatInvoiceEnabled(value ?? false),
            ),
            if (form.repeatInvoiceEnabled) ...[
              const SizedBox(height: 4),
              Text(
                'Frequency',
                style: saleFieldLabelStyle,
              ),
              const SizedBox(height: 4),
              SaleGenericSelectDropdown(
                value: form.repeatInvoiceFrequency,
                options: saleRepeatInvoiceFrequencies,
                hintText: 'Select frequency',
                compact: true,
                onSelected: notifier.updateRepeatInvoiceFrequency,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
