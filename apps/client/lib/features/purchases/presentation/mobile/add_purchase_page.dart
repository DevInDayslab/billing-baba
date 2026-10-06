import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/documents/application/document_number_preview.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/application/add_purchase_form_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/purchases/utils/purchase_line_item_catalog.dart';
import 'package:billing_baba/features/inventory/application/barcode_scan_handler.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_barcode_scanner_screen.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/document_barcode_keyboard_host.dart';
import 'package:billing_baba/shared/widgets/document_barcode_scan.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileAddPurchasePage extends ConsumerStatefulWidget {
  const MobileAddPurchasePage({super.key, this.billId});

  final String? billId;

  @override
  ConsumerState<MobileAddPurchasePage> createState() =>
      _MobileAddPurchasePageState();
}

class _MobileAddPurchasePageState extends ConsumerState<MobileAddPurchasePage> {
  static const MobileDocumentVisibility _visibility =
      MobileDocumentVisibility.purchaseBill;
  late final TextEditingController _descriptionController;
  late final TextEditingController _termsTextController;
  late final TextEditingController _eWayController;
  late final TextEditingController _billingNameController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _termsTextController = TextEditingController();
    _eWayController = TextEditingController();
    _billingNameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = ref.read(addPurchaseFormProvider(billId: widget.billId));
      _descriptionController.text = form.description;
      _termsTextController.text = form.termsNotes;
      _eWayController.text = form.eWayBillNo;
      _billingNameController.text = form.billingName;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _termsTextController.dispose();
    _eWayController.dispose();
    _billingNameController.dispose();
    super.dispose();
  }

  AddPurchaseFormState _form() =>
      ref.watch(addPurchaseFormProvider(billId: widget.billId));

  AddPurchaseForm _notifier() =>
      ref.read(addPurchaseFormProvider(billId: widget.billId).notifier);

  Future<bool> _handleClose() async {
    if (_form().isSaving) return false;
    return showCloseFormDialog(context, title: 'Close Purchase');
  }

  Future<void> _pickParty() async {
    final party = await pickMobileDocumentParty(
      context,
      typeFilter: PartyTypeFilter.supplier,
      title: 'Select supplier',
    );
    if (party != null) {
      _notifier().updateParty(party.name, partyId: party.id);
      _billingNameController.text = ref
          .read(addPurchaseFormProvider(billId: widget.billId))
          .billingName;
    }
  }

  Future<void> _addLine() async {
    final result = await pickMobileDocumentItem(context);
    if (result == null) return;
    final notifier = _notifier();
    final items = _form().items;
    final lastEmpty = items.isNotEmpty && items.last.itemName.trim().isEmpty;
    if (!lastEmpty) notifier.addLineItem();
    final targetIndex = _form().items.length - 1;
    notifier.updateLineItem(
      targetIndex,
      PurchaseLineItem(
        id: _form().items[targetIndex].id,
        itemId: result.item.id,
        itemName: result.item.name,
        qty: result.quantity,
        pricePerUnit: result.pricePerUnit,
        unit: result.item.baseUnitShortName ?? 'NONE',
        taxPercent: result.item.defaultTaxRate ?? 0,
      ),
    );
  }

  Future<void> _applyCatalogFromBarcode(SaleItemOption catalog) async {
    final form = _form();
    final notifier = _notifier();
    var index = form.items.lastIndexWhere(isEmptyPurchaseLineDraft);
    if (index < 0) {
      notifier.addLineItem();
      index = _form().items.length - 1;
    }
    notifier.selectCatalogItem(index, catalog);
  }

  Future<void> _scanBarcodeCamera() async {
    final code = await showMobileBarcodeScanner(context);
    if (code == null || !mounted) return;
    await handleDocumentBarcodeScanCode(
      code,
      context: context,
      ref: ref,
      handler: BarcodeScanHandler(
        debounce: BarcodeScanHandler.cameraDebounce,
      ),
      onCatalogItem: _applyCatalogFromBarcode,
    );
  }

  Future<void> _save({required bool saveAndNew}) async {
    final error = await _notifier().saveBill();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final form = _form();
    final docId = form.documentId;
    if (docId != null && docId.isNotEmpty) {
      await DocumentPrintActions.print(
        context,
        ref,
        PrintRequest.purchaseBill(docId),
      );
      if (!mounted) return;
    }
    if (saveAndNew) {
      ref.invalidate(addPurchaseFormProvider(billId: widget.billId));
      _descriptionController.clear();
      _termsTextController.clear();
      _eWayController.clear();
      _billingNameController.clear();
      return;
    }
    await leaveTransactionFormPage(
      context: context,
      isDirty: false,
      isSaving: false,
      listRoute: AppRoutes.purchaseBills,
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = _form();
    final notifier = _notifier();
    final confirmed = form.items
        .where((item) => item.itemName.trim().isNotEmpty)
        .toList();
    final partySelected = form.party.trim().isNotEmpty;
    final visibility = MobileDocumentVisibility(
      showDocumentNumber: _visibility.showDocumentNumber,
      showDate: _visibility.showDate,
      showTime: _visibility.showTime,
      showDueDate: _visibility.showDueDate,
      showPaymentTerms: _visibility.showPaymentTerms,
      showStateOfSupply: _visibility.showStateOfSupply,
      showGodown: _visibility.showGodown,
      showEWayBill: _visibility.showEWayBill,
      showParty: _visibility.showParty,
      showBillingName: partySelected && _visibility.showBillingName,
      showPhone: _visibility.showPhone,
      showBillingAddress: _visibility.showBillingAddress,
      showShippingAddress: _visibility.showShippingAddress,
      showGstin: _visibility.showGstin,
      showEmail: _visibility.showEmail,
      showItems: _visibility.showItems,
      showBarcodeScan: isBarcodeScanningEnabled(ref),
      showTotals: _visibility.showTotals,
      showRoundOff: _visibility.showRoundOff,
      showPaymentSection: _visibility.showPaymentSection,
      showReceivedAmount: _visibility.showReceivedAmount,
      showDescription: _visibility.showDescription,
      showTerms: _visibility.showTerms,
      showAttachments: _visibility.showAttachments,
      showSaleTypeToggle: _visibility.showSaleTypeToggle,
      showSettings: _visibility.showSettings,
      showSaveAndNew: _visibility.showSaveAndNew,
    );

    return DocumentBarcodeKeyboardHost(
      onCatalogItem: _applyCatalogFromBarcode,
      child: MobileDocumentFormScaffold(
        title: widget.billId != null ? 'Edit Purchase' : 'Purchase',
        visibility: visibility,
        isLoading: form.isLoading,
        isSaving: form.isSaving,
        onClose: _handleClose,
        onSave: () => unawaited(_save(saveAndNew: false)),
        onSaveAndNew: () => unawaited(_save(saveAndNew: true)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (form.saveError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  form.saveError!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            MobileDocumentHeader(
              visibility: visibility,
              documentNumberLabel: 'Bill No.',
              documentNumberValue: resolveDocumentNumberDisplay(
                documentId: form.documentId,
                currentNumber: form.billNumber,
                preview: watchDocumentNumberPreview(
                  ref,
                  PurchaseConstants.purchaseBillSeries,
                ),
              ),
              documentNumberIsPlaceholder: false,
              dateValue: formatSaleSingleDate(form.billDate),
              dateIsPlaceholder: form.billDate == null,
              onDateTap: () async {
                final date = await showMobileDatePicker(
                  context,
                  initialDate: form.billDate,
                );
                if (date != null) notifier.updateBillDate(date);
              },
              timeValue: formatSaleTime(form.billTime),
              timeIsPlaceholder: form.billTime == null,
              onTimeTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: form.billTime ?? TimeOfDay.now(),
                );
                if (picked != null) notifier.updateBillTime(picked);
              },
              paymentTermsValue: form.paymentTerms,
              onPaymentTermsTap: () async {
                final selected = await showMobileOptionSheet<String>(
                  context: context,
                  title: 'Payment Terms',
                  selected: form.paymentTerms,
                  options: [
                    for (final term in SaleDropdownOptions.paymentTerms)
                      MobileOption(value: term, label: term),
                  ],
                );
                if (selected != null) notifier.updatePaymentTerms(selected);
              },
              dueDateValue: form.dueDate != null
                  ? formatSaleSingleDate(form.dueDate)
                  : null,
              dueDateIsPlaceholder: form.dueDate == null,
              onDueDateTap: () async {
                final date = await showMobileDatePicker(
                  context,
                  initialDate: form.dueDate ?? form.billDate,
                );
                if (date != null) notifier.updateDueDate(date);
              },
              stateOfSupplyValue: form.stateOfSupply,
              onStateOfSupplyTap: () async {
                final selected = await showMobileOptionSheet<String>(
                  context: context,
                  title: 'State of supply',
                  selected: form.stateOfSupply,
                  options: [
                    for (final state in SaleDropdownOptions.indianStates)
                      MobileOption(value: state, label: state),
                  ],
                );
                if (selected != null) notifier.updateStateOfSupply(selected);
              },
              godownValue: form.godown,
              onGodownTap: () async {
                final godowns = ref.read(inventoryGodownsProvider).value ?? [];
                final options = godowns.isNotEmpty
                    ? godowns.map((g) => g.name).toList()
                    : SaleDropdownOptions.godowns;
                final selected = await showMobileOptionSheet<String>(
                  context: context,
                  title: 'Godown',
                  selected: form.godown,
                  options: [
                    for (final name in options)
                      MobileOption(value: name, label: name),
                  ],
                );
                if (selected == null) return;
                final match = godowns
                    .where((g) => g.name == selected)
                    .firstOrNull;
                notifier.updateGodown(selected, godownId: match?.id);
              },
              eWayBillController: _eWayController,
              onEWayBillChanged: notifier.updateEWayBillNo,
            ),
            const SizedBox(height: AppSpacing.lg),
            MobileDocumentPartySection(
              visibility: visibility,
              useInlinePartySearch: false,
              partyLabel: 'Supplier',
              partyValue: form.party,
              partyHasError: form.partyHasError,
              partyTypeFilter: PartyTypeFilter.supplier,
              onPickParty: () => unawaited(_pickParty()),
              billingNameController: _billingNameController,
              onBillingNameChanged: notifier.updateBillingName,
            ),
            const SizedBox(height: AppSpacing.xl),
            MobileDocumentItemsSection(
              visibility: visibility,
              lines: [
                for (final item in confirmed)
                  MobileDocumentLineDisplay(
                    name: item.itemName,
                    qtyLabel:
                        '${item.qty} × ₹${MobileDocumentItemsSection.formatAmount(item.pricePerUnit)}',
                    amountLabel: MobileDocumentItemsSection.formatAmount(
                      item.amount,
                    ),
                  ),
              ],
              onAddItems: () => unawaited(_addLine()),
              onScan: visibility.showBarcodeScan
                  ? () => unawaited(_scanBarcodeCamera())
                  : null,
              onRemoveLine: (i) {
                final index = form.items.indexWhere(
                  (item) => item.id == confirmed[i].id,
                );
                if (index >= 0) notifier.removeLineItem(index);
              },
              onLineTap: (i) async {
                final item = confirmed[i];
                final index = form.items.indexWhere((e) => e.id == item.id);
                if (index < 0) return;
                final draft = await showMobileDocumentLineEditSheet(
                  context: context,
                  itemName: item.itemName,
                  fields: MobileDocumentLineEditFields.purchase,
                  initial: MobileDocumentLineEditDraft(
                    qty: item.qty,
                    unit: item.unit,
                    pricePerUnit: item.pricePerUnit,
                    taxPercent: item.taxPercent,
                    description: item.description,
                  ),
                );
                if (draft == null || !mounted) return;
                notifier.updateLineItem(
                  index,
                  item.copyWith(
                    qty: draft.qty,
                    unit: draft.unit,
                    pricePerUnit: draft.pricePerUnit,
                    taxPercent: draft.taxPercent,
                    description: draft.description,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            MobileDocumentTotalsSection(
              visibility: visibility,
              totalAmount: form.grandTotal,
              subtotal: form.subtotal,
              taxAmount: form.totalTax,
              roundOff: form.roundOff,
              onRoundOffChanged: (v) => notifier.toggleRoundOff(value: v),
              paymentType: form.paymentType,
              paymentAmount: form.paymentAmount,
              onPaymentTypeTap: () async {
                final picked = await pickMobilePaymentType(
                  context,
                  selected: form.paymentType,
                );
                if (picked != null) notifier.updatePaymentType(picked);
              },
              onPaymentAmountChanged: notifier.updatePaymentAmount,
              onAddPaymentType: notifier.addPaymentType,
            ),
            const SizedBox(height: AppSpacing.xl),
            MobileDocumentNotesAttachmentsSection(
              visibility: visibility,
              descriptionController: _descriptionController,
              onDescriptionChanged: notifier.updateDescription,
              termsTitle: form.termsTitle,
              termsTextController: _termsTextController,
              onTermsTitleTap: () async {
                final picked = await pickMobileTermsTitle(
                  context,
                  selected: form.termsTitle,
                );
                if (picked != null) notifier.updateTermsTitle(picked);
              },
              onTermsTextChanged: notifier.updateTermsNotes,
              images: form.attachedImages,
              documents: form.attachedDocuments,
              onAddImage: () => unawaited(
                transactionAddImage(
                  context: context,
                  ref: ref,
                  entityType: DocumentAttachmentEntityType.purchase.apiValue,
                  entityId: form.documentId,
                  onAdded: notifier.addImage,
                ),
              ),
              onAddDocument: () => unawaited(
                transactionAddDocument(
                  context: context,
                  ref: ref,
                  entityType: DocumentAttachmentEntityType.purchase.apiValue,
                  entityId: form.documentId,
                  onAdded: notifier.addDocument,
                ),
              ),
              onRemoveImage: notifier.removeImage,
              onRemoveDocument: notifier.removeDocument,
            ),
          ],
        ),
      ),
    );
  }
}
