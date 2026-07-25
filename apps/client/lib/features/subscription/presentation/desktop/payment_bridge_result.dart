/// Raw outcome from the Razorpay payment host before server verification.
sealed class PaymentBridgeResult {
  const PaymentBridgeResult();
}

class PaymentBridgeCancelled extends PaymentBridgeResult {
  const PaymentBridgeCancelled();
}

class PaymentBridgeFailed extends PaymentBridgeResult {
  const PaymentBridgeFailed(this.message);

  final String message;
}

class PaymentBridgeSuccess extends PaymentBridgeResult {
  const PaymentBridgeSuccess({
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
  });

  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;
}
