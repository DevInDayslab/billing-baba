import 'package:billing_baba/core/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/core/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/core/forms/transaction_form_validation.dart';
import 'package:billing_baba/core/forms/transaction_party_link.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/core/utils/validators.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_order_form_model.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/providers/invoice_tax_fallback_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_orders_provider.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:billing_baba/features/sales/utils/sale_line_item_catalog.dart';
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
    ref.watch(invoiceFallbackTaxPercentProvider);
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
      final attachments = await loadTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.saleOrder.apiValue,
        entityId: documentId,
      );
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
        attachedImages: attachments.images,
        attachedDocuments: attachments.documents,
        isLoading: false,
        showValidationErrors: kResetValidationOnLoad,
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
      phoneNo: Validators.normalizeIndianPhone(party.phone) ?? '',
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
    state = state.copyWith(
      phoneNo: Validators.sanitizePhoneInput(value),
      clearSaveError: true,
    );
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

  void updateTaxOption(String value) {
    state = state.copyWith(
      taxOption: value,
      items: applyBillTaxOptionToSaleItems(state.items, value),
      clearSaveError: true,
    );
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
      nextLineId: _nextSaleOrderLineItemId,
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
      items.add(SaleLineItem.empty(id: _nextSaleOrderLineItemId()));
    }
    state = state.copyWith(items: items);
  }

  String? _validationError() {
    return buildTransactionValidationError(
      hasValidLineItems: state.hasValidLineItems,
      hasValidPhone: Validators.requiredPhone(state.phoneNo) == null,
      hasValidParty: state.partyId != null && state.partyId!.isNotEmpty,
      requirePhone: true,
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

  SalesDocumentDraftInput _draftInput() => SalesDocumentDraftInput(
    documentId: state.documentId,
    partyId: state.partyId,
    documentType: SalesDocumentType.saleOrder,
    documentSeries: SalesConstants.saleOrderSeries,
    documentDate: state.orderDate,
    notes: state.description,
    items: state.items,
    taxOption: state.taxOption,
  );

  Future<String?> save({bool stayOpen = false}) async {
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
        entityType: DocumentAttachmentEntityType.saleOrder.apiValue,
        entityId: document.id,
        images: state.attachedImages,
        documents: state.attachedDocuments,
      );
      ref.invalidate(salesDocumentsListProvider(saleOrderListScope()));
      ref.invalidate(saleOrdersProvider);
      state = state.copyWith(
        documentId: document.id,
        attachedImages: synced?.images ?? state.attachedImages,
        attachedDocuments: synced?.documents ?? state.attachedDocuments,
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
    if (state.isSaving) return null;
    if (!validate()) return _validationError();

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final document = await service.finalizeDocumentDraft(
        _draftInput(),
        itemNameToId: _itemNameToId(),
      );
      final synced = await syncTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.saleOrder.apiValue,
        entityId: document.id,
        images: state.attachedImages,
        documents: state.attachedDocuments,
      );
      state = state.copyWith(
        documentId: document.id,
        attachedImages: synced?.images ?? state.attachedImages,
        attachedDocuments: synced?.documents ?? state.attachedDocuments,
      );
      ref.invalidate(salesDocumentsListProvider(saleOrderListScope()));
      ref.invalidate(saleOrdersProvider);
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
      resetForm();
      return null;
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }
}
