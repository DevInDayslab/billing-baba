import 'dart:async';
import 'dart:convert';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/payments/application/payment_analytics.dart';
import 'package:billing_baba/features/payments/application/payment_checkout_service.dart';
import 'package:billing_baba/features/payments/data/payment_repository.dart';
import 'package:billing_baba/features/payments/domain/models/payment_models.dart';
import 'package:billing_baba/features/payments/domain/payment_intent_type.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Orchestrates create-order → checkout → verify. No UI.
class PaymentService {
  PaymentService({
    required PaymentRepository repository,
    PaymentCheckoutService? checkoutService,
  }) : _repository = repository,
       _checkout = checkoutService ?? PaymentCheckoutService();

  final PaymentRepository _repository;
  final PaymentCheckoutService _checkout;
  final _uuid = const Uuid();
  var _isProcessing = false;

  Future<PaymentResult> pay(PaymentIntent intent) async {
    if (_isProcessing) {
      throw const PaymentFailure('Payment already in progress');
    }
    _isProcessing = true;
    final idempotencyKey = _uuid.v4();

    try {
      final startedAt = DateTime.now();
      final order = await _repository.createOrder(
        body: intent.toCreateOrderJson(),
        idempotencyKey: idempotencyKey,
      );
      PaymentAnalytics.gatewayLatency(
        phase: 'create_order',
        latencyMs: DateTime.now().difference(startedAt).inMilliseconds,
      );

      final callback = await _checkout.launch(
        order: order,
        repository: _repository,
      );

      if (callback == null) {
        return const PaymentResult.cancelled();
      }

      if (callback.paymentId.isEmpty ||
          callback.orderId.isEmpty ||
          callback.signature.isEmpty) {
        return const PaymentResult.failure('Incomplete payment response');
      }

      await _repository.savePendingSession(
        intentId: order.intentId,
        razorpayOrderId: order.orderId,
        intentPayloadJson: jsonEncode(intent.toCreateOrderJson()),
        paymentId: callback.paymentId,
        signature: callback.signature,
      );

      return verifyPending(
        intentId: order.intentId,
        callback: callback,
        amountPaise: order.amount,
      );
    } on PaymentFailure {
      rethrow;
    } on DioException catch (e) {
      return PaymentResult.failure(
        e.response?.data?['error']?['message'] as String? ??
            e.message ??
            'Network error',
      );
    } catch (e) {
      return PaymentResult.failure(e.toString());
    } finally {
      _isProcessing = false;
    }
  }

  Future<PaymentResult> verifyPending({
    required String intentId,
    required RazorpayCheckoutCallback callback,
    int? amountPaise,
  }) async {
    PaymentAnalytics.verificationStarted(intentId: intentId);
    final startedAt = DateTime.now();

    try {
      final result = await _repository
          .verify(intentId: intentId, callback: callback)
          .timeout(
            Duration(seconds: AppConfig.paymentVerificationTimeoutSeconds),
          );

      switch (result.status) {
        case PaymentVerificationStatus.verified:
          await _repository.clearSession(intentId);
          PaymentAnalytics.verificationFinished(
            intentId: intentId,
            latencyMs: DateTime.now().difference(startedAt).inMilliseconds,
          );
          return PaymentResult.success(
            intentId: intentId,
            accountingPaymentId: result.paymentId ?? '',
            amountPaise: amountPaise ?? 0,
          );
        case PaymentVerificationStatus.failed:
          PaymentAnalytics.verificationFailed(
            intentId: intentId,
            reason: result.failureReason ?? 'unknown',
          );
          return PaymentResult.failure(
            result.failureReason ?? 'Payment verification failed',
          );
        case PaymentVerificationStatus.pending:
          return PaymentResult.failure('Verification pending — will retry');
      }
    } on TimeoutException {
      return PaymentResult.failure('Verification timed out — will retry');
    } on DioException catch (e) {
      return PaymentResult.failure(
        e.response?.data?['error']?['message'] as String? ??
            'Verification failed — will retry',
      );
    }
  }
}

/// Riverpod-friendly holder for flow state.
class PaymentFlowController {
  PaymentFlowController();

  PaymentFlowState state = PaymentFlowState.idle;

  void setState(PaymentFlowState next) {
    PaymentAnalytics.stateChanged(from: state, to: next);
    state = next;
  }
}
