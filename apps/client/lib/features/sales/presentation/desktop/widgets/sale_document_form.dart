import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/application/sale_document_form_provider.dart';
import 'package:billing_baba/features/sales/application/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_document_footer.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_document_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_document_actions.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_documents_filter_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_documents_table.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

/// Shared two-state form for Estimate/Quotation and Proforma Invoice.
class SaleDocumentForm extends ConsumerStatefulWidget {
  const SaleDocumentForm({
    required this.documentType,
    required this.route,
    required this.pageTitle,
    required this.accentColor,
    required this.illustrationCircleColor,
    required this.illustrationSquareColor,
    required this.emptyStateDescription,
    required this.createButtonLabel,
    this.onClose,
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
  final VoidCallback? onClose;

  @override
  ConsumerState<SaleDocumentForm> createState() => _SaleDocumentFormState();
}

class _SaleDocumentFormState extends ConsumerState<SaleDocumentForm> {
  String get _closeFormTitle => switch (widget.documentType) {
    SaleDocumentType.estimate => 'Close Estimate',
    SaleDocumentType.proforma => 'Close Proforma Invoice',
  };

  Future<void> _handleBack() async {
    final form = ref.read(saleDocumentFormProvider(widget.documentType));
    if (!form.isFormOpen) return;

    final confirmed = await showCloseFormDialog(
      context,
      title: _closeFormTitle,
    );
    if (!confirmed || !mounted) return;
    ref
        .read(saleDocumentFormProvider(widget.documentType).notifier)
        .closeForm();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(saleDocumentFormProvider(widget.documentType));
    final scope = switch (widget.documentType) {
      SaleDocumentType.estimate => estimateListScope(),
      SaleDocumentType.proforma => proformaListScope(),
    };
    final tableConfig = switch (widget.documentType) {
      SaleDocumentType.estimate => estimateTableConfig(),
      SaleDocumentType.proforma => proformaTableConfig(),
    };
    final formNotifier = ref.read(
      saleDocumentFormProvider(widget.documentType).notifier,
    );

    return PopScope(
      canPop: !form.isFormOpen,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: ColoredBox(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (form.isFormOpen)
                Row(
                  children: [
                    IconButton(
                      onPressed: _handleBack,
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textSecondary,
                      tooltip: 'Back',
                      visualDensity: VisualDensity.compact,
                    ),
                    Expanded(
                      child: SalePageTitleBar(
                        currentRoute: widget.route,
                        onSettingsTap: () {},
                      ),
                    ),
                  ],
                )
              else
                SalePageTitleBar(
                  currentRoute: widget.route,
                  onSettingsTap: () {},
                ),
              const SizedBox(height: AppSpacing.md),
              if (form.isFormOpen || widget.onClose != null)
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
                  child: _FormContent(
                    documentType: widget.documentType,
                    pageTitle: widget.pageTitle,
                    onClose: widget.onClose,
                  ),
                )
              else ...[
                SalesDocumentsFilterBar(
                  scope: scope,
                  onAdd: formNotifier.openForm,
                  addButtonLabel: widget.createButtonLabel,
                ),
                const SizedBox(height: AppSpacing.md),
                SalesDocumentsTable(config: tableConfig),
              ],
            ],
          ),
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
    final scope = switch (documentType) {
      SaleDocumentType.estimate => estimateListScope(),
      SaleDocumentType.proforma => proformaListScope(),
    };
    final documentsAsync = ref.watch(salesDocumentsListProvider(scope));
    final documents = documentsAsync.maybeWhen(
      data: (page) => page.items,
      orElse: () => const <SaleInvoiceModel>[],
    );
    final listNotifier = ref.read(salesDocumentsListProvider(scope).notifier);

    return SizedBox(
      height: documents.isEmpty && !documentsAsync.isLoading ? 480 : null,
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
            if (documentsAsync.isLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              )
            else if (documentsAsync.hasError)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      documentsAsync.error.toString(),
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: listNotifier.refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (documents.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Text(
                    'Saved documents',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  _XlsChip(
                    onTap: () => ModuleExportActions.exportSalesDocuments(
                      context,
                      ref,
                      scope,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                  maxHeight: 200,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: documents.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final saved = documents[index];
                    final dateLabel = DateFormat('dd MMM yyyy').format(
                      saved.date,
                    );
                    return Material(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(
                                saleDocumentFormProvider(documentType).notifier,
                              )
                              .loadDocument(saved.id);
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
                                      saved.partyName.isEmpty
                                          ? 'Untitled'
                                          : saved.partyName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$dateLabel · ${saved.invoiceNo}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                  locale: 'en_IN',
                                  symbol: '₹',
                                  decimalDigits: 2,
                                ).format(saved.amount),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (saved.isDraft)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  tooltip: 'Delete',
                                  onPressed: () async {
                                    final error = await listNotifier
                                        .deleteDraft(saved.id);
                                    if (!context.mounted) return;
                                    if (error != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(error)),
                                      );
                                    }
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
    this.onClose,
  });

  final SaleDocumentType documentType;
  final String pageTitle;
  final VoidCallback? onClose;

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
            onClose: onClose,
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
          child: SaleDocumentFooter(documentType: documentType),
        ),
        const Divider(height: 1, color: _cardBorder),
        _BottomActionBar(documentType: documentType, onClose: onClose),
      ],
    );
  }
}

