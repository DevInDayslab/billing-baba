import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/pricing/application/local_item_tier_prices_provider.dart';
import 'package:billing_baba/features/purchases/application/add_purchase_form_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/utils/purchase_line_item_catalog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_line_items_list.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_party_picker_field.dart';
import 'package:billing_baba/shared/navigation/transaction_detail_navigation.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_item_picker_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileAddPurchasePage extends ConsumerStatefulWidget {
  const MobileAddPurchasePage({
    super.key,
    this.billId,
  });

  final String? billId;

  @override
  ConsumerState<MobileAddPurchasePage> createState() =>
      _MobileAddPurchasePageState();
}

class _MobileAddPurchasePageState extends ConsumerState<MobileAddPurchasePage> {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 2,
  );

  late final TextEditingController _partyController;
  late final TextEditingController _billingNameController;

  bool get _isEditing => widget.billId != null;

  @override
  void initState() {
    super.initState();
    _partyController = TextEditingController();
    _billingNameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(inventoryItemsProvider.notifier).refresh());
      _syncControllersFromForm();
    });
  }

  @override
  void dispose() {
    _partyController.dispose();
    _billingNameController.dispose();
    super.dispose();
  }

  void _syncControllersFromForm() {
    final form = ref.read(addPurchaseFormProvider(billId: widget.billId));
    _partyController.text = form.party;
    _billingNameController.text = form.billingName;
  }

  void _resetPurchaseFormState() {
    ref
      ..invalidate(addPurchaseFormProvider(billId: widget.billId))
      ..invalidate(addPurchaseGrandTotalProvider(billId: widget.billId));
  }

  Future<void> _handleClose() async {
    final form = ref.read(addPurchaseFormProvider(billId: widget.billId));
    if (form.isDirty) {
      final confirmed = await showCloseFormDialog(
        context,
        title: 'Close Purchase',
      );
      if (!confirmed || !mounted) return;
    }
    _resetPurchaseFormState();
    returnToTransactionList(context, AppRoutes.purchaseBills);
  }

  Future<void> _pickBillDate() async {
    final form = ref.read(addPurchaseFormProvider(billId: widget.billId));
    final picked = await showDatePicker(
      context: context,
      initialDate: form.billDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    ref
        .read(addPurchaseFormProvider(billId: widget.billId).notifier)
        .updateBillDate(picked);
  }

  Future<void> _pickDueDate() async {
    final form = ref.read(addPurchaseFormProvider(billId: widget.billId));
    final picked = await showDatePicker(
      context: context,
      initialDate: form.dueDate ?? form.billDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    ref
        .read(addPurchaseFormProvider(billId: widget.billId).notifier)
        .updateDueDate(picked);
  }

  Future<void> _pickBillTime() async {
    final form = ref.read(addPurchaseFormProvider(billId: widget.billId));
    final picked = await showTimePicker(
      context: context,
      initialTime: form.billTime ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    ref
        .read(addPurchaseFormProvider(billId: widget.billId).notifier)
        .updateBillTime(picked);
  }

  Future<void> _pickPaymentTerms() async {
    final form = ref.read(addPurchaseFormProvider(billId: widget.billId));
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
        .read(addPurchaseFormProvider(billId: widget.billId).notifier)
        .updatePaymentTerms(selected);
  }

  Future<void> _pickCatalogItem() async {
    final selected = await showMobileItemPickerSheet(
      context: context,
      ref: ref,
      showSalePrice: false,
    );
    if (selected == null || !mounted) return;

    try {
      await ref.read(localItemTierPricesProvider.notifier).ensureInitialized();
    } on Object {
      // Tier prices are optional — selection should still succeed offline.
    }
    if (!mounted) return;

    final notifier = ref.read(
      addPurchaseFormProvider(billId: widget.billId).notifier,
    );
    var form = ref.read(addPurchaseFormProvider(billId: widget.billId));

    if (form.items.isEmpty ||
        form.items.indexWhere(isEmptyPurchaseLineDraft) < 0) {
      notifier.addLineItem();
      form = ref.read(addPurchaseFormProvider(billId: widget.billId));
    }

    final emptyIndex = form.items.indexWhere(isEmptyPurchaseLineDraft);
    final targetIndex = emptyIndex >= 0 ? emptyIndex : form.items.length - 1;
    if (targetIndex < 0) return;

    final catalogItem = saleItemOptionFromInventory(
      selected,
      tierPrices:
          ref.read(localItemTierPricesProvider)[selected.id] ?? const {},
    );
    notifier.selectCatalogItem(targetIndex, catalogItem);
  }

  Future<void> _save({required bool saveAndNew}) async {
    final notifier = ref.read(
      addPurchaseFormProvider(billId: widget.billId).notifier,
    );
    final error = await notifier.saveBill();
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    if (saveAndNew) {
      _resetPurchaseFormState();
      _partyController.clear();
      _billingNameController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncControllersFromForm();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase saved. Ready for a new bill.'),
        ),
      );
      return;
    }

    _resetPurchaseFormState();
    returnToTransactionList(context, AppRoutes.purchaseBills);
  }

  void _showMoreOptions() {
    unawaited(
      showMobileMoreActionsSheet(
        context: context,
        title: 'More Options',
        actions: [
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

  String _billNumberLabel(AddPurchaseFormState form) {
    return form.billNumber.isEmpty ? 'Auto' : form.billNumber;
  }

  String _totalLabel(double grandTotal) {
    if (grandTotal <= 0) return '—';
    return _currencyFormat.format(grandTotal).trim();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addPurchaseFormProvider(billId: widget.billId));
    final notifier = ref.read(
      addPurchaseFormProvider(billId: widget.billId).notifier,
    );
    final grandTotal = ref.watch(
      addPurchaseGrandTotalProvider(billId: widget.billId),
    );
    final title = _isEditing ? 'Edit Purchase' : 'Purchase';

    ref.listen(addPurchaseFormProvider(billId: widget.billId), (previous, next) {
      if (previous?.party != next.party ||
          previous?.billingName != next.billingName) {
        if (_partyController.text != next.party) {
          _partyController.text = next.party;
        }
        if (_billingNameController.text != next.billingName) {
          _billingNameController.text = next.billingName;
        }
      }
    });

    if (form.isLoading) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: MobileSalePickerField(
                            label: 'Bill No.',
                            value: _billNumberLabel(form),
                            isPlaceholder:
                                form.billNumber.isEmpty ||
                                form.billNumber == 'Auto',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: MobileSalePickerField(
                            label: 'Date',
                            value: formatSaleSingleDate(form.billDate),
                            isPlaceholder: form.billDate == null,
                            onTap: _pickBillDate,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: MobileSalePickerField(
                            label: 'Time',
                            value: formatSaleTime(form.billTime),
                            isPlaceholder: form.billTime == null,
                            onTap: _pickBillTime,
                          ),
                        ),
                      ],
                    ),
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
                    const SizedBox(height: AppSpacing.lg),
                    MobileSalePartyPickerField(
                      controller: _partyController,
                      selectedPartyId: form.partyId,
                      hasError: form.partyHasError,
                      label: 'Party',
                      hintText: 'Party name',
                      partyTypeFilter: PartyTypeFilter.supplier,
                      onSearchChanged: notifier.updateParty,
                      onPartySelected: (party) {
                        notifier.updateParty(party.name, partyId: party.id);
                        _syncControllersFromForm();
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    MobileSaleFormField(
                      label: 'Billing Name (Optional)',
                      controller: _billingNameController,
                      hintText: 'Billing Name (Optional)',
                      onChanged: notifier.updateBillingName,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    MobileSaleAddItemsRow(
                      onAddItems: () => unawaited(_pickCatalogItem()),
                      onScan: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Barcode scanner coming soon'),
                          ),
                        );
                      },
                    ),
                    if (form.items.any(
                      (line) => !isEmptyPurchaseLineDraft(line),
                    )) ...[
                      const SizedBox(height: AppSpacing.md),
                      for (var i = 0; i < form.items.length; i++)
                        if (!isEmptyPurchaseLineDraft(form.items[i])) ...[
                          MobileTransactionLineTile(
                            name: form.items[i].itemName,
                            qtyLabel: MobileTransactionLineFormat.qty(
                              qty: form.items[i].qty,
                              unit: form.items[i].unit,
                            ),
                            amountLabel: MobileTransactionLineFormat.amount(
                              form.items[i].amount,
                            ),
                            onRemove: () => notifier.removeLineItem(i),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    MobileSaleTotalRow(amountLabel: _totalLabel(grandTotal)),
                    const SizedBox(
                      height: MobileBottomNavigation.barHeight + AppSpacing.md,
                    ),
                  ],
                ),
              ),
            ),
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
