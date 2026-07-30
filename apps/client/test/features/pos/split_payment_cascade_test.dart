import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const total = 5305.0;
  final payments = [
    const PaymentEntry(mode: PaymentMode.cash, amount: 0),
    const PaymentEntry(mode: PaymentMode.upi, amount: 0),
    const PaymentEntry(mode: PaymentMode.card, amount: 0),
  ];

  test('fills next payment with remainder after first entry', () {
    final updated = applySplitPaymentCascade(
      payments: payments,
      editedIndex: 0,
      amount: 258,
      totalPayable: total,
    );

    expect(updated[0].amount, 258);
    expect(updated[1].amount, 5047);
    expect(updated[2].amount, 0);
  });

  test('fills third payment after second partial entry', () {
    final updated = applySplitPaymentCascade(
      payments: applySplitPaymentCascade(
        payments: payments,
        editedIndex: 0,
        amount: 258,
        totalPayable: total,
      ),
      editedIndex: 1,
      amount: 1000,
      totalPayable: total,
    );

    expect(updated[0].amount, 258);
    expect(updated[1].amount, 1000);
    expect(updated[2].amount, 4047);
  });

  test('does not cascade when editing the last payment', () {
    final updated = applySplitPaymentCascade(
      payments: payments,
      editedIndex: 2,
      amount: 1200,
      totalPayable: total,
    );

    expect(updated[2].amount, 1200);
    expect(updated[0].amount, 0);
    expect(updated[1].amount, 0);
  });

  test('clamps next payment to zero when entered amount exceeds total', () {
    final updated = applySplitPaymentCascade(
      payments: payments.take(2).toList(),
      editedIndex: 0,
      amount: 6000,
      totalPayable: total,
    );

    expect(updated[0].amount, 6000);
    expect(updated[1].amount, 0);
  });
}
