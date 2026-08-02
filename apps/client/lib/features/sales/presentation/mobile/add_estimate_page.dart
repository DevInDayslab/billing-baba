import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/sales/application/sale_document_form_provider.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileAddEstimatePage extends ConsumerStatefulWidget {
  const MobileAddEstimatePage({
    super.key,
    this.estimateId,
    this.duplicateFromId,
  });

  final String? estimateId;
  final String? duplicateFromId;

  @override
  ConsumerState<MobileAddEstimatePage> createState() =>
      _MobileAddEstimatePageState();
}

class _MobileAddEstimatePageState extends ConsumerState<MobileAddEstimatePage> {
  static const _documentType = SaleDocumentType.estimate;
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.estimateId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(saleDocumentFormProvider(_documentType).notifier)
            .loadDocument(widget.estimateId!);
      });
    } else {
      ref.read(saleDocumentFormProvider(_documentType).notifier).openForm();
    }
  }

  SaleDocumentFormState _form() =>
      ref.watch(saleDocumentFormProvider(_documentType));

  SaleDocumentFormNotifier _notifier() =>
      ref.read(saleDocumentFormProvider(_documentType).notifier);

  Future<void> _pickParty() async {
    final party = await showMobilePartyPickerSheet(
      context,
      typeFilter: PartyTypeFilter.customer,
    );
    if (party != null) {
      _notifier().updatePartyWithId(partyId: party.id, partyName: party.name);
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
      successMessage: _documentType.saveSuccessMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = _form();
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
      title: widget.estimateId != null ? 'Edit estimate' : 'Add estimate',
      isLoading: form.isLoading,
      isSaving: form.isSaving,
      primaryActionLabel: 'Save',
      onPrimaryAction: _save,
      onBack: () => leaveTransactionFormPage(
        context: context,
        isDirty: false,
        isSaving: form.isSaving,
        listRoute: AppRoutes.saleEstimateQuotation,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobileFormPickerField(
            label: 'Customer',
            value: form.party,
            errorText: form.partyHasError ? 'Required' : null,
            onTap: _pickParty,
          ),
          MobileFormPickerField(
            label: 'Date',
            value: form.invoiceDate != null
                ? _dateFormat.format(form.invoiceDate!)
                : '',
            onTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.invoiceDate,
              );
              if (date != null) _notifier().updateInvoiceDate(date);
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
            total: form.rawGrandTotal,
          ),
        ],
      ),
    );
  }
}
