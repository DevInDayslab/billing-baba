import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_sale_form_provider.g.dart';

int _lineItemCounter = 0;

String _nextLineItemId() {
  _lineItemCounter += 1;
  return 'line_$_lineItemCounter';
}

@riverpod
class AddSaleForm extends _$AddSaleForm {
  @override
  AddSaleFormState build({String? invoiceId}) {
    final invoices = ref.watch(saleInvoicesProvider);
    final now = DateTime.now();
    final invoiceNumber = generateNextInvoiceNumber(
      invoices.map((invoice) => invoice.invoiceNo).toList(),
    );

    // TODO(dev): load existing invoice when invoiceId is provided (edit mode).
    return AddSaleFormState(
      invoiceNumber: invoiceNumber,
      invoiceDate: DateTime(now.year, now.month, now.day),
      invoiceTime: TimeOfDay.fromDateTime(now),
      items: [SaleLineItem.empty(id: _nextLineItemId())],
    );
  }

  void updateBillingName(String value) {
    state = state.copyWith(billingName: value, isDirty: true);
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
      final invoices = ref.read(saleInvoicesProvider);
      final autoNumber = generateNextInvoiceNumber(
        invoices.map((invoice) => invoice.invoiceNo).toList(),
      );
      state = state.copyWith(
        invoiceNumberMode: mode,
        invoiceNumber: autoNumber,
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

  void updateGodown(String value) {
    state = state.copyWith(godown: value, isDirty: true);
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
    // TODO(dev): support multiple payment splits — stub adds a second entry.
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

  bool validate() {
    final isValid = state.hasValidLineItems;
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  SaleInvoiceModel? buildInvoiceModel() {
    if (!validate()) return null;

    final invoices = ref.read(saleInvoicesProvider);
    final nextId = invoices.length + 1;
    final grandTotal = state.grandTotal;
    final received = state.receivedEnabled
        ? state.receivedAmount
        : state.saleType == SaleType.cash
        ? grandTotal
        : 0.0;
    final balance = state.balanceAmount;

    final status = balance <= 0
        ? SaleInvoiceStatus.paid
        : received > 0
        ? SaleInvoiceStatus.partiallyPaid
        : SaleInvoiceStatus.unpaid;

    final date = state.invoiceDate ?? DateTime.now();
    final time = state.invoiceTime ?? TimeOfDay.now();
    final invoiceDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return SaleInvoiceModel(
      id: '$nextId',
      invoiceNo: state.invoiceNumber,
      date: invoiceDateTime,
      partyName: state.billingName.trim().isEmpty
          ? 'Cash Sale'
          : state.billingName.trim(),
      transactionType: 'Sale',
      paymentType: state.paymentType,
      status: status,
      amount: grandTotal,
      balance: balance,
      godown: state.godown,
    );
  }

  void saveInvoice() {
    final invoice = buildInvoiceModel();
    if (invoice == null) return;
    ref.read(saleInvoicesProvider.notifier).addInvoice(invoice);
    ref.invalidateSelf();
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
