import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pauses background sync while Razorpay checkout is active.
final paymentCheckoutBusyProvider =
    NotifierProvider<PaymentCheckoutBusy, bool>(PaymentCheckoutBusy.new);

class PaymentCheckoutBusy extends Notifier<bool> {
  @override
  bool build() => false;

  void begin() => state = true;

  void end() => state = false;
}
