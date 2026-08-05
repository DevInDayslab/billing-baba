import 'package:billing_baba/features/payments/domain/models/payment_models.dart';
import 'package:billing_baba/features/payments/domain/payment_intent_type.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';

PaymentIntent? paymentIntentFromPaymentInForm(
  PaymentInFormState form, {
  PaymentIntentType type = PaymentIntentType.paymentIn,
}) {
  final partyId = form.partyId;
  if (partyId == null || partyId.isEmpty) return null;
  if (form.receivedAmount <= 0) return null;

  return PaymentIntent(
    type: type,
    partyId: partyId,
    amount: form.receivedAmount.toStringAsFixed(2),
    discountAmount: form.discount > 0
        ? form.discount.toStringAsFixed(2)
        : null,
    notes: form.description.isEmpty ? null : form.description,
    referenceNumber: form.receiptNo.isEmpty ? null : form.receiptNo,
    partyName: form.party,
  );
}
