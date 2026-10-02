import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/hidden_ledger/models/short_payment_handling.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/hidden_ledger_recovery_dialog.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/hidden_ledger_summary_tile.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/short_payment_handling_dialog.dart';
import 'package:billing_baba/features/inventory/application/barcode_scan_handler.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_barcode_scanner_screen.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/sale_invoice_print_actions.dart';
import 'package:billing_baba/features/sales/application/add_sale_form_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_settings_panel.dart';
import 'package:billing_baba/features/sales/utils/sale_line_item_catalog.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/navigation/transaction_detail_navigation.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/document_barcode_keyboard_host.dart';
import 'package:billing_baba/shared/widgets/document_barcode_scan.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MobileAddSalePage extends ConsumerStatefulWidget {
  const MobileAddSalePage({
    super.key,
    this.invoiceId,
    this.duplicateFromId,
    this.attachOrderIds,
    this.initialPartyId,
    this.initialPartyName,
    this.readOnly = false,
  });

  final String? invoiceId;
  final String? duplicateFromId;
  final List<String>? attachOrderIds;
  final String? initialPartyId;
  final String? initialPartyName;
  final bool readOnly;

  @override
  ConsumerState<MobileAddSalePage> createState() => _MobileAddSalePageState();
}

class _MobileAddSalePageState extends ConsumerState<MobileAddSalePage> {
  static const MobileDocumentVisibility _visibility =
      MobileDocumentVisibility.saleInvoice;

  var _initialized = false;
  late final TextEditingController _customerController;
  late final TextEditingController _billingNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _billingAddressController;
  late final TextEditingController _shippingAddressController;
  late final TextEditingController _gstinController;
  late final TextEditingController _emailController;
  late final TextEditingController _eWayController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _termsTextController;

  late final String _duplicateSessionKey =
      'duplicate_${widget.duplicateFromId}';
  late final String _attachSessionKey =
      'attach_${widget.attachOrderIds?.join('_') ?? ''}';

  String get _sessionKey {
    if (widget.attachOrderIds != null && widget.attachOrderIds!.isNotEmpty) {
      return _attachSessionKey;
    }
    if (widget.duplicateFromId != null) return _duplicateSessionKey;
    if (widget.invoiceId != null) return widget.invoiceId!;
    final partyId = widget.initialPartyId?.trim();
    if (partyId != null && partyId.isNotEmpty) return 'party_$partyId';
    return 'default';
  }

  bool get _isEditing => widget.invoiceId != null;

