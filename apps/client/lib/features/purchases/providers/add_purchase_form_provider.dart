import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_purchase_form_provider.g.dart';

int _purchaseLineItemCounter = 0;

String _nextPurchaseLineItemId() {
  _purchaseLineItemCounter += 1;
  return 'purchase_line_$_purchaseLineItemCounter';
}

@riverpod
class AddPurchaseForm extends _$AddPurchaseForm {
  @override
  AddPurchaseFormState build() {
    final bills = ref.watch(purchaseBillsProvider);
    final now = DateTime.now();
    final billNumber = generateNextPurchaseBillNumber(
      bills.map((bill) => bill.invoiceNo).toList(),
    );

    return AddPurchaseFormState(
      billNumber: billNumber,
      billDate: DateTime(now.year, now.month, now.day),
      billTime: TimeOfDay.fromDateTime(now),
      dueDate: DateTime(now.year, now.month, now.day),
      items: [PurchaseLineItem.empty(id: _nextPurchaseLineItemId())],
    );
  }

  void updateParty(String value) {
    state = state.copyWith(
      party: value,
      billingName: state.billingName.isEmpty ? value : state.billingName,
      isDirty: true,
    );
  }

  void updateBillingName(String value) {
    state = state.copyWith(billingName: value, isDirty: true);
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

  void updateGodown(String value) {
    state = state.copyWith(godown: value, isDirty: true);
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
      PurchaseLineItem.empty(id: _nextPurchaseLineItemId()),
    ];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(PurchaseLineItem.empty(id: _nextPurchaseLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, PurchaseLineItem item) {
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
      attachedImages:
          state.attachedImages.where((image) => image.id != id).toList(),
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

  PurchaseBillModel? buildBillModel() {
    if (!validate()) return null;

    final bills = ref.read(purchaseBillsProvider);
    final nextId = (bills.length + 1).toString();
    final grandTotal = state.grandTotal;
    final paid = state.paymentAmount;
    final balance = state.balanceAmount;

    final status = balance <= 0
        ? PurchaseBillStatus.paid
        : paid > 0
        ? PurchaseBillStatus.partiallyPaid
        : PurchaseBillStatus.unpaid;

    final date = state.billDate ?? DateTime.now();
    final time = state.billTime ?? TimeOfDay.now();
    final billDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return PurchaseBillModel(
      id: nextId,
      invoiceNo: state.billNumber,
      date: billDateTime,
      partyName: state.billingName.trim().isNotEmpty
          ? state.billingName.trim()
          : state.party.trim(),
      paymentType: state.paymentType,
      status: status,
      amount: grandTotal,
      balanceDue: balance,
      dueDate: state.dueDate ?? billDateTime,
    );
  }

  bool save() {
    final bill = buildBillModel();
    if (bill == null) return false;
    ref.read(purchaseBillsProvider.notifier).addBill(bill);
    ref.invalidateSelf();
    return true;
  }
}

@riverpod
double addPurchaseTotalTax(Ref ref) {
  final form = ref.watch(addPurchaseFormProvider);
  return form.totalTax;
}

@riverpod
double addPurchaseGrandTotal(Ref ref) {
  final form = ref.watch(addPurchaseFormProvider);
  return form.grandTotal;
}
