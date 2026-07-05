import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_document_draft_input.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_purchase_form_provider.g.dart';

int _purchaseLineItemCounter = 0;

String _nextPurchaseLineItemId() {
  _purchaseLineItemCounter += 1;
  return 'purchase_line_$_purchaseLineItemCounter';
}

AddPurchaseFormState _defaultFormState({String? documentId}) {
  final now = DateTime.now();
  return AddPurchaseFormState(
    documentId: documentId,
    billNumber: 'Auto',
    billDate: DateTime(now.year, now.month, now.day),
    billTime: TimeOfDay.fromDateTime(now),
    dueDate: DateTime(now.year, now.month, now.day),
    items: [PurchaseLineItem.empty(id: _nextPurchaseLineItemId())],
    isLoading: documentId != null,
  );
}

@riverpod
class AddPurchaseForm extends _$AddPurchaseForm {
  @override
  AddPurchaseFormState build({String? billId}) {
    if (billId != null) {
      Future.microtask(() => _loadDocument(billId));
      return _defaultFormState(documentId: billId);
    }
    return _defaultFormState();
  }

  Future<void> _loadDocument(String documentId) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final loaded = await service.loadPurchaseBillForm(documentId);
      final items = await _resolveItemNames(loaded.items);
      state = loaded.copyWith(items: items, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: PurchaseErrorMapper.messageFor(error),
      );
    }
  }

  Future<List<PurchaseLineItem>> _resolveItemNames(
    List<PurchaseLineItem> items,
  ) async {
    final inventory = ref.read(inventoryItemsProvider).value ?? [];
    final itemNames = {for (final item in inventory) item.id: item.name};

    return [
      for (final line in items)
        if (line.itemId != null && line.itemName.isEmpty)
          line.copyWith(itemName: itemNames[line.itemId] ?? '')
        else
          line,
    ];
  }

  Map<String, String> _itemNameToId() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return {for (final item in items) item.name.trim(): item.id};
  }

  void updateParty(String value, {String? partyId}) {
    state = state.copyWith(
      party: value,
      partyId: partyId ?? state.partyId,
      billingName: state.billingName.isEmpty ? value : state.billingName,
      isDirty: true,
      clearSaveError: true,
    );
  }

  void updateBillingName(String value) {
    state = state.copyWith(billingName: value, isDirty: true, clearSaveError: true);
  }

  void updateEWayBillNo(String value) {
    state = state.copyWith(eWayBillNo: value, isDirty: true);
  }

  void updateBillNumber(String value) {
    state = state.copyWith(billNumber: value, isDirty: true);
  }

  void updateBillDate(DateTime date) {
    state = state.copyWith(billDate: date, isDirty: true);
  }

  void updateBillTime(TimeOfDay time) {
    state = state.copyWith(billTime: time, isDirty: true);
  }

  void updatePaymentTerms(String value) {
    state = state.copyWith(paymentTerms: value, isDirty: true);
  }

  void updateDueDate(DateTime? date) {
    state = state.copyWith(dueDate: date, isDirty: true);
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

  void updateTermsTitle(String value) {
    state = state.copyWith(termsTitle: value, isDirty: true);
  }

  void updateTermsNotes(String value) {
    state = state.copyWith(termsNotes: value, isDirty: true);
  }

  void addLineItem() {
    final items = [
      ...state.items,
      PurchaseLineItem.empty(id: _nextPurchaseLineItemId()),
    ];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(PurchaseLineItem.empty(id: _nextPurchaseLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, PurchaseLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = item;
    state = state.copyWith(items: items, isDirty: true);
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
      const SalePaymentEntry(type: 'UPI'),
    ];
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value, isDirty: true);
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

  void toggleRoundOff({required bool value}) {
    state = state.copyWith(roundOff: value, isDirty: true);
  }

  bool validate({bool finalize = false}) {
    final hasLines = state.hasValidLineItems;
    final hasParty =
        (state.partyId != null && state.partyId!.isNotEmpty) ||
        state.party.trim().isNotEmpty;

    final isValid = hasLines && (!finalize || hasParty);
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  Future<String?> saveDraft() async {
    if (!validate()) return 'Add at least one item with name and quantity';

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final input = service.draftInputFromBillForm(
        state,
        documentType: PurchaseDocumentType.purchaseBill,
      );
      final document = await service.saveDocumentDraft(
        input.copyWith(partyId: state.partyId),
        itemNameToId: _itemNameToId(),
      );
      state = state.copyWith(
        documentId: document.id,
        isSaving: false,
        isDirty: false,
      );
      ref.invalidate(purchaseBillsProvider);
      return null;
    } catch (error) {
      final message = PurchaseErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }

  Future<String?> saveBill({bool finalize = true}) async {
    if (!validate(finalize: finalize)) {
      if ((state.partyId == null || state.partyId!.isEmpty) &&
          state.party.trim().isEmpty) {
        return 'Supplier is required';
      }
      return 'Add at least one item with name and quantity';
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final input = service.draftInputFromBillForm(
        state,
        documentType: PurchaseDocumentType.purchaseBill,
      );

      if (finalize) {
        await service.finalizeDocumentDraft(
          input.copyWith(partyId: state.partyId),
          itemNameToId: _itemNameToId(),
          godownId: state.godownId,
        );
      } else {
        await service.saveDocumentDraft(
          input.copyWith(partyId: state.partyId),
          itemNameToId: _itemNameToId(),
        );
      }

      ref.invalidate(purchaseBillsProvider);
      ref.invalidateSelf();
      return null;
    } catch (error) {
      final message = PurchaseErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }
}

extension on PurchaseDocumentDraftInput {
  PurchaseDocumentDraftInput copyWith({String? partyId}) {
    return PurchaseDocumentDraftInput(
      documentId: documentId,
      partyId: partyId ?? this.partyId,
      documentType: documentType,
      documentSeries: documentSeries,
      documentDate: documentDate,
      dueDate: dueDate,
      supplierInvoiceNumber: supplierInvoiceNumber,
      notes: notes,
      godownId: godownId,
      isGstFormal: isGstFormal,
      convertedFromId: convertedFromId,
      items: items,
    );
  }
}

@riverpod
double addPurchaseTotalTax(Ref ref, {String? billId}) {
  final form = ref.watch(addPurchaseFormProvider(billId: billId));
  return form.totalTax;
}

@riverpod
double addPurchaseGrandTotal(Ref ref, {String? billId}) {
  final form = ref.watch(addPurchaseFormProvider(billId: billId));
  return form.grandTotal;
}
