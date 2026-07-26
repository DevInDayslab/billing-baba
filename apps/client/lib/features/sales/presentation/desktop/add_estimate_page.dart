import 'package:billing_baba/shared/navigation/transaction_detail_navigation.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/share_menu_button.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/application/sale_document_form_provider.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/godown_label_selector.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_document_footer.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_document_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
const SaleDocumentType _documentType = SaleDocumentType.estimate;
const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

class DesktopAddEstimatePage extends ConsumerStatefulWidget {
  const DesktopAddEstimatePage({
    this.estimateId,
    this.duplicateFromId,
    super.key,
  });

  final String? estimateId;
  final String? duplicateFromId;

  @override
  ConsumerState<DesktopAddEstimatePage> createState() => _AddEstimatePageState();
}

class _AddEstimatePageState extends ConsumerState<DesktopAddEstimatePage> {
  var _initialized = false;

  bool get _isEditing => widget.estimateId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeForm());
  }

  Future<void> _initializeForm() async {
    final notifier = ref.read(saleDocumentFormProvider(_documentType).notifier);
    if (widget.duplicateFromId != null) {
      await notifier.duplicateDocument(widget.duplicateFromId!);
    } else if (widget.estimateId != null) {
      await notifier.loadDocument(widget.estimateId!);
    } else {
      notifier.openForm();
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  Future<void> _handleClose() async {
    final confirmed = await showCloseFormDialog(
      context,
      title: 'Close Estimate',
    );
    if (!confirmed || !mounted) return;
    ref.read(saleDocumentFormProvider(_documentType).notifier).resetForm();
    returnToTransactionList(context, AppRoutes.saleEstimateQuotation);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      saleDocumentFormProvider(_documentType).select((form) => form.isLoading),
    );

    if (!_initialized || isLoading) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleClose();
      },
      child: ColoredBox(
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: SalePageTitleBar(
                currentRoute: AppRoutes.saleEstimateQuotation,
                onSettingsTap: () {},
                onBack: _handleClose,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: DecoratedBox(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          _sectionGap,
                          _sectionGap,
                          _sectionGap,
                          0,
                        ),
                        child: _EstimatePageHeader(
                          isEditing: _isEditing,
                          onClose: _handleClose,
                        ),
                      ),
                      const SizedBox(height: _sectionGap),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: _sectionGap),
                        child: _EstimateFormFields(),
                      ),
                      const SizedBox(height: _sectionGap),
                      const SaleDocumentLineItemsTable(
                        documentType: _documentType,
                        embedded: true,
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      const Padding(
                        padding: EdgeInsets.all(_sectionGap),
                        child: SaleDocumentFooter(documentType: _documentType),
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      _EstimateBottomActionBar(
                        isEditing: _isEditing,
                        onSaved: () => returnToTransactionList(
                          context,
                          AppRoutes.saleEstimateQuotation,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstimatePageHeader extends ConsumerWidget {
  const _EstimatePageHeader({
    required this.isEditing,
    required this.onClose,
  });

  final bool isEditing;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(saleDocumentFormProvider(_documentType));
    final notifier = ref.read(
      saleDocumentFormProvider(_documentType).notifier,
    );

    return Row(
      children: [
        Text(
          isEditing ? 'Edit Estimate/Quotation' : 'Estimate/Quotation',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        _GodownSelector(
          value: form.godown,
          onSelected: notifier.updateGodown,
        ),
        const SizedBox(width: AppSpacing.xs),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, size: 20),
          color: AppColors.textSecondary,
          tooltip: 'Close',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _GodownSelector extends ConsumerWidget {
  const _GodownSelector({
    required this.value,
    required this.onSelected,
  });

  final String value;
  final void Function(String name, {String? godownId}) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final godownsAsync = ref.watch(inventoryGodownsProvider);
    final options = godownsAsync.maybeWhen(
      data: (godowns) => godowns.map((godown) => godown.name).toList(),
      orElse: () => SaleDropdownOptions.godowns,
    );

    return GodownLabelSelector(
      value: value,
      options: options,
      onSelected: (name) {
        final godowns = ref.read(inventoryGodownsProvider).value ?? [];
        final match = godowns
            .where((godown) => godown.name == name)
            .firstOrNull;
        onSelected(name, godownId: match?.id);
      },
    );
  }
}

class _EstimateFormFields extends ConsumerStatefulWidget {
  const _EstimateFormFields();

  @override
  ConsumerState<_EstimateFormFields> createState() =>
      _EstimateFormFieldsState();
}

class _EstimateFormFieldsState extends ConsumerState<_EstimateFormFields> {
  final _invoiceDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(saleDocumentFormProvider(_documentType));
    final notifier = ref.read(
      saleDocumentFormProvider(_documentType).notifier,
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
                child: SaleTimeDropdown(
                  value: form.invoiceTime,
                  onSelected: notifier.updateInvoiceTime,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'State of supply',
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
}

class _EstimateBottomActionBar extends ConsumerWidget {
  const _EstimateBottomActionBar({
    required this.isEditing,
    required this.onSaved,
  });

  final bool isEditing;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(saleDocumentFormProvider(_documentType));
    final notifier = ref.read(
      saleDocumentFormProvider(_documentType).notifier,
    );
    final isSaving = form.isSaving;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (form.documentId != null)
            OutlinedButton.icon(
              onPressed: isSaving
                  ? null
                  : () => _handlePrintPreview(context, ref, form),
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
          const Spacer(),
          ShareMenuButton(
            onChannelSelected: isSaving
                ? null
                : (_) => _handleSaveAndShare(context, ref, notifier),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: isSaving
                ? null
                : () => _handleSave(context, ref, notifier),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
            ),
            child: isSaving
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Saving...', style: TextStyle(fontSize: 13)),
                    ],
                  )
                : const Text('Save', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  String _filename(SaleDocumentFormState form) {
    final number = form.refNo.trim();
    if (number.isNotEmpty) {
      return DocumentPrintActions.filenameFor(number);
    }
    final id = form.documentId;
    return id == null ? 'estimate' : DocumentPrintActions.filenameFor(id);
  }

  Future<void> _handlePrintPreview(
    BuildContext context,
    WidgetRef ref,
    SaleDocumentFormState form,
  ) async {
    final docId = form.documentId;
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the estimate before printing')),
      );
      return;
    }
    await DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.estimate(docId),
      filename: _filename(form),
    );
  }

  Future<void> _handleSaveAndShare(
    BuildContext context,
    WidgetRef ref,
    SaleDocumentFormNotifier notifier,
  ) async {
    final form = ref.read(saleDocumentFormProvider(_documentType));
    if (form.isSaving) return;

    final error = await notifier.saveDraft();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    _showSaveSuccessSnackBar(context);
    final saved = ref.read(saleDocumentFormProvider(_documentType));
    final docId = saved.documentId;
    if (docId == null) {
      onSaved();
      return;
    }
    await DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.estimate(docId),
      filename: _filename(saved),
    );
    if (context.mounted) onSaved();
  }

  void _showSaveSuccessSnackBar(BuildContext context) {
    final message = isEditing
        ? 'Estimate updated successfully.'
        : 'Estimate created successfully.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    SaleDocumentFormNotifier notifier,
  ) async {
    final form = ref.read(saleDocumentFormProvider(_documentType));
    if (form.isSaving) return;

    final error = await notifier.saveDraft();
    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    _showSaveSuccessSnackBar(context);
    ref.read(saleDocumentFormProvider(_documentType).notifier).resetForm();
    onSaved();
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(icon, size: 15, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
