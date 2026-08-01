import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/sales/application/sale_order_form_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_order_form_model.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileAddSaleOrderPage extends ConsumerStatefulWidget {
  const MobileAddSaleOrderPage({
    super.key,
    this.orderId,
  });

  final String? orderId;

  @override
  ConsumerState<MobileAddSaleOrderPage> createState() =>
      _MobileAddSaleOrderPageState();
}

class _MobileAddSaleOrderPageState extends ConsumerState<MobileAddSaleOrderPage> {
  final _dateFormat = DateFormat('dd MMM yyyy');
  late final String _sessionKey;

  @override
  void initState() {
    super.initState();
    _sessionKey = widget.orderId ?? 'mobile_sale_order_new';
    if (widget.orderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(saleOrderFormProvider(sessionKey: _sessionKey).notifier)
            .loadDocument(widget.orderId!);
      });
    }
  }

  SaleOrderFormState _form() =>
      ref.watch(saleOrderFormProvider(sessionKey: _sessionKey));

  SaleOrderFormNotifier _notifier() =>
      ref.read(saleOrderFormProvider(sessionKey: _sessionKey).notifier);

  Future<void> _pickParty() async {
    final party = await showMobilePartyPickerSheet(
      context,
      typeFilter: PartyTypeFilter.customer,
      title: 'Select customer',
    );
    if (party != null) {
      _notifier().updatePartyWithId(
        partyId: party.id,
        partyName: party.name,
      );
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
      SaleLineItem(
        id: _form().items[index].id,
        itemId: result.item.id,
        itemName: result.item.name,
        qty: result.quantity,
        pricePerUnit: result.pricePerUnit,
      ),
    );
  }

  Future<void> _save() async {
    final error = await _notifier().save();
    showMobileFormResult(
      context,
      error: error,
      successMessage: 'Sale order saved',
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
      title: isEdit ? 'Edit sale order' : 'Add sale order',
      isLoading: form.isLoading,
      isSaving: form.isSaving,
      primaryActionLabel: 'Save order',
      onPrimaryAction: _save,
      onBack: () => leaveTransactionFormPage(
        context: context,
        isDirty: false,
        isSaving: form.isSaving,
        listRoute: AppRoutes.saleOrder,
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
            label: 'Customer',
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
            tax: form.taxAmount,
            total: form.total,
          ),
        ],
      ),
    );
  }
}