class _FormHeader extends ConsumerWidget {
  const _FormHeader({
    required this.documentType,
    required this.pageTitle,
    this.onClose,
  });

  final SaleDocumentType documentType;
  final String pageTitle;
  final VoidCallback? onClose;

  Future<void> _handleClose(BuildContext context, WidgetRef ref) async {
    final title = switch (documentType) {
      SaleDocumentType.estimate => 'Close Estimate',
      SaleDocumentType.proforma => 'Close Proforma Invoice',
    };
    final confirmed = await showCloseFormDialog(context, title: title);
    if (!confirmed || !context.mounted) return;
    ref.read(saleDocumentFormProvider(documentType).notifier).closeForm();
    onClose?.call();
  }

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
        if (onClose != null) ...[
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: () => _handleClose(context, ref),
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Close',
            visualDensity: VisualDensity.compact,
          ),
        ],
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
              selectedPartyId: form.partyId,
              hasError: form.partyHasError,
              emptyPlaceholder: 'Search Party Name',
              errorMessage: 'Party is required',
              onSelected: notifier.updateParty,
              onPartySelectedWithId: (partyId, name) =>
                  notifier.updatePartyWithId(partyId: partyId, partyName: name),
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
                    onTap: () => _invoiceDatePickerKey.currentState?.toggle(),
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

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({
    required this.documentType,
    this.onClose,
  });

  final SaleDocumentType documentType;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(saleDocumentFormProvider(documentType));
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
          if (form.documentId != null) ...[
            OutlinedButton.icon(
              onPressed: () => _handlePrintPreview(context, ref, form),
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text(
                'Print / Preview',
                style: TextStyle(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                side: const BorderSide(color: _cardBorder),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: () => _handleShare(context, ref, form),
              icon: const Icon(Icons.share_outlined, size: 20),
              color: AppColors.textSecondary,
              tooltip: 'Share PDF',
            ),
          ],
          const Spacer(),
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
            onPressed: form.isSaving
                ? null
                : () async {
                    final error = await notifier.save();
                    if (!context.mounted) return;
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(documentType.saveSuccessMessage),
                      ),
                    );
                    onClose?.call();
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

  PrintRequest _printRequest(String documentId) {
    return switch (documentType) {
      SaleDocumentType.estimate => PrintRequest.estimate(documentId),
      SaleDocumentType.proforma => PrintRequest.proformaInvoice(documentId),
    };
  }

  String _filename(SaleDocumentFormState form) {
    final number = form.refNo.trim();
    if (number.isNotEmpty) {
      return DocumentPrintActions.filenameFor(number);
    }
    final id = form.documentId;
    return id == null ? 'document' : DocumentPrintActions.filenameFor(id);
  }

  Future<void> _handlePrintPreview(
    BuildContext context,
    WidgetRef ref,
    SaleDocumentFormState form,
  ) async {
    final docId = form.documentId;
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the document before printing')),
      );
      return;
    }
    await DocumentPrintActions.preview(
      context,
      ref,
      _printRequest(docId),
      filename: _filename(form),
    );
  }

  Future<void> _handleShare(
    BuildContext context,
    WidgetRef ref,
    SaleDocumentFormState form,
  ) async {
    final docId = form.documentId;
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the document before sharing')),
      );
      return;
    }
    await DocumentPrintActions.share(
      context,
      ref,
      _printRequest(docId),
      filename: _filename(form),
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

class _XlsChip extends StatelessWidget {
  const _XlsChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Text(
            'xls',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ),
    );
  }
}
