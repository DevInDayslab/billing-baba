import 'dart:async';

import 'package:billing_baba/shared/navigation/transaction_detail_navigation.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:billing_baba/features/sales/application/add_sale_form_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_party_picker_field.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 2,
  );

  var _initialized = false;
  late final TextEditingController _customerController;
  late final TextEditingController _billingNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _poNumberController;

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
    _poNumberController = TextEditingController();

    if (widget.invoiceId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initializeEditForm());
    } else if (widget.attachOrderIds != null &&
        widget.attachOrderIds!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initializeAttachForm());
    } else if (widget.duplicateFromId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initializeDuplicateForm());
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
    _poNumberController.dispose();
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
        .read(
          addSaleFormProvider(sessionKey: _duplicateSessionKey).notifier,
        )
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
  }

  void _resetSaleFormState() {
    ref.invalidate(addSaleFormProvider(sessionKey: _sessionKey));
    ref.invalidate(addSaleSubtotalProvider(sessionKey: _sessionKey));
    ref.invalidate(addSaleTotalTaxProvider(sessionKey: _sessionKey));
    ref.invalidate(addSaleGrandTotalProvider(sessionKey: _sessionKey));
  }

  Future<void> _handleClose() async {
    if (!widget.readOnly) {
      final confirmed = await showCloseFormDialog(
        context,
        title: 'Close Sale',
      );
      if (!confirmed || !mounted) return;
    }
    _resetSaleFormState();
    returnToTransactionList(context, AppRoutes.saleInvoices);
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

  Future<void> _save({required bool saveAndNew}) async {
    final notifier =
        ref.read(addSaleFormProvider(sessionKey: _sessionKey).notifier);
    final result = await notifier.saveInvoice();
    if (!mounted) return;

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }

    if (saveAndNew) {
      _resetSaleFormState();
      _customerController.clear();
      _billingNameController.clear();
      _phoneController.clear();
      _poNumberController.clear();
      ref
          .read(addSaleFormProvider().notifier)
          .toggleSaleType(SaleType.credit);
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
    unawaited(
      showMobileMoreActionsSheet(
        context: context,
        title: 'More Options',
        actions: [
          MobileSheetAction(
            label: 'Duplicate',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Duplicate coming soon')),
              );
            },
          ),
          MobileSheetAction(
            label: 'Share as PDF',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share as PDF coming soon')),
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

  String _totalLabel(double grandTotal) {
    if (grandTotal <= 0) return '—';
    return _currencyFormat.format(grandTotal).trim();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addSaleFormProvider(sessionKey: _sessionKey));
    final notifier =
        ref.read(addSaleFormProvider(sessionKey: _sessionKey).notifier);
    final grandTotal = ref.watch(
      addSaleGrandTotalProvider(sessionKey: _sessionKey),
    );
    final isCredit = form.saleType == SaleType.credit;
    final title = widget.readOnly
        ? 'View Sale'
        : (_isEditing ? 'Edit Sale' : 'Sale');

    if (!_initialized || (widget.invoiceId != null && form.isLoading)) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleClose();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _handleClose,
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (!widget.readOnly)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: MobileSaleTypeToggle(
                  saleType: form.saleType,
                  onChanged: notifier.toggleSaleType,
                ),
              ),
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
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: IgnorePointer(
                  ignoring: widget.readOnly,
                  child: Opacity(
                    opacity: widget.readOnly ? 0.85 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: MobileSalePickerField(
                                label: 'Invoice No.',
                                value: _invoiceNumberLabel(form),
                                isPlaceholder:
                                    form.invoiceNumberMode ==
                                        InvoiceNumberMode.auto &&
                                    form.invoiceNumber == 'Auto',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: MobileSalePickerField(
                                label: 'Date',
                                value: formatSaleSingleDate(form.invoiceDate),
                                isPlaceholder: form.invoiceDate == null,
                                onTap: _pickInvoiceDate,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: MobileSalePickerField(
                                label: 'Time',
                                value: formatSaleTime(form.invoiceTime),
                                isPlaceholder: form.invoiceTime == null,
                                onTap: _pickInvoiceTime,
                              ),
                            ),
                          ],
                        ),
                        if (isCredit) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: MobileSalePickerField(
                                  label: 'Pmt. Terms',
                                  value: form.paymentTerms,
                                  onTap: _pickPaymentTerms,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: MobileSalePickerField(
                                  label: 'Due On',
                                  value: form.dueDate != null
                                      ? formatSaleSingleDate(form.dueDate)
                                      : 'Select date',
                                  isPlaceholder: form.dueDate == null,
                                  trailingIcon: Icons.calendar_today_outlined,
                                  onTap: _pickDueDate,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        MobileSalePartyPickerField(
                          controller: _customerController,
                          selectedPartyId: form.partyId,
                          hasError: form.partyHasError,
                          onSearchChanged: notifier.updateBillingName,
                          onPartySelected: (party) {
                            notifier.applyPartyDetails(party);
                            _syncControllersFromForm();
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        MobileSaleFormField(
                          label: 'Billing Name (Optional)',
                          controller: _billingNameController,
                          hintText: 'Billing Name (Optional)',
                          onChanged: notifier.updateBusinessName,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        MobileSaleFormField(
                          label: 'Phone Number',
                          controller: _phoneController,
                          hintText: 'Phone number',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          hasError: form.phoneHasError,
                          errorText: form.phoneErrorMessage,
                          onChanged: notifier.updatePhone,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: MobileSalePickerField(
                                label: 'PO Date',
                                value: 'Select date',
                                isPlaceholder: true,
                                trailingIcon: Icons.calendar_today_outlined,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('PO date coming soon'),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: MobileSaleFormField(
                                label: 'PO Number',
                                controller: _poNumberController,
                                hintText: 'PO Number',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        MobileSaleAddItemsRow(
                          onAddItems: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Item picker coming soon'),
                              ),
                            );
                          },
                          onScan: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Barcode scanner coming soon'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        MobileSaleTotalRow(
                          amountLabel: _totalLabel(grandTotal),
                        ),
                        const SizedBox(
                          height: MobileBottomNavigation.barHeight + AppSpacing.md,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!widget.readOnly)
              MobileSaleBottomBar(
                isSaving: form.isSaving,
                onSave: () => unawaited(_save(saveAndNew: false)),
                onSaveAndNew: () => unawaited(_save(saveAndNew: true)),
                onMore: _showMoreOptions,
              ),
          ],
        ),
      ),
    );
  }
}
