import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/features/payments/domain/payment_intent_type.dart';

abstract final class PaymentAnalytics {
  static void checkoutOpened({required String intentId}) {
    LoggingService.instance.info(
      '[Payment] Checkout opened intentId=$intentId',
    );
  }

  static void checkoutCompleted({required String intentId}) {
    LoggingService.instance.info(
      '[Payment] Checkout completed intentId=$intentId',
    );
  }

  static void verificationStarted({required String intentId}) {
    LoggingService.instance.info(
      '[Payment] Verification started intentId=$intentId',
    );
  }

  static void verificationFinished({
    required String intentId,
    required int latencyMs,
  }) {
    LoggingService.instance.info(
      '[Payment] Verification finished intentId=$intentId latencyMs=$latencyMs',
    );
  }

  static void verificationFailed({
    required String intentId,
    required String reason,
  }) {
    LoggingService.instance.warn(
      '[Payment] Verification failed intentId=$intentId reason=$reason',
    );
  }

  static void recoverySucceeded({
    required String intentId,
    required int retryCount,
  }) {
    LoggingService.instance.info(
      '[Payment] Recovery succeeded intentId=$intentId retries=$retryCount',
    );
  }

  static void gatewayLatency({
    required String phase,
    required int latencyMs,
  }) {
    LoggingService.instance.info(
      '[Payment] Gateway $phase latencyMs=$latencyMs',
    );
  }

  static void stateChanged({
    required PaymentFlowState from,
    required PaymentFlowState to,
  }) {
    LoggingService.instance.debug(
      '[Payment] State $from -> $to',
    );
  }
}
