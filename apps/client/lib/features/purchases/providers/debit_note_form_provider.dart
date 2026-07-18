import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/debit_note_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_document_draft_input.dart';
import 'package:billing_baba/features/purchases/providers/purchase_return_provider.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/utils/sale_line_item_catalog.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debit_note_form_provider.g.dart';

int _debitNoteLineItemCounter = 0;

String _nextDebitNoteLineItemId() {
  _debitNoteLineItemCounter += 1;
  return 'debit_note_line_$_debitNoteLineItemCounter';
}

DebitNoteFormState _initialDebitNoteFormState({String? documentId}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return DebitNoteFormState(
    documentId: documentId,
    returnDate: today,
    returnTime: TimeOfDay.fromDateTime(now),
    items: [SaleLineItem.empty(id: _nextDebitNoteLineItemId())],
  );
}

List<PurchaseLineItem> _toPurchaseLines(List<SaleLineItem> items) {
  return items
      .map(
        (line) => PurchaseLineItem(
          id: line.id,
          serverLineId: line.serverLineId,
          itemId: line.itemId,
          itemName: line.itemName,
          qty: line.qty,
          unit: line.unit,
          pricePerUnit: line.pricePerUnit,
          taxPercent: line.taxPercent,
        ),
      )
      .toList();
}

@riverpod
class DebitNoteForm extends _$DebitNoteForm {
  @override
  DebitNoteFormState build({String? debitNoteId}) {
    if (debitNoteId != null) {
      Future.microtask(() => _loadDocument(debitNoteId));
    }
    return _initialDebitNoteFormState(
      documentId: debitNoteId,
    ).copyWith(isLoading: debitNoteId != null);
  }

  Future<void> _loadDocument(String documentId) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final loaded = await service.loadDebitNoteForm(documentId);
      final inventory = ref.read(inventoryItemsProvider).value ?? [];
      final itemNames = {for (final item in inventory) item.id: item.name};

      final items = loaded.items.map((line) {
        final saleLine = SaleLineItem(
          id: line.id,
          serverLineId: line.serverLineId,
          itemId: line.itemId,
          itemName: line.itemId != null && line.itemName.isEmpty
              ? (itemNames[line.itemId] ?? '')
              : line.itemName,
          qty: line.qty,
          unit: line.unit,
          pricePerUnit: line.pricePerUnit,
          taxPercent: line.taxPercent,
        );
        return saleLine;
      }).toList();

