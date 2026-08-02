import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';

class PosCartState {
  const PosCartState({
    this.items = const [],
    this.customerName,
    this.payments = const [],
    this.heldBills = const [],
    this.warehouseLabel = 'Main Store',
    this.priceListLabel = 'Retail Price',
    this.billDiscountPercent = 0,
  });

  final List<CartItem> items;
  final String? customerName;
  final List<PaymentEntry> payments;
  final List<HeldBill> heldBills;
  final String warehouseLabel;
  final String priceListLabel;
  final double billDiscountPercent;

  double get subtotal => items.fold(0, (sum, item) => sum + item.grossTotal);

  double get totalDiscount =>
      items.fold(0, (sum, item) => sum + item.discountAmount);

  double get taxableAmount => subtotal - totalDiscount;

  double get billDiscountAmount => taxableAmount * billDiscountPercent / 100;

  double get taxableAfterBillDiscount => taxableAmount - billDiscountAmount;

  double get cgst => taxableAfterBillDiscount * 0.09;

  double get sgst => taxableAfterBillDiscount * 0.09;

  double get totalTax => cgst + sgst;

  double get roundOff {
    final beforeRound = taxableAfterBillDiscount + totalTax;
    final rounded = beforeRound.roundToDouble();
    return rounded - beforeRound;
  }

  double get totalPayable =>
      subtotal - totalDiscount - billDiscountAmount + totalTax + roundOff;

  double get totalPaid => payments.fold(0, (sum, entry) => sum + entry.amount);

  double get balance => totalPaid - totalPayable;

  int get totalItems => items.length;

  int get totalQty => items.fold(0, (sum, item) => sum + item.quantity);

  PosCartState copyWith({
    List<CartItem>? items,
    String? customerName,
    bool clearCustomerName = false,
    List<PaymentEntry>? payments,
    List<HeldBill>? heldBills,
    String? warehouseLabel,
    String? priceListLabel,
    double? billDiscountPercent,
  }) {
    return PosCartState(
      items: items ?? this.items,
      customerName: clearCustomerName
          ? null
          : (customerName ?? this.customerName),
      payments: payments ?? this.payments,
      heldBills: heldBills ?? this.heldBills,
      warehouseLabel: warehouseLabel ?? this.warehouseLabel,
      priceListLabel: priceListLabel ?? this.priceListLabel,
      billDiscountPercent: billDiscountPercent ?? this.billDiscountPercent,
    );
  }
}

/// After editing a split-payment row, fill the next row with the remaining
/// balance and clear any rows after that.
List<PaymentEntry> applySplitPaymentCascade({
  required List<PaymentEntry> payments,
  required int editedIndex,
  required double amount,
  required double totalPayable,
}) {
  if (editedIndex < 0 || editedIndex >= payments.length) return payments;

  final updated = [
    for (final payment in payments) payment.copyWith(),
  ];
  updated[editedIndex] = updated[editedIndex].copyWith(amount: amount);

  if (payments.length <= 1 || editedIndex >= payments.length - 1) {
    return updated;
  }

  final allocated = updated
      .take(editedIndex + 1)
      .fold<double>(0, (sum, payment) => sum + payment.amount);
  final remainder = (totalPayable - allocated).clamp(0.0, double.infinity);
  updated[editedIndex + 1] = updated[editedIndex + 1].copyWith(
    amount: remainder,
  );

  for (var index = editedIndex + 2; index < updated.length; index++) {
    updated[index] = updated[index].copyWith(amount: 0);
  }

  return updated;
}

double heldBillTotal(List<CartItem> items) {
  final subtotal = items.fold<double>(0, (sum, item) => sum + item.grossTotal);
  final discount = items.fold<double>(
    0,
    (sum, item) => sum + item.discountAmount,
  );
  final taxable = subtotal - discount;
  final tax = taxable * 0.18;
  final beforeRound = taxable + tax;
  return beforeRound.roundToDouble();
}
