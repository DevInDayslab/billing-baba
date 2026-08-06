import 'dart:convert';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/payments/data/payment_repository.dart';
import 'package:billing_baba/features/payments/data/razorpay_checkout_gateway.dart';
import 'package:billing_baba/features/payments/domain/models/payment_models.dart';

/// Opens native Razorpay checkout — no API or verification logic.
class PaymentCheckoutService {
  PaymentCheckoutService({RazorpayCheckoutGateway? gateway})
    : _gateway = gateway ?? RazorpayCheckoutGateway();

  final RazorpayCheckoutGateway _gateway;

  Future<RazorpayCheckoutCallback?> launch({
    required GatewayOrderResult order,
    required PaymentRepository repository,
  }) async {
    if (!AppConfig.razorpayNative || !RazorpayCheckoutGateway.isSupported) {
      throw const PaymentFailure(
        'Native Razorpay checkout is not available on this device',
      );
    }

    await repository.savePendingSession(
      intentId: order.intentId,
      razorpayOrderId: order.orderId,
      intentPayloadJson: jsonEncode({'intent_id': order.intentId}),
    );

    await repository.markCheckoutOpen(order.intentId);

    try {
      return await _gateway.openCheckout(
        order: order,
        notes: {
          'intent_id': order.intentId,
        },
      );
    } finally {
      _gateway.dispose();
    }
  }

  void dispose() => _gateway.dispose();
}
