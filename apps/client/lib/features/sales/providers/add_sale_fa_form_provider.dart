import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/sales/application/sale_fa_service.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/sale_fa_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/providers/sale_fa_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_sale_fa_form_provider.g.dart';

int _saleFaLineItemCounter = 0;

String _nextSaleFaLineItemId() {
  _saleFaLineItemCounter += 1;
  return 'sale_fa_line_$_saleFaLineItemCounter';
}

AddSaleFaFormState _defaultFormState() {
  final now = DateTime.now();
  return AddSaleFaFormState(
    invoiceNumber: 'Auto',
    saleDate: DateTime(now.year, now.month, now.day),
    saleTime: TimeOfDay.fromDateTime(now),
    dueDate: DateTime(now.year, now.month, now.day),
    items: [SaleFixedAssetLineItem.empty(id: _nextSaleFaLineItemId())],
  );
}

@riverpod
class AddSaleFaForm extends _$AddSaleFaForm {
  @override
  AddSaleFaFormState build({String sessionKey = 'default'}) {
    return _defaultFormState();
  }

  Future<void> loadBatch(String batchId) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(saleFaServiceProvider.future);
      final loaded = await service.loadForm(batchId);
      state = loaded.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: SalesErrorMapper.messageFor(error),
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
    state = state.copyWith(
      billingName: value,
      isDirty: true,
      clearSaveError: true,
    );
  }

  void updateAddresses({String? billing, String? shipping}) {
    state = state.copyWith(
      billingAddress: billing ?? state.billingAddress,
      shippingAddress: shipping ?? state.shippingAddress,
      isDirty: true,
    );
  }

  void updateEWayBillNo(String value) {
    state = state.copyWith(eWayBillNo: value, isDirty: true);
  }

  void updateInvoiceNumber(String value) {
    state = state.copyWith(invoiceNumber: value, isDirty: true);
  }

  void updateSaleDate(DateTime date) {
    state = state.copyWith(saleDate: date, isDirty: true);
  }

  void updateSaleTime(TimeOfDay time) {
    state = state.copyWith(saleTime: time, isDirty: true);
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
      SaleFixedAssetLineItem.empty(id: _nextSaleFaLineItemId()),
    ];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(SaleFixedAssetLineItem.empty(id: _nextSaleFaLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, SaleFixedAssetLineItem item) {
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
    final payments = [...state.payments, const SalePaymentEntry(type: 'UPI')];
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
        return 'Customer is required';
      }
      return 'Add at least one asset with name and quantity';
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(saleFaServiceProvider.future);
      if (state.batchId != null) {
        await service.updateBatch(state.batchId!, state);
      } else {
        final created = await service.createBatch(state);
        state = state.copyWith(batchId: created.batchId);
      }

      ref.invalidate(saleFaProvider);
      refreshAfterSaleFaMutation(ref);
      state = state.copyWith(isSaving: false, isDirty: false);
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
double addSaleFaTotalTax(Ref ref, {String sessionKey = 'default'}) {
  final form = ref.watch(addSaleFaFormProvider(sessionKey: sessionKey));
  return form.totalTax;
}

@riverpod
double addSaleFaGrandTotal(Ref ref, {String sessionKey = 'default'}) {
  final form = ref.watch(addSaleFaFormProvider(sessionKey: sessionKey));
  return form.grandTotal;
}
