import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/purchases/application/add_purchase_order_form_provider.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_form_model.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileAddPurchaseOrderPage extends ConsumerStatefulWidget {
  const MobileAddPurchaseOrderPage({
    super.key,
    this.orderId,
  });

  final String? orderId;

  @override
  ConsumerState<MobileAddPurchaseOrderPage> createState() =>
      _MobileAddPurchaseOrderPageState();
}

class _MobileAddPurchaseOrderPageState
    extends ConsumerState<MobileAddPurchaseOrderPage> {
  final _dateFormat = DateFormat('dd MMM yyyy');

  AddPurchaseOrderFormState _form() =>
      ref.watch(addPurchaseOrderFormProvider(orderId: widget.orderId));

  AddPurchaseOrderForm _notifier() =>
      ref.read(addPurchaseOrderFormProvider(orderId: widget.orderId).notifier);

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

  Future<void> _addLine() async {
    final result = await showMobileItemPickerSheet(context);
    if (result == null) return;
    final items = _form().items;
    final lastEmpty =
        items.isNotEmpty && items.last.itemName.trim().isEmpty;
    if (!lastEmpty) _notifier().addLineItem();
    final index = _form().items.length - 1;
    _notifier().updateLineItem(
      index,
      PurchaseLineItem(
        id: _form().items[index].id,
        itemId: result.item.id,
        itemName: result.item.name,
        qty: result.quantity,
        pricePerUnit: result.pricePerUnit,
      ),
    );
  }

  Future<void> _save() async {
    final error = await _notifier().saveOrder();
    showMobileFormResult(
      context,
      error: error,
      successMessage: 'Purchase order saved',
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = _form();
    final isEdit = widget.orderId != null;

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
      title: isEdit ? 'Edit purchase order' : 'Add purchase order',
      isLoading: form.isLoading,
      isSaving: form.isSaving,
      primaryActionLabel: 'Save order',
      onPrimaryAction: _save,
      onBack: () => leaveTransactionFormPage(
        context: context,
        isDirty: form.isDirty,
        isSaving: form.isSaving,
        listRoute: AppRoutes.purchaseOrder,
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
          MobileFormPickerField(
            label: 'Supplier',
            value: form.party,
            errorText: form.partyHasError ? 'Required' : null,
            onTap: _pickParty,
          ),
          MobileFormPickerField(
            label: 'Order date',
            value: form.orderDate != null
                ? _dateFormat.format(form.orderDate!)
                : '',
            onTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.orderDate,
              );
              if (date != null) _notifier().updateOrderDate(date);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileLineItemsEditor(
            lines: lines,
            onAdd: _addLine,
            onRemove: _notifier().removeLineItem,
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
