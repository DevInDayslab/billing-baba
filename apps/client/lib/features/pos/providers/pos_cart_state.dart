import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';

class PosCartState {
  const PosCartState({
    this.items = const [],
    this.customerName,
    this.payments = const [],
    this.heldBills = const [],
    this.warehouseLabel = 'Main Store',
    this.priceListLabel = 'Retail Price',
  });

  final List<CartItem> items;
  final String? customerName;
  final List<PaymentEntry> payments;
  final List<HeldBill> heldBills;
  final String warehouseLabel;
  final String priceListLabel;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.grossTotal);

  double get totalDiscount =>
      items.fold(0, (sum, item) => sum + item.discountAmount);

  double get taxableAmount => subtotal - totalDiscount;

  double get cgst => taxableAmount * 0.09;

  double get sgst => taxableAmount * 0.09;

  double get roundOff {
    final beforeRound = taxableAmount + cgst + sgst;
    final rounded = beforeRound.roundToDouble();
    return rounded - beforeRound;
  }

  double get totalPayable => taxableAmount + cgst + sgst + roundOff;

  double get totalPaid =>
      payments.fold(0, (sum, entry) => sum + entry.amount);

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
  }) {
    return PosCartState(
      items: items ?? this.items,
      customerName:
          clearCustomerName ? null : (customerName ?? this.customerName),
      payments: payments ?? this.payments,
      heldBills: heldBills ?? this.heldBills,
      warehouseLabel: warehouseLabel ?? this.warehouseLabel,
      priceListLabel: priceListLabel ?? this.priceListLabel,
    );
  }
}

double heldBillTotal(List<CartItem> items) {
  final subtotal = items.fold(0.0, (sum, item) => sum + item.grossTotal);
  final discount =
      items.fold(0.0, (sum, item) => sum + item.discountAmount);
  final taxable = subtotal - discount;
  final tax = taxable * 0.18;
  final beforeRound = taxable + tax;
  return beforeRound.roundToDouble();
}
