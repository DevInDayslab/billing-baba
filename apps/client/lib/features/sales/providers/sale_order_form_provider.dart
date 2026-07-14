import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_order_form_model.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/providers/sale_orders_provider.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_order_form_provider.g.dart';

int _saleOrderLineItemCounter = 0;

String _nextSaleOrderLineItemId() {
  _saleOrderLineItemCounter += 1;
  return 'order_line_$_saleOrderLineItemCounter';
}

SaleOrderFormState _initialSaleOrderFormState() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return SaleOrderFormState(
    orderDate: today,
    dueDate: today,
    orderTime: TimeOfDay.fromDateTime(now),
    items: [SaleLineItem.empty(id: _nextSaleOrderLineItemId())],
  );
}

@riverpod
class SaleOrderFormNotifier extends _$SaleOrderFormNotifier {
  @override
  SaleOrderFormState build({String sessionKey = 'default'}) {
    return _initialSaleOrderFormState();
  }

  Map<String, String> _itemNameToId() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return {for (final item in items) item.name.trim(): item.id};
  }

  void openForm() {
    state = _initialSaleOrderFormState().copyWith(isFormOpen: true);
  }

  void resetForm() {
    state = _initialSaleOrderFormState();
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
      final now = DateTime.now();
      state = SaleOrderFormState(
        isFormOpen: true,
        documentId: loaded.documentId,
        partyId: loaded.partyId,
        party: loaded.party,
        orderNo: loaded.refNo,
        orderDate: loaded.invoiceDate,
        orderTime: TimeOfDay.fromDateTime(now),
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
    await loadDocument(documentId);
    state = state.copyWith(
      orderNo: '',
      isFormOpen: true,
    );
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
    final parties = ref.read(partiesListProvider);
    final party = parties.where((item) => item.id == partyId).firstOrNull;
    if (party != null) {
      applyPartyDetails(party);
      return;
    }

    state = state.copyWith(
      partyId: partyId,
      party: partyName,
      clearSaveError: true,
    );
  }

  void applyPartyDetails(PartyModel party) {
    state = state.copyWith(
      partyId: party.id,
      party: party.name,
      phoneNo: party.phone,
      stateOfSupply: party.state.isNotEmpty ? party.state : state.stateOfSupply,
      clearSaveError: true,
    );
  }

  void updateOrderNo(String value) {
    state = state.copyWith(orderNo: value);
  }

  void updateOrderDate(DateTime date) {
    state = state.copyWith(orderDate: date);
  }

  void updateOrderTime(TimeOfDay time) {
    state = state.copyWith(orderTime: time);
  }

  void updateDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
  }

  void updateStateOfSupply(String value) {
    state = state.copyWith(stateOfSupply: value);
  }

  void updateGodown(String value, {String? godownId}) {
    state = state.copyWith(godown: value);
  }

  void updatePhoneNo(String value) {
    state = state.copyWith(phoneNo: value);
  }

  void updatePaymentType(String value) {
    state = state.copyWith(paymentType: value);
  }

  void updateAdvanceAmount(double value) {
    state = state.copyWith(advanceAmount: value);
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
      SaleLineItem.empty(id: _nextSaleOrderLineItemId()),
    ];
    state = state.copyWith(items: items);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(SaleLineItem.empty(id: _nextSaleOrderLineItemId()));
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
      items.add(SaleLineItem.empty(id: _nextSaleOrderLineItemId()));
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
    documentType: SalesDocumentType.saleOrder,
    documentSeries: SalesConstants.saleOrderSeries,
    documentDate: state.orderDate,
    notes: state.description,
    items: state.items,
  );

  Future<String?> save({bool stayOpen = false}) async {
    if (!validate()) return 'Please fill required fields';

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final document = await service.saveDocumentDraft(
        _draftInput(),
        itemNameToId: _itemNameToId(),
      );
      ref.invalidate(salesDocumentsListProvider(saleOrderListScope()));
      ref.invalidate(saleOrdersProvider);
      state = state.copyWith(
        documentId: document.id,
        isSaving: false,
        isFormOpen: stayOpen,
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
      );
      ref.invalidate(salesDocumentsListProvider(saleOrderListScope()));
      ref.invalidate(saleOrdersProvider);
      refreshAfterSaleMutation(
        ref,
        context: (
          partyId: state.partyId,
          itemIds: state.items
              .map((line) => line.itemId)
              .whereType<String>()
              .where((id) => id.isNotEmpty),
        ),
      );
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
double saleOrderGrandTotal(Ref ref, {String sessionKey = 'default'}) {
  final form = ref.watch(saleOrderFormProvider(sessionKey: sessionKey));
  return form.total;
}

@riverpod
double saleOrderTotalTax(Ref ref, {String sessionKey = 'default'}) {
  final form = ref.watch(saleOrderFormProvider(sessionKey: sessionKey));
  return form.taxAmount;
}