      state = DebitNoteFormState(
        documentId: loaded.documentId,
        partyId: loaded.partyId,
        party: loaded.party,
        returnNo: loaded.billNumber,
        returnDate: loaded.billDate,
        returnTime: loaded.billTime,
        description: loaded.description,
        items: items.isEmpty
            ? [SaleLineItem.empty(id: _nextDebitNoteLineItemId())]
            : items,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: PurchaseErrorMapper.messageFor(error),
      );
    }
  }

  void resetForm() {
    state = _initialDebitNoteFormState();
  }

  Map<String, String> _itemNameToId() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return {for (final item in items) item.name.trim(): item.id};
  }

  void updateParty(String value, {String? partyId}) {
    state = state.copyWith(
      party: value,
      partyId: partyId ?? state.partyId,
      isDirty: true,
    );
  }

  void updateReturnNo(String value) {
    state = state.copyWith(returnNo: value, isDirty: true);
  }

  void updateBillNumber(String value) {
    state = state.copyWith(billNumber: value, isDirty: true);
  }

  void updateBillDate(DateTime? date) {
    state = state.copyWith(billDate: date, isDirty: true);
  }

  void updateReturnDate(DateTime date) {
    state = state.copyWith(returnDate: date, isDirty: true);
  }

  void updateReturnTime(TimeOfDay time) {
    state = state.copyWith(returnTime: time, isDirty: true);
  }

  void updateStateOfSupply(String value) {
    state = state.copyWith(stateOfSupply: value, isDirty: true);
  }

  void updateGodown(String value, {String? godownId}) {
    state = state.copyWith(
      godown: value,
      godownId: godownId ?? state.godownId,
      isDirty: true,
    );
  }

  void toggleRoundOff({required bool value}) {
    state = state.copyWith(roundOff: value, isDirty: true);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value, isDirty: true);
  }

  void updatePaymentType(String type) {
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(SalePaymentEntry(type: type));
    } else {
      payments[0] = payments[0].copyWith(type: type);
    }
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void updatePaymentAmount(double amount) {
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(SalePaymentEntry(type: 'Cash', amount: amount));
    } else {
      payments[0] = payments[0].copyWith(amount: amount);
    }
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void addPaymentType() {
    final payments = [
      ...state.payments,
      const SalePaymentEntry(type: 'Cash'),
    ];
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void addLineItem() {
    final items = [
      ...state.items,
      SaleLineItem.empty(id: _nextDebitNoteLineItemId()),
    ];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(SaleLineItem.empty(id: _nextDebitNoteLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, SaleLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = item;
    state = state.copyWith(items: items, isDirty: true);
  }

  void selectCatalogItem(int index, SaleItemOption catalogItem) {
    if (index < 0 || index >= state.items.length) return;
    final line = state.items[index];
    final applied = applyCatalogItemToLine(
      line,
      catalogItem,
    ).copyWith(mrp: catalogItem.salePrice);
    final items = selectCatalogItemOnSaleLines(
      items: state.items,
      targetIndex: index,
      appliedLine: applied,
      nextLineId: _nextDebitNoteLineItemId,
    );
    state = state.copyWith(items: items, isDirty: true);
  }

  void addImage(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedImages: [...state.attachedImages, attachment],
      isDirty: true,
    );
  }

  void removeImage(String id) {
    state = state.copyWith(
      attachedImages: state.attachedImages
          .where((image) => image.id != id)
          .toList(),
      isDirty: true,
    );
  }

  void updateImage(String id, String name) {
    state = state.copyWith(
      attachedImages: [
        for (final image in state.attachedImages)
          if (image.id == id) image.copyWith(name: name) else image,
      ],
      isDirty: true,
    );
  }

  void addDocument(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedDocuments: [...state.attachedDocuments, attachment],
      isDirty: true,
    );
  }

  void removeDocument(String id) {
    state = state.copyWith(
      attachedDocuments: state.attachedDocuments
          .where((document) => document.id != id)
          .toList(),
      isDirty: true,
    );
  }

  void updateDocument(String id, String name) {
    state = state.copyWith(
      attachedDocuments: [
        for (final document in state.attachedDocuments)
          if (document.id == id) document.copyWith(name: name) else document,
      ],
      isDirty: true,
    );
  }

  bool validate({bool finalize = false}) {
    final hasParty = state.partyId != null && state.partyId!.isNotEmpty;
    final isValid = state.hasValidLineItems && (!finalize || hasParty);
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  Future<String?> saveDebitNote({bool finalize = true}) async {
    if (!validate(finalize: finalize)) {
      if (state.partyId == null || state.partyId!.isEmpty) {
        return 'Please select a party';
      }
      return 'Add at least one item with name and quantity';
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final input = PurchaseDocumentDraftInput(
        documentId: state.documentId,
        partyId: state.partyId,
        documentType: PurchaseDocumentType.purchaseReturn,
        documentSeries: PurchaseConstants.purchaseReturnSeries,
        documentDate: state.returnDate,
        notes: state.description,
        godownId: state.godownId,
        items: _toPurchaseLines(state.items),
      );

      if (finalize) {
        await service.finalizeDocumentDraft(
          input,
          itemNameToId: _itemNameToId(),
          godownId: state.godownId,
        );
      } else {
        await service.saveDocumentDraft(
          input,
          itemNameToId: _itemNameToId(),
        );
      }

      ref.invalidate(purchaseReturnsProvider);
      await refreshAfterPurchaseReturn(
        ref,
        context: (
          partyId: state.partyId,
          itemIds: state.items
              .map((line) => line.itemId)
              .whereType<String>()
              .where((id) => id.isNotEmpty),
        ),
      );
      await ref.read(purchaseReturnsProvider.notifier).refresh();
      ref
          .read(purchaseReturnSaveSuccessMessageProvider.notifier)
          .setMessage('Debit note saved successfully');
      resetForm();
      return null;
    } catch (error) {
      final message = PurchaseErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }
}

@riverpod
double debitNoteGrandTotal(Ref ref, {String? debitNoteId}) {
  final form = ref.watch(debitNoteFormProvider(debitNoteId: debitNoteId));
  return form.total;
}
