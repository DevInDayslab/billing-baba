import 'package:billing_baba/features/sales/models/delivery_challan_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
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

  void openForm() {
    state = _initialChallanFormState().copyWith(isFormOpen: true);
  }

  void resetForm() {
    state = _initialChallanFormState();
  }

  void closeForm() {
    state = state.copyWith(isFormOpen: false);
  }

  void updateParty(String value) {
    state = state.copyWith(party: value);
  }

  void updateGodown(String value) {
    state = state.copyWith(godown: value);
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

  void loadSavedChallan(SavedDeliveryChallan saved) {
    state = DeliveryChallanFormState(
      isFormOpen: true,
      party: saved.party,
      godown: saved.godown,
      challanNo: saved.challanNo,
      invoiceDate: saved.invoiceDate,
      invoiceTime: saved.invoiceTime,
      dueDate: saved.dueDate,
      stateOfSupply: saved.stateOfSupply,
      items: saved.items.isEmpty
          ? [SaleLineItem.empty(id: _nextChallanLineItemId())]
          : List<SaleLineItem>.from(saved.items),
      description: saved.description,
      attachedImages: List<SaleFormAttachment>.from(saved.attachedImages),
      attachedDocuments: List<SaleFormAttachment>.from(saved.attachedDocuments),
      roundOff: saved.roundOff,
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
    final saved = SavedDeliveryChallan.fromFormState(
      id: nextSavedDeliveryChallanId(),
      form: state,
    );
    ref.read(savedDeliveryChallansProvider.notifier).addChallan(saved);
    resetForm();
    return true;
  }
}

@riverpod
class SavedDeliveryChallansNotifier extends _$SavedDeliveryChallansNotifier {
  @override
  List<SavedDeliveryChallan> build() => [];

  void addChallan(SavedDeliveryChallan challan) {
    state = [challan, ...state];
  }

  void removeChallan(String id) {
    state = state.where((challan) => challan.id != id).toList();
  }
}

@riverpod
double deliveryChallanGrandTotal(Ref ref) {
  final form = ref.watch(deliveryChallanFormProvider);
  return form.total;
}
