import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/purchases/application/debit_note_form_provider.dart';
import 'package:billing_baba/features/purchases/models/debit_note_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileAddDebitNotePage extends ConsumerStatefulWidget {
  const MobileAddDebitNotePage({super.key, this.debitNoteId});

  final String? debitNoteId;

  @override
  ConsumerState<MobileAddDebitNotePage> createState() =>
      _MobileAddDebitNotePageState();
}

class _MobileAddDebitNotePageState extends ConsumerState<MobileAddDebitNotePage> {
  final _dateFormat = DateFormat('dd MMM yyyy');

  DebitNoteFormState _form() =>
      ref.watch(debitNoteFormProvider(debitNoteId: widget.debitNoteId));

  DebitNoteForm _notifier() =>
      ref.read(debitNoteFormProvider(debitNoteId: widget.debitNoteId).notifier);

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
      SaleLineItem(
        id: lineId,
        itemId: result.item.id,
        itemName: result.item.name,
        qty: result.quantity,
        pricePerUnit: result.pricePerUnit,
      ),
    );
  }

  Future<void> _save() async {
    final error = await _notifier().saveDebitNote(finalize: true);
    showMobileFormResult(
      context,
      error: error,
      successMessage: 'Debit note saved',
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
      title:
          widget.debitNoteId != null ? 'Edit debit note' : 'Add debit note',
      isLoading: form.isLoading,
      isSaving: form.isSaving,
      primaryActionLabel: 'Save',
      onPrimaryAction: _save,
      onBack: () => leaveTransactionFormPage(
        context: context,
        isDirty: form.isDirty,
        isSaving: form.isSaving,
        listRoute: AppRoutes.purchaseReturnDebitNote,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (form.saveError != null)
            Text(
              form.saveError!,
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                color: AppColors.error,
              ),
            ),
          MobileFormPickerField(
            label: 'Supplier',
            value: form.party,
            errorText: form.partyHasError ? 'Required' : null,
            onTap: _pickParty,
          ),
          MobileFormPickerField(
            label: 'Return date',
            value: form.returnDate != null
                ? _dateFormat.format(form.returnDate!)
                : '',
            onTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.returnDate,
              );
              if (date != null) _notifier().updateReturnDate(date);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileLineItemsEditor(
            lines: lines,
            onAdd: _addLine,
            onRemove: _notifier().removeLineItem,
          ),
          MobileDocumentSummaryCard(
            subtotal: form.items.fold<double>(
              0,
              (sum, item) => sum + item.lineSubtotal,
            ),
            tax: form.items.fold<double>(
              0,
              (sum, item) => sum + item.lineTax,
            ),
            total: form.total,
          ),
        ],
      ),
    );
  }
}
