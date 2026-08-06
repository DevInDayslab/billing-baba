import 'package:billing_baba/features/payments/domain/payment_intent_type.dart';
import 'package:billing_baba/features/payments/presentation/shared/payment_intent_builder.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('paymentIntentFromPaymentInForm requires party and amount', () {
    expect(
      paymentIntentFromPaymentInForm(
        const PaymentInFormState(receivedAmount: 100),
      ),
      isNull,
    );

    final intent = paymentIntentFromPaymentInForm(
      const PaymentInFormState(
        partyId: 'party-1',
        party: 'Rahul',
        receivedAmount: 4500,
      ),
    );
    expect(intent, isNotNull);
    expect(intent!.type, PaymentIntentType.paymentIn);
    expect(intent.amount, '4500.00');
    expect(intent.partyId, 'party-1');
  });
}
