import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/providers/saved_sale_documents_provider.dart';
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

@riverpod
class SaleDocumentFormNotifier extends _$SaleDocumentFormNotifier {
  @override
  SaleDocumentFormState build(SaleDocumentType documentType) {
    return _initialDocumentFormState();
  }

  void openForm() {
    state = _initialDocumentFormState().copyWith(isFormOpen: true);
  }

  void resetForm() {
    state = _initialDocumentFormState();
  }

  void updateParty(String value) {
    state = state.copyWith(party: value);
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

  void updateGodown(String value) {
    state = state.copyWith(godown: value);
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

  void loadSavedDocument(SavedSaleDocument saved) {
    state = SaleDocumentFormState(
      isFormOpen: true,
      party: saved.party,
      refNo: saved.refNo,
      invoiceDate: saved.invoiceDate,
      invoiceTime: saved.invoiceTime,
      stateOfSupply: saved.stateOfSupply,
      godown: saved.godown,
      items: saved.items.isEmpty
          ? [SaleLineItem.empty(id: _nextDocumentLineItemId())]
          : List<SaleLineItem>.from(saved.items),
      description: saved.description,
      attachedImages: List<SaleFormAttachment>.from(saved.attachedImages),
      attachedDocuments: List<SaleFormAttachment>.from(saved.attachedDocuments),
      taxOption: saved.taxOption,
      roundOff: saved.roundOff,
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
    state = state.copyWith(items: items);
  }

  bool validate() {
    final isValid = state.isValid;
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  bool save() {
    if (!validate()) return false;
    final saved = SavedSaleDocument.fromFormState(
      id: nextSavedSaleDocumentId(),
      documentType: documentType,
      form: state,
      total: state.total,
    );
    ref.read(savedSaleDocumentsProvider.notifier).addDocument(saved);
    resetForm();
    return true;
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
