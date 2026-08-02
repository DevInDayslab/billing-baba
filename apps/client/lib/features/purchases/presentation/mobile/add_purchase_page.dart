import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/purchases/application/add_purchase_form_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileAddPurchasePage extends ConsumerStatefulWidget {
  const MobileAddPurchasePage({super.key, this.billId});

  final String? billId;

  @override
  ConsumerState<MobileAddPurchasePage> createState() =>
      _MobileAddPurchasePageState();
}

class _MobileAddPurchasePageState extends ConsumerState<MobileAddPurchasePage> {
  final _dateFormat = DateFormat('dd MMM yyyy');

  AddPurchaseFormState _form() =>
      ref.watch(addPurchaseFormProvider(billId: widget.billId));

  AddPurchaseForm _notifier() =>
      ref.read(addPurchaseFormProvider(billId: widget.billId).notifier);

  Future<void> _pickParty() async {
    final party = await showMobilePartyPickerSheet(
      context,
      typeFilter: PartyTypeFilter.supplier,
      title: 'Select supplier',
    );
    if (party != null) {
      _notifier().updateParty(party.name, partyId: party.id);
    }
  }

  Future<void> _pickPaymentType() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            for (final type in SaleDropdownOptions.paymentTypes)
              ListTile(
                title: Text(type),
                onTap: () => Navigator.pop(context, type),
              ),
          ],
        ),
      ),
    );
    if (picked != null) _notifier().updatePaymentType(picked);
  }

  Future<void> _addLine() async {
    final result = await showMobileItemPickerSheet(context);
    if (result == null) return;
    final notifier = _notifier();
    final items = _form().items;
    final lastEmpty =
        items.isNotEmpty && items.last.itemName.trim().isEmpty;
    int targetIndex;
    if (lastEmpty) {
      targetIndex = items.length - 1;
    } else {
      notifier.addLineItem();
      targetIndex = _form().items.length - 1;
    }
    final lineId = _form().items[targetIndex].id;
    notifier.updateLineItem(
      targetIndex,
      PurchaseLineItem(
        id: lineId,
        itemId: result.item.id,
        itemName: result.item.name,
        qty: result.quantity,
        pricePerUnit: result.pricePerUnit,
      ),
    );
  }

  Future<void> _saveDraft() async {
    final error = await _notifier().saveDraft();
    showMobileFormResult(context, error: error, successMessage: 'Draft saved');
  }

  Future<void> _finalize() async {
    final error = await _notifier().saveBill(finalize: true);
    showMobileFormResult(context, error: error, successMessage: 'Bill saved');
  }

  @override
  Widget build(BuildContext context) {
    final form = _form();
    final isEdit = widget.billId != null;

    final lines = form.items
        .where((item) => item.itemName.trim().isNotEmpty)
        .map(
          (item) => MobileLineItemDisplay(
            title: item.itemName,
            quantity: item.qty,
            unitPrice: item.pricePerUnit,
            total: item.amount,
          ),
        )
        .toList();

    return MobileFormScaffold(
      title: isEdit ? 'Edit purchase' : 'Add purchase',
      isLoading: form.isLoading,
      isSaving: form.isSaving,
      primaryActionLabel: 'Finalize',
      secondaryActionLabel: 'Save draft',
      onPrimaryAction: _finalize,
      onSecondaryAction: _saveDraft,
      onBack: () => leaveTransactionFormPage(
        context: context,
        isDirty: form.isDirty,
        isSaving: form.isSaving,
        listRoute: AppRoutes.purchaseBills,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (form.saveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                form.saveError!,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodySize,
                  color: AppColors.error,
                ),
              ),
            ),
          MobileFormSection(
            title: 'Supplier',
            children: [
              MobileFormPickerField(
                label: 'Party',
                value: form.party,
                errorText: form.partyHasError ? 'Required' : null,
                onTap: _pickParty,
              ),
              MobileFormPickerField(
                label: 'Bill date',
                value: form.billDate != null
                    ? _dateFormat.format(form.billDate!)
                    : '',
                onTap: () async {
                  final date = await showMobileDatePicker(
                    context,
                    initialDate: form.billDate,
                  );
                  if (date != null) _notifier().updateBillDate(date);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileLineItemsEditor(
            lines: lines,
            onAdd: _addLine,
            onRemove: _notifier().removeLineItem,
          ),
          MobileFormPickerField(
            label: 'Payment mode',
            value: form.paymentType,
            onTap: _pickPaymentType,
          ),
          MobileDocumentSummaryCard(
            subtotal: form.subtotal,
            tax: form.totalTax,
            total: form.grandTotal,
          ),
        ],
      ),
    );
  }
}