  @override
  void initState() {
    super.initState();
    _customerController = TextEditingController();
    _billingNameController = TextEditingController();
    _phoneController = TextEditingController();
    _billingAddressController = TextEditingController();
    _shippingAddressController = TextEditingController();
    _gstinController = TextEditingController();
    _emailController = TextEditingController();
    _eWayController = TextEditingController();
    _descriptionController = TextEditingController();
    _termsTextController = TextEditingController();

    if (widget.invoiceId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeEditForm(),
      );
    } else if (widget.attachOrderIds != null &&
        widget.attachOrderIds!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeAttachForm(),
      );
    } else if (widget.duplicateFromId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeDuplicateForm(),
      );
    } else {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(
          addSaleFormProvider(sessionKey: _sessionKey).notifier,
        );
        if (!widget.readOnly) {
          notifier.toggleSaleType(SaleType.credit);
        }
        final partyId = widget.initialPartyId?.trim();
        final partyName = widget.initialPartyName?.trim();
        if (partyId != null &&
            partyId.isNotEmpty &&
            partyName != null &&
            partyName.isNotEmpty) {
          notifier.updateParty(partyId: partyId, partyName: partyName);
        }
        _syncControllersFromForm();
      });
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _billingNameController.dispose();
    _phoneController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    _gstinController.dispose();
    _emailController.dispose();
    _eWayController.dispose();
    _descriptionController.dispose();
    _termsTextController.dispose();
    super.dispose();
  }

  Future<void> _initializeEditForm() async {
    await ref
        .read(addSaleFormProvider(sessionKey: widget.invoiceId!).notifier)
        .loadDocument(widget.invoiceId!);
    if (mounted) {
      setState(() => _initialized = true);
      _syncControllersFromForm();
    }
  }

  Future<void> _initializeAttachForm() async {
    await ref
        .read(addSaleFormProvider(sessionKey: _attachSessionKey).notifier)
        .attachSaleOrders(widget.attachOrderIds!);
    if (mounted) {
      setState(() => _initialized = true);
      _syncControllersFromForm();
    }
  }

  Future<void> _initializeDuplicateForm() async {
    await ref
        .read(addSaleFormProvider(sessionKey: _duplicateSessionKey).notifier)
        .duplicateDocument(widget.duplicateFromId!);
    if (mounted) {
      setState(() => _initialized = true);
      _syncControllersFromForm();
    }
  }

  void _syncControllersFromForm() {
    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    _customerController.text = form.billingName;
    _billingNameController.text = form.businessName;
    _phoneController.text = form.phone;
    _billingAddressController.text = form.billingAddress;
    _shippingAddressController.text = form.shippingAddress;
    _gstinController.text = form.gstin;
    _emailController.text = form.email;
    _eWayController.text = form.eWayBillNo;
    _descriptionController.text = form.description;
    _termsTextController.text = form.termsText;
  }

  void _resetSaleFormState() {
    ref.invalidate(addSaleFormProvider(sessionKey: _sessionKey));
    ref.invalidate(addSaleSubtotalProvider(sessionKey: _sessionKey));
    ref.invalidate(addSaleTotalTaxProvider(sessionKey: _sessionKey));
    ref.invalidate(addSaleGrandTotalProvider(sessionKey: _sessionKey));
  }

  Future<bool> _handleClose() async {
    if (!widget.readOnly) {
      final confirmed = await showCloseFormDialog(
        context,
        title: 'Close Sale',
      );
      if (!confirmed || !mounted) return false;
    }
    _resetSaleFormState();
    return true;
  }

  Future<void> _pickInvoiceDate() async {
    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    final picked = await showDatePicker(
      context: context,
      initialDate: form.invoiceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    ref
        .read(addSaleFormProvider(sessionKey: _sessionKey).notifier)
        .updateInvoiceDate(picked);
  }

  Future<void> _pickDueDate() async {
    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    final picked = await showDatePicker(
      context: context,
      initialDate: form.dueDate ?? form.invoiceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    ref
        .read(addSaleFormProvider(sessionKey: _sessionKey).notifier)
        .updateDueDate(picked);
  }

  Future<void> _pickInvoiceTime() async {
    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    final picked = await showTimePicker(
      context: context,
      initialTime: form.invoiceTime ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    ref
        .read(addSaleFormProvider(sessionKey: _sessionKey).notifier)
        .updateInvoiceTime(picked);
  }

  Future<void> _pickPaymentTerms() async {
    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    final selected = await showMobileOptionSheet<String>(
      context: context,
      title: 'Payment Terms',
      selected: form.paymentTerms,
      options: [
        for (final term in SaleDropdownOptions.paymentTerms)
          MobileOption(value: term, label: term),
      ],
    );
    if (selected == null || !mounted) return;
    ref
        .read(addSaleFormProvider(sessionKey: _sessionKey).notifier)
        .updatePaymentTerms(selected);
  }

  Future<void> _pickStateOfSupply() async {
    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    final selected = await showMobileOptionSheet<String>(
      context: context,
      title: 'State of supply',
      selected: form.stateOfSupply,
      options: [
        for (final state in SaleDropdownOptions.indianStates)
          MobileOption(value: state, label: state),
      ],
    );
    if (selected == null || !mounted) return;
    ref
        .read(addSaleFormProvider(sessionKey: _sessionKey).notifier)
        .updateStateOfSupply(selected);
  }

  Future<void> _pickGodown() async {
    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    final godowns = ref.read(inventoryGodownsProvider).value ?? [];
    final options = godowns.isNotEmpty
        ? godowns.map((g) => g.name).toList()
        : SaleDropdownOptions.godowns;
    final selected = await showMobileOptionSheet<String>(
      context: context,
      title: 'Godown',
      selected: form.godown,
      options: [
        for (final name in options) MobileOption(value: name, label: name),
      ],
    );
    if (selected == null || !mounted) return;
    final match = godowns.where((g) => g.name == selected).firstOrNull;
    ref
        .read(addSaleFormProvider(sessionKey: _sessionKey).notifier)
        .updateGodown(selected, godownId: match?.id);
  }

  Future<void> _addLine() async {
    final result = await pickMobileDocumentItem(context);
    if (result == null || !mounted) return;
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: _sessionKey).notifier,
    );
    final items = ref.read(addSaleFormProvider(sessionKey: _sessionKey)).items;
    final lastEmpty = items.isNotEmpty && items.last.itemName.trim().isEmpty;
    if (!lastEmpty) notifier.addLineItem();
    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    final index = form.items.length - 1;
    notifier.updateLineItem(
      index,
      SaleLineItem(
        id: form.items[index].id,
        itemId: result.item.id,
        itemName: result.item.name,
        qty: result.quantity,
        pricePerUnit: result.pricePerUnit,
        unit: result.item.baseUnitShortName ?? 'NONE',
        taxPercent: result.item.defaultTaxRate ?? 0,
        mrp: result.item.mrp ?? 0,
        isConfirmed: true,
      ),
    );
  }

  Future<void> _applyCatalogFromBarcode(
    SaleItemOption catalog,
  ) async {
    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: _sessionKey).notifier,
    );
    var index = form.items.lastIndexWhere(isEmptySaleLineDraft);
    if (index < 0) {
      notifier.addLineItem();
      index =
          ref.read(addSaleFormProvider(sessionKey: _sessionKey)).items.length -
          1;
    }
    await notifier.selectCatalogItem(index, catalog);
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

  Future<({String? shortPaymentHandling, double? shortfallAmount})>
  _resolveShortPaymentHandling() async {
    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    if (!form.hasShortPayment) {
      return (shortPaymentHandling: null, shortfallAmount: null);
    }

    final paidAmount = form.displayReceivedAmount;
    final allowHiddenLedger = ref
        .read(permissionServiceProvider)
        .canViewHiddenLedger;

    final handling = await showShortPaymentHandlingDialog(
      context,
      paidAmount: paidAmount,
      targetAmount: form.invoiceTotal,
      allowHiddenLedger: allowHiddenLedger,
    );
    if (handling == null) {
      return (shortPaymentHandling: null, shortfallAmount: null);
    }

    final shortfall = (form.invoiceTotal - paidAmount)
        .clamp(0, double.infinity)
        .toDouble();
    return (
      shortPaymentHandling: handling.apiValue,
      shortfallAmount: handling == ShortPaymentHandling.hiddenLedger
          ? shortfall
          : null,
    );
  }

  Future<double?> _resolveHiddenLedgerRecovery() async {
    if (!ref.read(permissionServiceProvider).canViewHiddenLedger) return 0;

    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    if (!form.hasRecoverableMarkup) return 0;

    final result = await showHiddenLedgerRecoveryDialog(
      context,
      hiddenBalance: form.hiddenLedgerBalance,
      markupAmount: form.markupAmount,
    );
    if (result == null) return null;
    if (result.choice == HiddenLedgerRecoveryChoice.ignore) return 0;
    return result.amount;
  }

  Future<void> _save({required bool saveAndNew}) async {
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: _sessionKey).notifier,
    );

    final shortPayment = await _resolveShortPaymentHandling();
    if (!mounted) return;
    final latestForm = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    if (latestForm.hasShortPayment &&
        shortPayment.shortPaymentHandling == null) {
      return;
    }

    final recoveryAmount = await _resolveHiddenLedgerRecovery();
    if (!mounted) return;
    if (latestForm.hasRecoverableMarkup && recoveryAmount == null) {
      return;
    }

    final result = await notifier.saveInvoice(
      shortPaymentHandling: shortPayment.shortPaymentHandling,
      shortfallAmount: shortPayment.shortfallAmount,
      hiddenLedgerRecoveryAmount: recoveryAmount ?? 0,
    );
    if (!mounted) return;

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }

    final saved = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    final docId = saved.documentId;
    if (docId != null && docId.isNotEmpty) {
      await SaleInvoicePrintActions.print(
        context,
        ref,
        docId,
        filename: SaleInvoicePrintActions.filenameFor(saved.invoiceNumber),
      );
      if (!mounted) return;
    }

    if (saveAndNew) {
      _resetSaleFormState();
      _customerController.clear();
      _billingNameController.clear();
      _phoneController.clear();
      _billingAddressController.clear();
      _shippingAddressController.clear();
      _gstinController.clear();
      _emailController.clear();
      _eWayController.clear();
      _descriptionController.clear();
      _termsTextController.clear();
      ref.read(addSaleFormProvider().notifier).toggleSaleType(SaleType.credit);
      _syncControllersFromForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale saved. Ready for a new sale.')),
      );
      return;
    }

    _resetSaleFormState();
    returnToTransactionList(context, AppRoutes.saleInvoices);
  }

  void _showMoreOptions() {
    final form = ref.read(addSaleFormProvider(sessionKey: _sessionKey));
    unawaited(
      showMobileMoreActionsSheet(
        context: context,
        title: 'More Options',
        actions: [
          if (form.documentId != null && form.documentId!.isNotEmpty)
            MobileSheetAction(
              label: 'Share as PDF',
              onTap: () {
                unawaited(
                  SaleInvoicePrintActions.share(
                    context,
                    ref,
                    form.documentId!,
                    filename: SaleInvoicePrintActions.filenameFor(
                      form.invoiceNumber,
                    ),
                  ),
                );
              },
            ),
          if (_isEditing)
            MobileSheetAction(
              label: 'Duplicate',
              onTap: () {
                context.push(
                  '${AppRoutes.duplicateSale}/${widget.invoiceId}',
                );
              },
            ),
        ],
      ),
    );
  }

  String _invoiceNumberLabel(AddSaleFormState form) {
    if (form.invoiceNumberMode == InvoiceNumberMode.auto) {
      return form.invoiceNumber == 'Auto' ? 'Auto' : form.invoiceNumber;
    }
    return form.invoiceNumber.isEmpty ? 'Enter number' : form.invoiceNumber;
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addSaleFormProvider(sessionKey: _sessionKey));
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: _sessionKey).notifier,
    );
    final grandTotal = ref.watch(
      addSaleGrandTotalProvider(sessionKey: _sessionKey),
    );
    final subtotal = ref.watch(
      addSaleSubtotalProvider(sessionKey: _sessionKey),
    );
    final tax = ref.watch(addSaleTotalTaxProvider(sessionKey: _sessionKey));
    final isCredit = form.saleType == SaleType.credit;
    final title = widget.readOnly
        ? 'View Sale'
        : (_isEditing ? 'Edit Sale' : 'Sale');
    final canViewHiddenLedger = ref
        .watch(permissionServiceProvider)
        .canViewHiddenLedger;
    final partyId = form.partyId;
    final showHiddenLedgerBanner =
        canViewHiddenLedger && partyId != null && partyId.isNotEmpty;

    final confirmedLines = <({int index, SaleLineItem item})>[];
    for (var i = 0; i < form.items.length; i++) {
      final item = form.items[i];
      if (item.itemName.trim().isNotEmpty) {
        confirmedLines.add((index: i, item: item));
      }
    }

    final visibility = MobileDocumentVisibility(
      showDocumentNumber: _visibility.showDocumentNumber,
      showDate: _visibility.showDate,
      showTime: _visibility.showTime,
      showDueDate: isCredit && _visibility.showDueDate,
      showPaymentTerms: isCredit && _visibility.showPaymentTerms,
      showStateOfSupply: _visibility.showStateOfSupply,
      showGodown: _visibility.showGodown,
      showEWayBill: _visibility.showEWayBill,
      showParty: _visibility.showParty,
      showBillingName: _visibility.showBillingName,
      showPhone: _visibility.showPhone,
      showBillingAddress: _visibility.showBillingAddress,
      showShippingAddress: _visibility.showShippingAddress,
      showGstin: _visibility.showGstin,
      showEmail: _visibility.showEmail,
      showItems: _visibility.showItems,
      showBarcodeScan: !widget.readOnly && isBarcodeScanningEnabled(ref),
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
      enabled: !widget.readOnly,
      onCatalogItem: _applyCatalogFromBarcode,
      child: MobileDocumentFormScaffold(
        title: title,
        visibility: visibility,
        isLoading:
            !_initialized || (widget.invoiceId != null && form.isLoading),
        isSaving: form.isSaving,
        readOnly: widget.readOnly,
        onClose: _handleClose,
        onSave: () => unawaited(_save(saveAndNew: false)),
        onSaveAndNew: () => unawaited(_save(saveAndNew: true)),
        onMore: _showMoreOptions,
        leadingToggle: (!widget.readOnly && visibility.showSaleTypeToggle)
            ? MobileSaleTypeToggle(
                saleType: form.saleType,
                onChanged: notifier.toggleSaleType,
              )
            : null,
        appBarActions: [
          if (visibility.showSettings && !widget.readOnly)
            MobileIconActionButton(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onPressed: () => showMobileSaleSettingsPanel(
                context: context,
                ref: ref,
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MobileDocumentHeader(
              visibility: visibility,
              documentNumberValue: _invoiceNumberLabel(form),
              documentNumberIsPlaceholder:
                  form.invoiceNumberMode == InvoiceNumberMode.auto &&
                  form.invoiceNumber == 'Auto',
              dateValue: formatSaleSingleDate(form.invoiceDate),
              dateIsPlaceholder: form.invoiceDate == null,
              onDateTap: _pickInvoiceDate,
              timeValue: formatSaleTime(form.invoiceTime),
              timeIsPlaceholder: form.invoiceTime == null,
              onTimeTap: _pickInvoiceTime,
              paymentTermsValue: form.paymentTerms,
              onPaymentTermsTap: _pickPaymentTerms,
              dueDateValue: form.dueDate != null
                  ? formatSaleSingleDate(form.dueDate)
                  : null,
              dueDateIsPlaceholder: form.dueDate == null,
              onDueDateTap: _pickDueDate,
              stateOfSupplyValue: form.stateOfSupply,
              onStateOfSupplyTap: _pickStateOfSupply,
              godownValue: form.godown,
              onGodownTap: _pickGodown,
              eWayBillController: _eWayController,
              onEWayBillChanged: notifier.updateEWayBillNo,
            ),
            const SizedBox(height: AppSpacing.lg),
            MobileDocumentPartySection(
              visibility: visibility,
              partyController: _customerController,
              selectedPartyId: form.partyId,
              partyHasError: form.partyHasError,
              onSearchChanged: notifier.updateBillingName,
              onPartySelected: (party) {
                notifier.applyPartyDetails(party);
                _syncControllersFromForm();
              },
              billingNameController: _billingNameController,
              onBillingNameChanged: notifier.updateBusinessName,
              phoneController: _phoneController,
              phoneHasError: form.phoneHasError,
              phoneErrorText: form.phoneErrorMessage,
              onPhoneChanged: notifier.updatePhone,
              billingAddressController: _billingAddressController,
              onBillingAddressChanged: (value) =>
                  notifier.updateAddresses(billing: value),
              shippingAddressController: _shippingAddressController,
              onShippingAddressChanged: (value) =>
                  notifier.updateAddresses(shipping: value),
              gstinController: _gstinController,
              onGstinChanged: notifier.updateGstin,
              emailController: _emailController,
              onEmailChanged: notifier.updateEmail,
            ),
            if (showHiddenLedgerBanner) ...[
              const SizedBox(height: AppSpacing.lg),
              HiddenLedgerSummaryTile(partyId: partyId),
            ],
            const SizedBox(height: AppSpacing.xl),
            MobileDocumentItemsSection(
              visibility: visibility,
              lines: [
                for (final entry in confirmedLines)
                  MobileDocumentLineDisplay(
                    name: entry.item.itemName,
                    qtyLabel:
                        '${entry.item.qty} ${entry.item.unit} × ₹${MobileDocumentItemsSection.formatAmount(entry.item.pricePerUnit)}',
                    amountLabel: MobileDocumentItemsSection.formatAmount(
                      entry.item.amount,
                    ),
                  ),
              ],
              onAddItems: () => unawaited(_addLine()),
              onScan: visibility.showBarcodeScan
                  ? () => unawaited(_scanBarcodeCamera())
                  : null,
              onRemoveLine: (displayIndex) {
                notifier.removeLineItem(confirmedLines[displayIndex].index);
              },
              onLineTap: (displayIndex) async {
                final entry = confirmedLines[displayIndex];
                final draft = await showMobileDocumentLineEditSheet(
                  context: context,
                  itemName: entry.item.itemName,
                  fields: MobileDocumentLineEditFields.sale,
                  initial: MobileDocumentLineEditDraft(
                    qty: entry.item.qty,
                    unit: entry.item.unit,
                    pricePerUnit: entry.item.pricePerUnit,
                    discountPercent: entry.item.discountPercent,
                    taxPercent: entry.item.taxPercent,
                    serialNo: entry.item.serialNo,
                    batchNo: entry.item.batchNo,
                    mrp: entry.item.mrp,
                    description: entry.item.description,
                  ),
                );
                if (draft == null || !mounted) return;
                notifier.updateLineItem(
                  entry.index,
                  entry.item.copyWith(
                    qty: draft.qty,
                    unit: draft.unit,
                    pricePerUnit: draft.pricePerUnit,
                    discountPercent: draft.discountPercent,
                    taxPercent: draft.taxPercent,
                    serialNo: draft.serialNo,
                    batchNo: draft.batchNo,
                    mrp: draft.mrp,
                    description: draft.description,
                    priceManuallyOverridden: true,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            MobileDocumentTotalsSection(
              visibility: visibility,
              totalAmount: grandTotal,
              subtotal: subtotal,
              taxAmount: tax,
              roundOff: form.roundOff,
              onRoundOffChanged: (value) =>
                  notifier.toggleRoundOff(value: value),
              receivedAmount: form.receivedAmount,
              onReceivedAmountChanged: notifier.updateReceivedAmount,
              payments: [
                for (final payment in form.payments)
                  (type: payment.type, amount: payment.amount),
              ],
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
              onTermsTextChanged: notifier.updateTermsText,
              images: form.attachedImages,
              documents: form.attachedDocuments,
              onAddImage: () => unawaited(
                transactionAddImage(
                  context: context,
                  ref: ref,
                  entityType: DocumentAttachmentEntityType.sale.apiValue,
                  entityId: form.documentId,
                  onAdded: notifier.addImage,
                ),
              ),
              onAddDocument: () => unawaited(
                transactionAddDocument(
                  context: context,
                  ref: ref,
                  entityType: DocumentAttachmentEntityType.sale.apiValue,
                  entityId: form.documentId,
                  onAdded: notifier.addDocument,
                ),
              ),
              onRemoveImage: notifier.removeImage,
              onRemoveDocument: notifier.removeDocument,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
