import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/payments/domain/models/payment_models.dart';
import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';

extension CreateOrderResultGatewayX on CreateOrderResult {
  GatewayOrderResult toGatewayOrderResult() {
    return GatewayOrderResult(
      intentId: paymentUuid,
      orderId: razorpayOrderId,
      razorpayKey: razorpayKey,
      amount: amount,
      currency: currency,
      receipt: paymentUuid,
      customerName: ownerName,
      customerEmail: businessEmail,
      customerContact: businessPhone,
      merchantName: businessName,
      themeColor: '#6C3CE9',
      checkoutTimeout: AppConfig.paymentCheckoutTimeoutSeconds,
    );
  }
}
