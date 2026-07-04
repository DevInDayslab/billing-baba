import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_sale_form_provider.g.dart';

int _lineItemCounter = 0;

String _nextLineItemId() {
  _lineItemCounter += 1;
  return 'line_$_lineItemCounter';
}

AddSaleFormState _defaultFormState({String? documentId}) {
  final now = DateTime.now();
  return AddSaleFormState(
    documentId: documentId,
    invoiceNumber: 'Auto',
    invoiceDate: DateTime(now.year, now.month, now.day),
    invoiceTime: TimeOfDay.fromDateTime(now),
    items: [SaleLineItem.empty(id: _nextLineItemId())],
    isLoading: documentId != null,
  );
}

@riverpod
class AddSaleForm extends _$AddSaleForm {
  @override
  AddSaleFormState build({String? invoiceId}) {
    if (invoiceId != null) {
      Future.microtask(() => _loadDocument(invoiceId));
      return _defaultFormState(documentId: invoiceId);
    }
    return _defaultFormState();
  }

  Future<void> _loadDocument(String documentId) async {
    if (state.documentId == documentId && !state.isLoading) return;

    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final loaded = await service.loadSaleForm(documentId);
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

  Map<String, String> _itemNameToId() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return {for (final item in items) item.name.trim(): item.id};
  }

  void updateBillingName(String value) {
    state = state.copyWith(billingName: value, isDirty: true, clearSaveError: true);
  }

  void updateParty({required String partyId, required String partyName}) {
    state = state.copyWith(
      partyId: partyId,
      billingName: partyName,
      isDirty: true,
      clearSaveError: true,
    );
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value, isDirty: true);
  }

  void updateAddresses({String? billing, String? shipping}) {
    state = state.copyWith(
      billingAddress: billing ?? state.billingAddress,
      shippingAddress: shipping ?? state.shippingAddress,
      isDirty: true,
    );
  }

  void toggleSaleType(SaleType type) {
    state = state.copyWith(
      saleType: type,
      dueDate: type == SaleType.cash ? null : state.dueDate,
      receivedEnabled: type == SaleType.credit && state.receivedEnabled,
      loyaltyPointsEnabled:
          type == SaleType.credit && state.loyaltyPointsEnabled,
      isDirty: true,
    );
  }

  void updateInvoiceNumber(String value) {
    state = state.copyWith(invoiceNumber: value, isDirty: true);
  }

  void toggleInvoiceNumberMode(InvoiceNumberMode mode) {
    if (mode == InvoiceNumberMode.auto) {
      state = state.copyWith(
        invoiceNumberMode: mode,
        invoiceNumber: 'Auto',
        isDirty: true,
      );
    } else {
      state = state.copyWith(invoiceNumberMode: mode, isDirty: true);
    }
  }

  void updateInvoiceDate(DateTime date) {
    state = state.copyWith(invoiceDate: date, isDirty: true);
  }

  void updateDueDate(DateTime? date) {
    state = state.copyWith(dueDate: date, isDirty: true);
  }

  void updateInvoiceTime(TimeOfDay time) {
    state = state.copyWith(invoiceTime: time, isDirty: true);
  }

  void updateStateOfSupply(String value) {
    state = state.copyWith(stateOfSupply: value, isDirty: true);
  }

  void updateEWayBillNo(String value) {
    state = state.copyWith(eWayBillNo: value, isDirty: true);
  }

  void updateGodown(String value, {String? godownId}) {
    state = state.copyWith(
      godown: value,
      godownId: godownId,
      isDirty: true,
    );
  }

  void addLineItem() {
    final items = [...state.items, SaleLineItem.empty(id: _nextLineItemId())];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(SaleLineItem.empty(id: _nextLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, SaleLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = item;
    state = state.copyWith(items: items, isDirty: true, clearSaveError: true);
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

  void updateReceivedAmount(double value) {
    state = state.copyWith(receivedAmount: value, isDirty: true);
  }

  void toggleReceived({required bool enabled}) {
    state = state.copyWith(
      receivedEnabled: enabled,
      receivedAmount: enabled ? state.receivedAmount : 0,
      isDirty: true,
    );
  }

  void toggleLoyaltyPoints({required bool enabled}) {
    state = state.copyWith(
      loyaltyPointsEnabled: enabled,
      loyaltyPointsUsed: enabled ? state.loyaltyPointsUsed : 0,
      isDirty: true,
    );
  }

  void updateLoyaltyPointsUsed(double value) {
    state = state.copyWith(loyaltyPointsUsed: value, isDirty: true);
  }

  bool validate({bool finalize = false}) {
    final hasLines = state.hasValidLineItems;
    final hasParty = state.partyId != null && state.partyId!.isNotEmpty;

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
      final service = await ref.read(salesServiceProvider.future);
      final document = await service.saveDraft(
        state,
        itemNameToId: _itemNameToId(),
      );
      state = state.copyWith(
        documentId: document.id,
        isSaving: false,
        isDirty: false,
      );
      ref.invalidate(saleInvoicesProvider);
      return null;
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }

  Future<String?> saveInvoice({bool finalize = true}) async {
    if (!validate(finalize: finalize)) {
      if (state.partyId == null || state.partyId!.isEmpty) {
        return 'Party is required';
      }
      return 'Add at least one item with name and quantity';
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);

      if (finalize) {
        await service.createAndFinalizeSale(
          state,
          partyId: state.partyId,
          itemNameToId: _itemNameToId(),
          godownId: state.godownId,
        );
      } else {
        await service.saveDraft(state, itemNameToId: _itemNameToId());
      }

      ref.invalidate(saleInvoicesProvider);
      ref.invalidateSelf();
      return null;
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }
}

@riverpod
double addSaleSubtotal(Ref ref, {String? invoiceId}) {
  final form = ref.watch(addSaleFormProvider(invoiceId: invoiceId));
  return form.subtotal;
}

@riverpod
double addSaleTotalTax(Ref ref, {String? invoiceId}) {
  final form = ref.watch(addSaleFormProvider(invoiceId: invoiceId));
  return form.totalTax;
}

@riverpod
double addSaleGrandTotal(Ref ref, {String? invoiceId}) {
  final form = ref.watch(addSaleFormProvider(invoiceId: invoiceId));
  return form.grandTotal;
}
