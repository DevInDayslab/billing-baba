import 'package:billing_baba/core/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/core/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_document_draft_input.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_form_model.dart';
import 'package:billing_baba/features/purchases/providers/purchase_orders_provider.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/purchases/utils/purchase_line_item_catalog.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_purchase_order_form_provider.g.dart';

int _purchaseOrderLineItemCounter = 0;

String _nextPurchaseOrderLineItemId() {
  _purchaseOrderLineItemCounter += 1;
  return 'po_line_$_purchaseOrderLineItemCounter';
}

@riverpod
class AddPurchaseOrderForm extends _$AddPurchaseOrderForm {
  @override
  AddPurchaseOrderFormState build({String? orderId}) {
    if (orderId != null) {
      Future.microtask(() => _loadDocument(orderId));
    }
    final now = DateTime.now();
    return AddPurchaseOrderFormState(
      documentId: orderId,
      orderNumber: 'Auto',
      orderDate: DateTime(now.year, now.month, now.day),
      orderTime: TimeOfDay.fromDateTime(now),
      dueDate: DateTime(now.year, now.month, now.day),
      items: [PurchaseLineItem.empty(id: _nextPurchaseOrderLineItemId())],
      isLoading: orderId != null,
    );
  }

  Future<void> _loadDocument(String documentId) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final loaded = await service.loadPurchaseOrderForm(documentId);
      final items = await _resolveItemNames(loaded.items);
      final attachments = await loadTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.purchaseOrder.apiValue,
        entityId: documentId,
      );
      state = _mapBillFormToOrderForm(
        loaded.copyWith(
          items: items,
          attachedImages: attachments.images,
          attachedDocuments: attachments.documents,
        ),
      ).copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: PurchaseErrorMapper.messageFor(error),
      );
    }
  }

  AddPurchaseOrderFormState _mapBillFormToOrderForm(AddPurchaseFormState bill) {
    return AddPurchaseOrderFormState(
      documentId: bill.documentId,
      partyId: bill.partyId,
      godownId: bill.godownId,
      party: bill.party,
      billingName: bill.billingName,
      orderNumber: bill.billNumber,
      orderDate: bill.billDate,
      orderTime: bill.billTime,
      dueDate: bill.dueDate,
      stateOfSupply: bill.stateOfSupply,
      godown: bill.godown,
      description: bill.description,
      items: bill.items,
      payments: bill.payments,
      attachedImages: bill.attachedImages,
      attachedDocuments: bill.attachedDocuments,
    );
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
    state = state.copyWith(billingName: value, isDirty: true);
  }

  void updateOrderNumber(String value) {
    state = state.copyWith(orderNumber: value, isDirty: true);
  }

  void updateOrderDate(DateTime date) {
    state = state.copyWith(orderDate: date, isDirty: true);
  }

  void updateOrderTime(TimeOfDay time) {
    state = state.copyWith(orderTime: time, isDirty: true);
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
      PurchaseLineItem.empty(id: _nextPurchaseOrderLineItemId()),
    ];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(PurchaseLineItem.empty(id: _nextPurchaseOrderLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, PurchaseLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = item;
    state = state.copyWith(items: items, isDirty: true);
  }

  void selectCatalogItem(int index, SaleItemOption catalogItem) {
    if (index < 0 || index >= state.items.length) return;
    final line = state.items[index];
    final applied = applyCatalogItemToPurchaseLine(line, catalogItem);
    final items = selectCatalogItemOnPurchaseLines(
      items: state.items,
      targetIndex: index,
      appliedLine: applied,
      nextLineId: _nextPurchaseOrderLineItemId,
    );
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
    final hasParty = state.partyId != null && state.partyId!.isNotEmpty;
    final isValid = state.hasValidLineItems && (!finalize || hasParty);
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  Future<String?> saveOrder({bool finalize = true}) async {
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
        documentType: PurchaseDocumentType.purchaseOrder,
        documentSeries: PurchaseConstants.purchaseOrderSeries,
        documentDate: state.orderDate,
        dueDate: state.dueDate,
        notes: state.description,
        godownId: state.godownId,
        items: state.items,
      );

      late final String savedDocumentId;
      if (finalize) {
        final document = await service.finalizeDocumentDraft(
          input,
          itemNameToId: _itemNameToId(),
          godownId: state.godownId,
        );
        savedDocumentId = document.id;
      } else {
        final document = await service.saveDocumentDraft(
          input,
          itemNameToId: _itemNameToId(),
        );
        savedDocumentId = document.id;
      }

      final synced = await syncTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.purchaseOrder.apiValue,
        entityId: savedDocumentId,
        images: state.attachedImages,
        documents: state.attachedDocuments,
      );
      state = state.copyWith(
        documentId: savedDocumentId,
        attachedImages: synced?.images ?? state.attachedImages,
        attachedDocuments: synced?.documents ?? state.attachedDocuments,
        isSaving: false,
      );

      ref.invalidate(purchaseOrdersProvider);
      await ref.read(purchaseOrdersProvider.notifier).refresh();
      if (finalize) {
        await refreshAfterPurchaseMutation(ref);
      }
      ref
          .read(purchaseOrderSaveSuccessMessageProvider.notifier)
          .setMessage('Purchase order saved successfully');
      ref.invalidateSelf();
      return null;
    } catch (error) {
      final message = PurchaseErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }
}

@riverpod
double addPurchaseOrderTotalTax(Ref ref, {String? orderId}) {
  final form = ref.watch(addPurchaseOrderFormProvider(orderId: orderId));
  return form.totalTax;
}

@riverpod
double addPurchaseOrderGrandTotal(Ref ref, {String? orderId}) {
  final form = ref.watch(addPurchaseOrderFormProvider(orderId: orderId));
  return form.grandTotal;
}
