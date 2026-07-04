import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_fa_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_form_model.dart';
import 'package:billing_baba/features/purchases/providers/purchase_fa_provider.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_purchase_fa_form_provider.g.dart';

int _purchaseFaLineItemCounter = 0;

String _nextPurchaseFaLineItemId() {
  _purchaseFaLineItemCounter += 1;
  return 'purchase_fa_line_$_purchaseFaLineItemCounter';
}

AddPurchaseFaFormState _defaultFormState({String? batchId}) {
  final now = DateTime.now();
  return AddPurchaseFaFormState(
    batchId: batchId,
    billNumber: 'Auto',
    billDate: DateTime(now.year, now.month, now.day),
    billTime: TimeOfDay.fromDateTime(now),
    dueDate: DateTime(now.year, now.month, now.day),
    items: [FixedAssetLineItem.empty(id: _nextPurchaseFaLineItemId())],
    isLoading: batchId != null,
  );
}

@riverpod
class AddPurchaseFaForm extends _$AddPurchaseFaForm {
  @override
  AddPurchaseFaFormState build({String? batchId}) {
    if (batchId != null) {
      Future.microtask(() => _loadBatch(batchId));
      return _defaultFormState(batchId: batchId);
    }
    return _defaultFormState();
  }

  Future<void> _loadBatch(String batchId) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(purchaseFaServiceProvider.future);
      final loaded = await service.loadForm(batchId);
      state = loaded.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: PurchaseErrorMapper.messageFor(error),
      );
    }
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

  void updateTermsTitle(String value) {
    state = state.copyWith(termsTitle: value, isDirty: true);
  }

  void updateTermsNotes(String value) {
    state = state.copyWith(termsNotes: value, isDirty: true);
  }

  void addLineItem() {
    final items = [
      ...state.items,
      FixedAssetLineItem.empty(id: _nextPurchaseFaLineItemId()),
    ];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(FixedAssetLineItem.empty(id: _nextPurchaseFaLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, FixedAssetLineItem item) {
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

  bool validate() {
    final isValid = state.isValid;
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  Future<String?> save() async {
    if (!validate()) {
      if ((state.partyId == null || state.partyId!.isEmpty) &&
          state.party.trim().isEmpty) {
        return 'Supplier is required';
      }
      return 'Add at least one asset with name and quantity';
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(purchaseFaServiceProvider.future);
      if (state.batchId != null) {
        await service.updateBatch(state.batchId!, state);
      } else {
        final created = await service.createBatch(state);
        state = state.copyWith(batchId: created.batchId);
      }

      ref.invalidate(purchaseFaProvider);
      state = state.copyWith(isSaving: false, isDirty: false);
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
double addPurchaseFaTotalTax(Ref ref, {String? batchId}) {
  final form = ref.watch(addPurchaseFaFormProvider(batchId: batchId));
  return form.totalTax;
}

@riverpod
double addPurchaseFaGrandTotal(Ref ref, {String? batchId}) {
  final form = ref.watch(addPurchaseFaFormProvider(batchId: batchId));
  return form.grandTotal;
}
