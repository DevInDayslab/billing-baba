import 'package:billing_baba/core/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/core/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:billing_baba/shared/forms/transaction_party_link.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/sales/application/estimate_quotation_provider.dart';
import 'package:billing_baba/features/sales/application/invoice_tax_fallback_provider.dart';
import 'package:billing_baba/features/sales/application/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:billing_baba/features/sales/utils/sale_line_item_catalog.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_document_form_provider.g.dart';

int _documentLineItemCounter = 0;

String _nextDocumentLineItemId() {
  _documentLineItemCounter += 1;
  return 'doc_line_$_documentLineItemCounter';
}

SaleDocumentFormState _initialDocumentFormState(SaleDocumentType documentType) {
  final now = DateTime.now();
  return SaleDocumentFormState(
    invoiceDate: DateTime(now.year, now.month, now.day),
    invoiceTime: TimeOfDay.fromDateTime(now),
    termsTitle: documentType.defaultTermsTitle,
    items: [SaleLineItem.empty(id: _nextDocumentLineItemId())],
  );
}

SalesDocumentListScope _listScopeFor(SaleDocumentType documentType) =>
    switch (documentType) {
      SaleDocumentType.estimate => estimateListScope(),
      SaleDocumentType.proforma => proformaListScope(),
    };

void _invalidateDocumentLists(Ref ref, SaleDocumentType documentType) {
  if (documentType == SaleDocumentType.estimate) {
    ref.invalidate(estimateQuotationsProvider);
  }
}

@riverpod
class SaleDocumentFormNotifier extends _$SaleDocumentFormNotifier {
  @override
  SaleDocumentFormState build(SaleDocumentType documentType) {
    ref.watch(invoiceFallbackTaxPercentProvider);
    return _initialDocumentFormState(documentType);
  }

