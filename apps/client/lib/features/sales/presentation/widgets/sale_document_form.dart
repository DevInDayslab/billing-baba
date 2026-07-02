import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_document_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/providers/sale_document_form_provider.dart';
import 'package:billing_baba/features/sales/providers/saved_sale_documents_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

/// Shared two-state form for Estimate/Quotation and Proforma Invoice.
class SaleDocumentForm extends ConsumerWidget {
  const SaleDocumentForm({
    required this.documentType,
    required this.route,
    required this.pageTitle,
    required this.accentColor,
    required this.illustrationCircleColor,
    required this.illustrationSquareColor,
    required this.emptyStateDescription,
    required this.createButtonLabel,
    super.key,
  });

  final SaleDocumentType documentType;
  final String route;
  final String pageTitle;
  final Color accentColor;
  final Color illustrationCircleColor;
  final Color illustrationSquareColor;
  final String emptyStateDescription;
  final String createButtonLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(saleDocumentFormProvider(documentType));

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SalePageTitleBar(currentRoute: route, onSettingsTap: () {}),
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lgBorder,
                border: Border.all(color: _cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: form.isFormOpen
                  ? _FormContent(
                      documentType: documentType,
                      pageTitle: pageTitle,
                    )
                  : _EmptyState(
                      documentType: documentType,
                      accentColor: accentColor,
                      circleColor: illustrationCircleColor,
                      squareColor: illustrationSquareColor,
                      description: emptyStateDescription,
                      createButtonLabel: createButtonLabel,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState({
    required this.documentType,
    required this.accentColor,
    required this.circleColor,
    required this.squareColor,
    required this.description,
    required this.createButtonLabel,
  });

  final SaleDocumentType documentType;
  final Color accentColor;
  final Color circleColor;
  final Color squareColor;
  final String description;
  final String createButtonLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedDocuments = ref
        .watch(savedSaleDocumentsProvider)
        .where((doc) => doc.documentType == documentType)
        .toList();

    return SizedBox(
      height: savedDocuments.isEmpty ? 480 : null,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 230,
              height: 230,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: squareColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => ref
                  .read(saleDocumentFormProvider(documentType).notifier)
                  .openForm(),
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(
                createButtonLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (savedDocuments.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Saved documents',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480, maxHeight: 200),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: savedDocuments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final saved = savedDocuments[index];
                    final dateLabel = saved.invoiceDate != null
                        ? DateFormat('dd MMM yyyy').format(saved.invoiceDate!)
                        : 'No date';
                    return Material(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(
                                saleDocumentFormProvider(documentType).notifier,
                              )
                              .loadSavedDocument(saved);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      saved.party.isEmpty
                                          ? 'Untitled'
                                          : saved.party,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$dateLabel · ${saved.attachedImages.length} image(s) · ${saved.attachedDocuments.length} doc(s)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    if (saved.description.isNotEmpty)
                                      Text(
                                        saved.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                  locale: 'en_IN',
                                  symbol: '₹',
                                  decimalDigits: 2,
                                ).format(saved.total),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                tooltip: 'Delete',
                                onPressed: () {
                                  ref
                                      .read(savedSaleDocumentsProvider.notifier)
                                      .removeDocument(saved.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormContent extends ConsumerWidget {
  const _FormContent({
    required this.documentType,
    required this.pageTitle,
  });

  final SaleDocumentType documentType;
  final String pageTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            _sectionGap,
            _sectionGap,
            _sectionGap,
            0,
          ),
          child: _FormHeader(
            documentType: documentType,
            pageTitle: pageTitle,
          ),
        ),
        const SizedBox(height: _sectionGap),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _sectionGap),
          child: _DocumentFormFields(documentType: documentType),
        ),
        const SizedBox(height: _sectionGap),
        SaleDocumentLineItemsTable(documentType: documentType),
        const Divider(height: 1, color: _cardBorder),
        Padding(
          padding: const EdgeInsets.all(_sectionGap),
          child: _DocumentFooter(documentType: documentType),
        ),
        const Divider(height: 1, color: _cardBorder),
        _BottomActionBar(documentType: documentType),
      ],
    );
  }
}

class _FormHeader extends ConsumerWidget {
  const _FormHeader({
    required this.documentType,
    required this.pageTitle,
  });

  final SaleDocumentType documentType;
  final String pageTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(saleDocumentFormProvider(documentType));
    final notifier = ref.read(
      saleDocumentFormProvider(documentType).notifier,
    );

    return Row(
      children: [
        Text(
          pageTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        _GodownChipSelector(
          value: form.godown,
          onSelected: notifier.updateGodown,
        ),
      ],
    );
  }
}

class _GodownChipSelector extends StatefulWidget {
  const _GodownChipSelector({
    required this.value,
    required this.onSelected,
  });

  final String value;
  final ValueChanged<String> onSelected;

  @override
  State<_GodownChipSelector> createState() => _GodownChipSelectorState();
}

class _GodownChipSelectorState extends State<_GodownChipSelector> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _select(String value) {
    _removeOverlay();
    widget.onSelected(value);
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 36),
              child: Material(
                elevation: 4,
                shadowColor: Colors.black26,
                borderRadius: AppRadius.smBorder,
                clipBehavior: Clip.antiAlias,
                color: AppColors.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 160),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final option in saleDocumentGodowns)
                        InkWell(
                          onTap: () => _select(option),
                          hoverColor: const Color(0xFFF5F5F5),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: option == widget.value
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: option == widget.value
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Godown: ',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentFormFields extends ConsumerStatefulWidget {
  const _DocumentFormFields({required this.documentType});

  final SaleDocumentType documentType;

  @override
  ConsumerState<_DocumentFormFields> createState() =>
      _DocumentFormFieldsState();
}

class _DocumentFormFieldsState extends ConsumerState<_DocumentFormFields> {
  final _invoiceDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(
      saleDocumentFormProvider(widget.documentType),
    );
    final notifier = ref.read(
      saleDocumentFormProvider(widget.documentType).notifier,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _RequiredLabeledField(
            label: 'Party',
            child: BillingNamePartySearchField(
              value: form.party,
              hasError: form.partyHasError,
              emptyPlaceholder: 'Search Party Name',
              errorMessage: 'Party is required',
              onSelected: notifier.updateParty,
            ),
          ),
        ),
        const SizedBox(width: _sectionGap),
        SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LabeledField(
                label: 'Ref No.',
                child: _SaleTextField(
                  initialValue: form.refNo,
                  hintText: 'Ref No.',
                  onChanged: notifier.updateRefNo,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Invoice Date',
                child: SaleSingleDatePickerAnchor(
                  key: _invoiceDatePickerKey,
                  selectedDate: form.invoiceDate,
                  onDateSelected: notifier.updateInvoiceDate,
                  child: _PickerField(
                    value: formatSaleSingleDate(form.invoiceDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () =>
                        _invoiceDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Time',
                child: _PickerField(
                  value: _formatTime(form.invoiceTime),
                  icon: Icons.access_time,
                  onTap: () => _pickTime(context, form.invoiceTime),
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'State of Supply',
                child: SaleGenericSelectDropdown(
                  value: form.stateOfSupply,
                  options: SaleDropdownOptions.indianStates,
                  maxMenuHeight: 280,
                  onSelected: notifier.updateStateOfSupply,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickTime(BuildContext context, TimeOfDay? current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
    );
    if (picked != null) {
      ref
          .read(
            saleDocumentFormProvider(widget.documentType).notifier,
          )
          .updateInvoiceTime(picked);
    }
  }
}

class _DocumentFooter extends ConsumerWidget {
  const _DocumentFooter({required this.documentType});

  final SaleDocumentType documentType;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(saleDocumentFormProvider(documentType));
    final notifier = ref.read(
      saleDocumentFormProvider(documentType).notifier,
    );
    final totalTax = ref.watch(
      saleDocumentTotalTaxProvider(documentType),
    );
    final grandTotal = ref.watch(
      saleDocumentGrandTotalProvider(documentType),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SaleFormAttachmentsSection(
            description: form.description,
            images: form.attachedImages,
            documents: form.attachedDocuments,
            onDescriptionChanged: notifier.updateDescription,
            onAddImage: () => _DocumentFooter._promptAddImage(
              context,
              notifier,
              form.attachedImages.length,
            ),
            onRemoveImage: notifier.removeImage,
            onUpdateImage: notifier.updateImage,
            onAddDocument: () => _DocumentFooter._promptAddDocument(
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
                  const Text('Tax', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: SaleGenericSelectDropdown(
                      value: form.taxOption,
                      options: SaleDropdownOptions.taxSlabs,
                      highlight: SaleDropdownHighlight.red,
                      compact: true,
                      onSelected: notifier.updateTaxOption,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _currencyFormat.format(totalTax),
                    style: const TextStyle(fontSize: 13),
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
                  SizedBox(
                    width: 120,
                    child: _AmountField(
                      value: grandTotal,
                      readOnly: true,
                      onChanged: (_) {},
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

  static Future<void> _promptAddImage(
    BuildContext context,
    SaleDocumentFormNotifier notifier,
    int currentCount,
  ) async {
    final attachment = await promptSaleFormAttachment(
      context,
      title: 'Add image',
      defaultName: 'image_${currentCount + 1}.png',
    );
    if (attachment != null) notifier.addImage(attachment);
  }

  static Future<void> _promptAddDocument(
    BuildContext context,
    SaleDocumentFormNotifier notifier,
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

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({required this.documentType});

  final SaleDocumentType documentType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      saleDocumentFormProvider(documentType).notifier,
    );
    final grandTotal = ref.watch(
      saleDocumentGrandTotalProvider(documentType),
    );
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Spacer(),
          ShareMenuButton(
            onChannelSelected: (channel) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${channel.label} coming soon')),
              );
            },
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                ),
              ),
              Text(
                currencyFormat.format(grandTotal),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () {
              final saved = notifier.save();
              if (!saved) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(documentType.saveSuccessMessage),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text('Save', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _RequiredLabeledField extends StatelessWidget {
  const _RequiredLabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: saleFieldLabelStyle.copyWith(color: AppColors.primary),
            children: [
              TextSpan(text: label),
              const TextSpan(
                text: ' *',
                style: TextStyle(color: saleFieldErrorColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: saleFieldLabelStyle),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _SaleTextField extends StatefulWidget {
  const _SaleTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  State<_SaleTextField> createState() => _SaleTextFieldState();
}

class _SaleTextFieldState extends State<_SaleTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_SaleTextField oldWidget) {
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
      style: saleFieldTextStyle,
      decoration: buildSaleFieldDecoration(hint: widget.hintText),
      onChanged: widget.onChanged,
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SaleFieldTrigger(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: saleFieldTextStyle,
            ),
          ),
          Icon(icon, size: 15, color: AppColors.textSecondary),
        ],
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
    final newText = widget.value == 0
        ? '0'
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
