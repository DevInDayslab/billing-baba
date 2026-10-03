import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/application/add_purchase_form_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_document_desktop_import.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/add_purchase_footer.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_line_items_table.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/transaction_form_busy_overlay.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/purchases/utils/purchase_line_item_catalog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/godown_label_selector.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/shared/widgets/document_barcode_keyboard_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _addPurchaseRed = Color(0xFFD32F2F);

class DesktopAddPurchasePage extends ConsumerStatefulWidget {
  const DesktopAddPurchasePage({this.billId, super.key});

  final String? billId;

  @override
  ConsumerState<DesktopAddPurchasePage> createState() =>
      _DesktopAddPurchasePageState();
}

class _DesktopAddPurchasePageState
    extends ConsumerState<DesktopAddPurchasePage> {
  var _routeExtraConsumed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumeRouteExtra());
  }

  void _consumeRouteExtra() {
    if (_routeExtraConsumed || !mounted || widget.billId != null) return;
    final extra = GoRouterState.of(context).extra;
    if (extra is! PurchaseDocumentParseDto) return;
    _routeExtraConsumed = true;
    // Pending provider may already have applied; skip duplicate if form dirty.
    final form = ref.read(addPurchaseFormProvider());
    if (form.isDirty && form.items.any((line) => line.itemName.isNotEmpty)) {
      return;
    }
    unawaited(
      ref
          .read(addPurchaseFormProvider().notifier)
          .consumeRouteExtraParse(extra),
    );
  }

  @override
  Widget build(BuildContext context) {
    final billId = widget.billId;
    final form = ref.watch(addPurchaseFormProvider(billId: billId));

    ref.listen(addPurchaseFormProvider(billId: billId), (previous, next) {
      final error = next.saveError;
      if (error == null || error == previous?.saveError) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: _addPurchaseRed),
      );
    });

    return DocumentBarcodeKeyboardHost(
      onCatalogItem: (catalog) async {
        final current = ref.read(addPurchaseFormProvider(billId: billId));
        final notifier = ref.read(
          addPurchaseFormProvider(billId: billId).notifier,
        );
        var index = current.items.lastIndexWhere(isEmptyPurchaseLineDraft);
        if (index < 0) {
          notifier.addLineItem();
          index =
              ref.read(addPurchaseFormProvider(billId: billId)).items.length -
              1;
        }
        notifier.selectCatalogItem(index, catalog);
      },
      child: Stack(
        children: [
          ColoredBox(
            color: AppColors.background,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PurchasePageTitleBar(
                    currentRoute: AppRoutes.purchaseBills,
                    onBack: () => leaveTransactionFormPage(
                      context: context,
                      isDirty: form.isDirty,
                      isSaving: form.isSaving,
                      listRoute: AppRoutes.purchaseBills,
                    ),
                  ),
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
                          child: _PageHeader(billId: billId),
                        ),
                        const SizedBox(height: _sectionGap),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _sectionGap,
                          ),
                          child: _FormFields(billId: billId),
                        ),
                        const SizedBox(height: _sectionGap),
                        PurchaseLineItemsTable(embedded: true, billId: billId),
                        const Divider(height: 1, color: _cardBorder),
                        Padding(
                          padding: const EdgeInsets.all(_sectionGap),
                          child: AddPurchaseFooter(billId: billId),
                        ),
                        const Divider(height: 1, color: _cardBorder),
                        _BottomActionBar(billId: billId),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: TransactionFormBusyOverlay(
              isLoading: form.isLoading,
              isSaving: form.isSaving,
              savingLabel: billId == null
                  ? 'Saving purchase bill…'
                  : 'Updating purchase bill…',
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends ConsumerWidget {
  const _PageHeader({this.billId});

  final String? billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPurchaseFormProvider(billId: billId));
    final notifier = ref.read(addPurchaseFormProvider(billId: billId).notifier);

    return Row(
      children: [
        const Text(
          'Purchase',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        GodownLabelSelector(
          value: form.godown,
          onSelected: notifier.updateGodown,
        ),
      ],
    );
  }
}

class _FormFields extends ConsumerStatefulWidget {
  const _FormFields({this.billId});

  final String? billId;

  @override
  ConsumerState<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends ConsumerState<_FormFields> {
  final _billDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addPurchaseFormProvider(billId: widget.billId));
    final notifier = ref.read(
      addPurchaseFormProvider(billId: widget.billId).notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _LabeledField(
                label: 'Party *',
                child: BillingNamePartySearchField(
                  value: form.party,
                  selectedPartyId: form.partyId,
                  hasError: form.partyHasError,
                  errorMessage: 'Please select a party',
                  emptyPlaceholder: 'Search party name',
                  onSelected: notifier.updateParty,
                  onPartySelectedWithId: (partyId, name) =>
                      notifier.updateParty(name, partyId: partyId),
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'E-Way Bill No.',
                child: _PurchaseTextField(
                  initialValue: form.eWayBillNo,
                  hintText: 'E-Way bill number',
                  onChanged: notifier.updateEWayBillNo,
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'Bill Number',
                child: _PurchaseTextField(
                  initialValue: form.billNumber,
                  hintText: 'Assigned on save',
                  readOnly: true,
                  onChanged: (_) {},
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'Bill Date',
                child: SaleSingleDatePickerAnchor(
                  key: _billDatePickerKey,
                  selectedDate: form.billDate,
                  onDateSelected: notifier.updateBillDate,
                  child: _PickerField(
                    value: form.billDate != null
                        ? formatSaleSingleDate(form.billDate)
                        : 'Select Date',
                    icon: Icons.calendar_today_outlined,
                    isPlaceholder: form.billDate == null,
                    onTap: () => _billDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (form.party.trim().isNotEmpty) ...[
          const SizedBox(height: _sectionGap),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _LabeledField(
                  label: 'Billing Name (optional)',
                  child: _PurchaseTextField(
                    initialValue: form.billingName,
                    hintText: 'Billing name',
                    onChanged: notifier.updateBillingName,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: _sectionGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LabeledField(
                label: 'Time',
                child: SaleTimeDropdown(
                  value: form.billTime,
                  hasError: form.billTime == null,
                  onSelected: notifier.updateBillTime,
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              flex: 2,
              child: _LabeledField(
                label: 'Payment Terms',
                child: SaleGenericSelectDropdown(
                  value: form.paymentTerms,
                  options: purchasePaymentTerms,
                  hintText: 'Select terms',
                  onSelected: notifier.updatePaymentTerms,
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'Due Date',
                child: SaleSingleDatePickerAnchor(
                  key: _dueDatePickerKey,
                  selectedDate: form.dueDate,
                  onDateSelected: notifier.updateDueDate,
                  child: _PickerField(
                    value: form.dueDate != null
                        ? formatSaleSingleDate(form.dueDate)
                        : 'Select Date',
                    icon: Icons.calendar_today_outlined,
                    isPlaceholder: form.dueDate == null,
                    onTap: () => _dueDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              flex: 2,
              child: _LabeledField(
                label: 'State of supply',
                child: SaleGenericSelectDropdown(
                  value: form.stateOfSupply,
                  options: SaleDropdownOptions.indianStates,
                  hintText: 'Select state',
                  maxMenuHeight: 280,
                  onSelected: notifier.updateStateOfSupply,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({this.billId});

  final String? billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPurchaseFormProvider(billId: billId));
    final notifier = ref.read(addPurchaseFormProvider(billId: billId).notifier);
    final isSaving = form.isSaving;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: isSaving
                ? null
                : () => runPurchaseDocumentDesktopImport(
                    context: context,
                    billId: billId,
                  ),
            icon: const Icon(Icons.upload_file_outlined, size: 16),
            label: const Text('Upload Bill', style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: const BorderSide(color: _cardBorder),
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: isSaving
                ? null
                : () => leaveTransactionFormPage(
                    context: context,
                    isDirty: form.isDirty,
                    isSaving: form.isSaving,
                    listRoute: AppRoutes.purchaseBills,
                  ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              side: const BorderSide(color: _cardBorder),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (form.documentId != null) ...[
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
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: isSaving
                  ? null
                  : () => _handleShare(context, ref, form),
              icon: const Icon(Icons.share_outlined, size: 20),
              color: AppColors.textSecondary,
              tooltip: 'Share PDF',
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          FilledButton(
            onPressed: isSaving
                ? null
                : () => _handleSave(context, ref, notifier),
            style: FilledButton.styleFrom(
              backgroundColor: _addPurchaseRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    AddPurchaseForm notifier,
  ) async {
    final form = ref.read(addPurchaseFormProvider(billId: billId));
    await handleTransactionFormSave(
      context: context,
      isSaving: form.isSaving,
      save: notifier.saveBill,
      listRoute: AppRoutes.purchaseBills,
    );
  }

  Future<void> _handlePrintPreview(
    BuildContext context,
    WidgetRef ref,
    AddPurchaseFormState form,
  ) async {
    final docId = form.documentId ?? billId;
    if (docId == null) return;
    await DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.purchaseBill(docId),
      filename: DocumentPrintActions.filenameFor(
        form.billNumber.isNotEmpty ? form.billNumber : docId,
      ),
    );
  }

  Future<void> _handleShare(
    BuildContext context,
    WidgetRef ref,
    AddPurchaseFormState form,
  ) async {
    final docId = form.documentId ?? billId;
    if (docId == null) return;
    await DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.purchaseBill(docId),
      filename: DocumentPrintActions.filenameFor(
        form.billNumber.isNotEmpty ? form.billNumber : docId,
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

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

class _PurchaseTextField extends StatefulWidget {
  const _PurchaseTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.readOnly = false,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final bool readOnly;

  @override
  State<_PurchaseTextField> createState() => _PurchaseTextFieldState();
}

class _PurchaseTextFieldState extends State<_PurchaseTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_PurchaseTextField oldWidget) {
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
    return SaleTextField(
      controller: _controller,
      readOnly: widget.readOnly,
      hint: widget.hintText,
      onChanged: widget.readOnly ? null : widget.onChanged,
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.icon,
    required this.onTap,
    this.isPlaceholder = false,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return SaleFieldTrigger(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: saleFieldTextStyle.copyWith(
                color: isPlaceholder ? saleFieldErrorColor : null,
              ),
            ),
          ),
          Icon(icon, size: 15, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
