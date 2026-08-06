import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/payments/domain/models/payment_models.dart';
import 'package:dio/dio.dart';

class PaymentApi {
  PaymentApi(this._dio);

  final Dio _dio;

  Future<GatewayOrderResult> createOrder({
    required Map<String, dynamic> body,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.paymentGatewayCreateOrder,
      data: body,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    final data = response.data?['data'] as Map<String, dynamic>? ?? {};
    return GatewayOrderResult.fromJson(data);
  }

  Future<PaymentVerificationResult> verify({
    required String intentId,
    required String paymentId,
    required String orderId,
    required String signature,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.paymentGatewayVerify,
      data: {
        'intent_id': intentId,
        'payment_id': paymentId,
        'order_id': orderId,
        'signature': signature,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    final data = response.data?['data'] as Map<String, dynamic>? ?? {};
    return PaymentVerificationResult.fromJson(data);
  }

  Future<PaymentVerificationResult> getStatus(String intentId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.paymentGatewayStatus(intentId),
    );
    final data = response.data?['data'] as Map<String, dynamic>? ?? {};
    final status = data['status'] as String? ?? 'created';
    final payment = data['payment'] as Map<String, dynamic>?;
    return PaymentVerificationResult(
      status: switch (status) {
        'verified' => PaymentVerificationStatus.verified,
        'failed' || 'cancelled' || 'expired' => PaymentVerificationStatus.failed,
        _ => PaymentVerificationStatus.pending,
      },
      paymentId: payment?['id'] as String?,
      failureReason: data['failure_reason'] as String?,
    );
  }

  Future<void> markCheckoutOpen(String intentId) async {
    await _dio.post<void>(ApiEndpoints.paymentGatewayCheckoutOpen(intentId));
  }
}
