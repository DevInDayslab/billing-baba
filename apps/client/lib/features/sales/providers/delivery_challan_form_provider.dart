import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/delivery_challan_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/providers/delivery_challan_provider.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delivery_challan_form_provider.g.dart';

int _challanLineItemCounter = 0;

String _nextChallanLineItemId() {
  _challanLineItemCounter += 1;
  return 'challan_line_$_challanLineItemCounter';
}

DeliveryChallanFormState _initialChallanFormState() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return DeliveryChallanFormState(
    invoiceDate: today,
    dueDate: today,
    invoiceTime: TimeOfDay.fromDateTime(now),
    items: [SaleLineItem.empty(id: _nextChallanLineItemId())],
  );
}

@riverpod
class DeliveryChallanFormNotifier extends _$DeliveryChallanFormNotifier {
  @override
  DeliveryChallanFormState build() => _initialChallanFormState();

  Map<String, String> _itemNameToId() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return {for (final item in items) item.name.trim(): item.id};
  }

  void openForm() {
    state = _initialChallanFormState().copyWith(isFormOpen: true);
  }

  void resetForm() {
    state = _initialChallanFormState();
  }

  void closeForm() {
    state = state.copyWith(isFormOpen: false);
  }

  Future<void> loadDocument(String documentId) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final loaded = await service.loadSaleDocumentForm(documentId);
      final items = await _resolveItemNames(loaded.items);
      state = DeliveryChallanFormState(
        isFormOpen: true,
        documentId: loaded.documentId,
        partyId: loaded.partyId,
        party: loaded.party,
        godown: loaded.godown,
        godownId: loaded.godownId,
        challanNo: loaded.refNo,
        invoiceDate: loaded.invoiceDate,
        invoiceTime: loaded.invoiceTime,
        dueDate: loaded.invoiceDate,
        stateOfSupply: loaded.stateOfSupply,
        items: items,
        description: loaded.description,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: SalesErrorMapper.messageFor(error),
      );
    }
  }

  Future<void> duplicateDocument(String documentId) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final loaded = await service.loadSaleDocumentForm(documentId);
      final items = await _resolveItemNames(loaded.items);
      final now = DateTime.now();
      state = DeliveryChallanFormState(
        isFormOpen: true,
        partyId: loaded.partyId,
        party: loaded.party,
        godown: loaded.godown,
        godownId: loaded.godownId,
        invoiceDate: DateTime(now.year, now.month, now.day),
        invoiceTime: TimeOfDay.fromDateTime(now),
        dueDate: DateTime(now.year, now.month, now.day),
        stateOfSupply: loaded.stateOfSupply,
        items: _cloneLineItemsForDuplicate(items),
        description: loaded.description,
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
      return [SaleLineItem.empty(id: _nextChallanLineItemId())];
    }

    return [
      for (final line in filled)
        SaleLineItem(
          id: _nextChallanLineItemId(),
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
      SaleLineItem.empty(id: _nextChallanLineItemId()),
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
    state = state.copyWith(party: value, clearSaveError: true);
  }

  void updatePartyWithId({required String partyId, required String partyName}) {
    state = state.copyWith(
      partyId: partyId,
      party: partyName,
      clearSaveError: true,
    );
  }

  void updateBillingAddress(String value) {
    state = state.copyWith(billingAddress: value);
  }

  void updateShippingAddress(String value) {
    state = state.copyWith(shippingAddress: value);
  }

  void updateGodown(String value, {String? godownId}) {
    state = state.copyWith(godown: value, godownId: godownId);
  }

  void updateChallanNo(String value) {
    state = state.copyWith(challanNo: value);
  }

  void updateInvoiceDate(DateTime date) {
    state = state.copyWith(invoiceDate: date);
  }

  void updateInvoiceTime(TimeOfDay time) {
    state = state.copyWith(invoiceTime: time);
  }

  void updateDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
  }

  void updateStateOfSupply(String value) {
    state = state.copyWith(stateOfSupply: value);
  }

  void updateTaxOption(String value) {
    state = state.copyWith(taxOption: value);
  }

  void updateTermsTitle(String value) {
    state = state.copyWith(termsTitle: value);
  }

  void updateTermsText(String value) {
    state = state.copyWith(termsText: value);
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
      SaleLineItem.empty(id: _nextChallanLineItemId()),
    ];
    state = state.copyWith(items: items);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(SaleLineItem.empty(id: _nextChallanLineItemId()));
    }
    state = state.copyWith(items: items);
  }

  void updateLineItem(int index, SaleLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = item;
    state = state.copyWith(items: items, clearSaveError: true);
  }

  void confirmLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final item = state.items[index];
    if (item.itemName.trim().isEmpty || item.qty <= 0) return;

    final items = [...state.items];
    items[index] = item.copyWith(isConfirmed: true);
    if (index == items.length - 1) {
      items.add(SaleLineItem.empty(id: _nextChallanLineItemId()));
    }
    state = state.copyWith(items: items);
  }

  bool validate() {
    final isValid = state.isValid;
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  SalesDocumentDraftInput _draftInput() => SalesDocumentDraftInput(
    documentId: state.documentId,
    partyId: state.partyId,
    documentType: SalesDocumentType.deliveryChallan,
    documentSeries: SalesConstants.challanSeries,
    documentDate: state.invoiceDate,
    documentTime: state.invoiceTime,
    notes: _buildNotes(),
    godownId: state.godownId,
    items: state.items,
  );

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

  Future<String?> save() async {
    if (!validate()) return 'Please fill required fields';

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final document = await service.saveDocumentDraft(
        _draftInput(),
        itemNameToId: _itemNameToId(),
      );
      ref.invalidate(salesDocumentsListProvider(deliveryChallanListScope()));
      ref.invalidate(deliveryChallansProvider);
      state = state.copyWith(
        documentId: document.id,
        isSaving: false,
      );
      return null;
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }

  Future<String?> finalize() async {
    if (!validate()) return 'Please fill required fields';

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.finalizeDocumentDraft(
        _draftInput(),
        itemNameToId: _itemNameToId(),
        godownId: state.godownId,
      );
      ref.invalidate(salesDocumentsListProvider(deliveryChallanListScope()));
      ref.invalidate(deliveryChallansProvider);
      refreshAfterSaleMutation(ref);
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
double deliveryChallanTotalTax(Ref ref) {
  final form = ref.watch(deliveryChallanFormProvider);
  return form.taxAmount;
}

@riverpod
double deliveryChallanGrandTotal(Ref ref) {
  final form = ref.watch(deliveryChallanFormProvider);
  return form.total;
}