  Map<String, String> _itemNameToId() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return {for (final item in items) item.name.trim(): item.id};
  }

  void openForm() {
    state = _initialDocumentFormState(documentType).copyWith(isFormOpen: true);
  }

  void resetForm() {
    state = _initialDocumentFormState(documentType);
  }

  void closeForm() {
    state = _initialDocumentFormState(documentType);
  }

  Future<void> loadDocument(String documentId) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final loaded = await service.loadSaleDocumentForm(documentId);
      final items = await _resolveItemNames(loaded.items);
      final attachments = await loadTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.estimate.apiValue,
        entityId: documentId,
      );
      state = loaded.copyWith(
        items: items,
        attachedImages: attachments.images,
        attachedDocuments: attachments.documents,
        isLoading: false,
        isFormOpen: true,
        showValidationErrors: kResetValidationOnLoad,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: SalesErrorMapper.messageFor(error),
      );
    }
  }

  Future<void> duplicateDocument(String sourceDocumentId) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final loaded = await service.loadSaleDocumentForm(sourceDocumentId);
      final items = await _resolveItemNames(loaded.items);
      final now = DateTime.now();
      state = loaded.copyWith(
        clearDocumentId: true,
        invoiceDate: DateTime(now.year, now.month, now.day),
        invoiceTime: TimeOfDay.fromDateTime(now),
        items: _cloneLineItemsForDuplicate(items),
        isFormOpen: true,
        isLoading: false,
        showValidationErrors: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: SalesErrorMapper.messageFor(error),
      );
    }
  }

  List<SaleLineItem> _cloneLineItemsForDuplicate(List<SaleLineItem> items) {
    final filled = items
        .where((line) => line.itemName.trim().isNotEmpty || line.qty > 0)
        .toList();
    if (filled.isEmpty) {
      return [SaleLineItem.empty(id: _nextDocumentLineItemId())];
    }

    return [
      for (final line in filled)
        SaleLineItem(
          id: _nextDocumentLineItemId(),
          itemId: line.itemId,
          itemName: line.itemName,
          serialNo: line.serialNo,
          description: line.description,
          batchNo: line.batchNo,
          modelNo: line.modelNo,
          expDate: line.expDate,
          mfgDate: line.mfgDate,
          mrp: line.mrp,
          size: line.size,
          qty: line.qty,
          unit: line.unit,
          pricePerUnit: line.pricePerUnit,
          priceIsTaxInclusive: line.priceIsTaxInclusive,
          discountPercent: line.discountPercent,
          taxPercent: line.taxPercent,
          isConfirmed: true,
        ),
      SaleLineItem.empty(id: _nextDocumentLineItemId()),
    ];
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
    final change = unlinkedPartyNameChange(
      newName: value,
      previousName: state.party,
      currentPartyId: state.partyId,
    );
    state = state.copyWith(
      party: change.partyName,
      clearPartyId: change.clearPartyId,
      clearSaveError: true,
    );
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
    state = state.copyWith(
      taxOption: value,
      items: applyBillTaxOptionToSaleItems(state.items, value),
    );
  }

  void toggleRoundOff({required bool value}) {
    state = state.copyWith(roundOff: value);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void updateTermsTitle(String value) {
    state = state.copyWith(termsTitle: value);
  }

  void updateTermsText(String value) {
    state = state.copyWith(termsText: value);
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
    final previous = state.items[index];
    final items = [...state.items];
    items[index] = item;
    final clearBillTax =
        item.taxPercent > 0 && isBillLevelTaxActive(state.taxOption);
    state = state.copyWith(
      items: items,
      taxOption: clearBillTax ? 'NONE' : state.taxOption,
      clearSaveError: true,
    );
    rememberInvoiceLineTaxIfChanged(ref, previous, item);
  }

  Future<void> selectCatalogItem(int index, SaleItemOption catalogItem) async {
    if (index < 0 || index >= state.items.length) return;
    final line = state.items[index];
    final applied = (await applyCatalogItemWithInvoiceTaxFallback(
      ref,
      line,
      catalogItem,
    )).copyWith(mrp: catalogItem.salePrice);
    final items = selectCatalogItemOnSaleLines(
      items: state.items,
      targetIndex: index,
      appliedLine: applied,
      nextLineId: _nextDocumentLineItemId,
    );
    state = state.copyWith(items: items, clearSaveError: true);
  }

  void confirmLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final item = state.items[index];
    if (item.itemName.trim().isEmpty || item.qty <= 0) return;

    final items = [...state.items];
    items[index] = item.copyWith(isConfirmed: true);
    if (index == items.length - 1) {
      items.add(SaleLineItem.empty(id: _nextDocumentLineItemId()));
    }
    state = state.copyWith(items: items);
  }

  String? _validationError() {
    return buildTransactionValidationError(
      hasValidLineItems: state.hasValidLineItems,
      hasValidParty: state.partyId != null && state.partyId!.isNotEmpty,
      requireParty: true,
    );
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
      documentTime: state.invoiceTime,
      notes: _buildNotes(),
      godownId: state.godownId,
      items: state.items,
      taxOption: state.taxOption,
    );
  }

  String? _buildNotes() {
    final parts = <String>[];
    if (state.termsText.trim().isNotEmpty) {
      parts.add(state.termsText.trim());
    }
    if (state.description.trim().isNotEmpty) {
      parts.add(state.description.trim());
    }
    return parts.isEmpty ? null : parts.join('\n\n');
  }

  Future<String?> saveDraft() async {
    if (state.isSaving) return null;
    if (!validate()) return _validationError();

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final document = await service.saveDocumentDraft(
        _draftInput(),
        itemNameToId: _itemNameToId(),
      );
      final synced = await syncTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.estimate.apiValue,
        entityId: document.id,
        images: state.attachedImages,
        documents: state.attachedDocuments,
      );
      state = state.copyWith(
        documentId: document.id,
        attachedImages: synced?.images ?? state.attachedImages,
        attachedDocuments: synced?.documents ?? state.attachedDocuments,
        isSaving: false,
      );
      ref.invalidate(salesDocumentsListProvider(_listScopeFor(documentType)));
      _invalidateDocumentLists(ref, documentType);
      return null;
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }

  Future<String?> save({bool finalize = false}) async {
    if (state.isSaving) return null;
    if (!validate()) return _validationError();

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      late final String savedDocumentId;
      if (finalize) {
        final document = await service.finalizeDocumentDraft(
          _draftInput(),
          itemNameToId: _itemNameToId(),
          godownId: state.godownId,
        );
        savedDocumentId = document.id;
      } else {
        final document = await service.saveDocumentDraft(
          _draftInput(),
          itemNameToId: _itemNameToId(),
        );
        savedDocumentId = document.id;
      }

      final synced = await syncTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.estimate.apiValue,
        entityId: savedDocumentId,
        images: state.attachedImages,
        documents: state.attachedDocuments,
      );
      state = state.copyWith(
        documentId: savedDocumentId,
        attachedImages: synced?.images ?? state.attachedImages,
        attachedDocuments: synced?.documents ?? state.attachedDocuments,
      );

      ref.invalidate(salesDocumentsListProvider(_listScopeFor(documentType)));
      _invalidateDocumentLists(ref, documentType);
      if (finalize) {
        await refreshAfterSaleMutation(
          ref,
          context: (
            partyId: state.partyId,
            itemIds: state.items
                .map((line) => line.itemId)
                .whereType<String>()
                .where((id) => id.isNotEmpty),
          ),
        );
      }
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
