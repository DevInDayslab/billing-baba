import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_document_form_provider.g.dart';

int _documentLineItemCounter = 0;

String _nextDocumentLineItemId() {
  _documentLineItemCounter += 1;
  return 'doc_line_$_documentLineItemCounter';
}

SaleDocumentFormState _initialDocumentFormState() {
  final now = DateTime.now();
  return SaleDocumentFormState(
    invoiceDate: DateTime(now.year, now.month, now.day),
    invoiceTime: TimeOfDay.fromDateTime(now),
    items: [SaleLineItem.empty(id: _nextDocumentLineItemId())],
  );
}

SalesDocumentListScope _listScopeFor(SaleDocumentType documentType) =>
    switch (documentType) {
      SaleDocumentType.estimate => estimateListScope(),
      SaleDocumentType.proforma => proformaListScope(),
    };

@riverpod
class SaleDocumentFormNotifier extends _$SaleDocumentFormNotifier {
  @override
  SaleDocumentFormState build(SaleDocumentType documentType) {
    return _initialDocumentFormState();
  }

  Map<String, String> _itemNameToId() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return {for (final item in items) item.name.trim(): item.id};
  }

  void openForm() {
    state = _initialDocumentFormState().copyWith(isFormOpen: true);
  }

  void resetForm() {
    state = _initialDocumentFormState();
  }

  Future<void> loadDocument(String documentId) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final loaded = await service.loadSaleDocumentForm(documentId);
      final items = await _resolveItemNames(loaded.items);
      state = loaded.copyWith(items: items, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: SalesErrorMapper.messageFor(error),
      );
    }
  }

  Future<List<SaleLineItem>> _resolveItemNames(List<SaleLineItem> items) async {
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

  void updateParty(String value) {
    state = state.copyWith(party: value, clearSaveError: true);
  }

  void updatePartyWithId({required String partyId, required String partyName}) {
    state = state.copyWith(
      partyId: partyId,
      party: partyName,
      clearSaveError: true,
    );
  }

  void updateRefNo(String value) {
    state = state.copyWith(refNo: value);
  }

  void updateInvoiceDate(DateTime date) {
    state = state.copyWith(invoiceDate: date);
  }

  void updateInvoiceTime(TimeOfDay time) {
    state = state.copyWith(invoiceTime: time);
  }

  void updateStateOfSupply(String value) {
    state = state.copyWith(stateOfSupply: value);
  }

  void updateGodown(String value, {String? godownId}) {
    state = state.copyWith(godown: value, godownId: godownId);
  }

  void updateTaxOption(String value) {
    state = state.copyWith(taxOption: value);
  }

  void toggleRoundOff({required bool value}) {
    state = state.copyWith(roundOff: value);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void addImage(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedImages: [...state.attachedImages, attachment],
    );
  }

  void removeImage(String id) {
    state = state.copyWith(
      attachedImages: state.attachedImages
          .where((image) => image.id != id)
          .toList(),
    );
  }

  void updateImage(String id, String name) {
    state = state.copyWith(
      attachedImages: [
        for (final image in state.attachedImages)
          if (image.id == id) image.copyWith(name: name) else image,
      ],
    );
  }

  void addDocument(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedDocuments: [...state.attachedDocuments, attachment],
    );
  }

  void removeDocument(String id) {
    state = state.copyWith(
      attachedDocuments: state.attachedDocuments
          .where((document) => document.id != id)
          .toList(),
    );
  }

  void updateDocument(String id, String name) {
    state = state.copyWith(
      attachedDocuments: [
        for (final document in state.attachedDocuments)
          if (document.id == id) document.copyWith(name: name) else document,
      ],
    );
  }

  void addLineItem() {
    final items = [
      ...state.items,
      SaleLineItem.empty(id: _nextDocumentLineItemId()),
    ];
    state = state.copyWith(items: items);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(SaleLineItem.empty(id: _nextDocumentLineItemId()));
    }
    state = state.copyWith(items: items);
  }

  void updateLineItem(int index, SaleLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = item;
    state = state.copyWith(items: items, clearSaveError: true);
  }

  bool validate() {
    final isValid = state.isValid;
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  SalesDocumentDraftInput _draftInput() {
    return SalesDocumentDraftInput(
      documentId: state.documentId,
      partyId: state.partyId,
      documentType: documentType.backendType,
      documentSeries: documentType.documentSeries,
      documentDate: state.invoiceDate,
      notes: state.description,
      godownId: state.godownId,
      items: state.items,
    );
  }

  Future<String?> saveDraft() async {
    if (!validate()) return 'Please fill required fields';

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final document = await service.saveDocumentDraft(
        _draftInput(),
        itemNameToId: _itemNameToId(),
      );
      state = state.copyWith(
        documentId: document.id,
        isSaving: false,
      );
      ref.invalidate(salesDocumentsListProvider(_listScopeFor(documentType)));
      return null;
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }

  Future<String?> save({bool finalize = false}) async {
    if (!validate()) return 'Please fill required fields';

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      if (finalize) {
        await service.finalizeDocumentDraft(
          _draftInput(),
          itemNameToId: _itemNameToId(),
          godownId: state.godownId,
        );
      } else {
        await service.saveDocumentDraft(
          _draftInput(),
          itemNameToId: _itemNameToId(),
        );
      }
      ref.invalidate(salesDocumentsListProvider(_listScopeFor(documentType)));
      resetForm();
      return null;
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }
}

@riverpod
double saleDocumentTotalTax(Ref ref, SaleDocumentType documentType) {
  final form = ref.watch(saleDocumentFormProvider(documentType));
  return form.taxAmount;
}

@riverpod
double saleDocumentGrandTotal(Ref ref, SaleDocumentType documentType) {
  final form = ref.watch(saleDocumentFormProvider(documentType));
  return form.total;
}
