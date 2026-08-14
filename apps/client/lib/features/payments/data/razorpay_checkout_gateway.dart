import 'dart:async';
import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/payments/application/payment_analytics.dart';
import 'package:billing_baba/features/payments/domain/models/payment_models.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Native Razorpay SDK wrapper — no business logic.
class RazorpayCheckoutGateway {
  RazorpayCheckoutGateway() : _razorpay = Razorpay();

  final Razorpay _razorpay;
  Completer<RazorpayCheckoutCallback?>? _completer;

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<RazorpayCheckoutCallback?> openCheckout({
    required GatewayOrderResult order,
    required Map<String, String> notes,
  }) async {
    if (!isSupported) {
      throw PaymentFailure('Native Razorpay is not supported on this platform');
    }

    _completer = Completer<RazorpayCheckoutCallback?>();
    _razorpay
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    final options = {
      'key': order.razorpayKey,
      'amount': order.amount,
      'currency': order.currency,
      'name': order.merchantName,
      'order_id': order.orderId,
      'description': 'Payment',
      'timeout': order.checkoutTimeout,
      'retry': {'enabled': true, 'max_count': 3},
      'remember_customer': true,
      'send_sms_hash': true,
      'readonly': {'email': false, 'contact': false},
      'prefill': {
        'name': order.customerName,
        'email': order.customerEmail,
        'contact': order.customerContact,
      },
      'theme': {'color': order.themeColor},
      'notes': notes,
    };

    PaymentAnalytics.checkoutOpened(intentId: order.intentId);
    _razorpay.open(options);

    return _completer!.future.timeout(
      Duration(seconds: AppConfig.paymentCheckoutTimeoutSeconds),
      onTimeout: () {
        _complete(null);
        return null;
      },
    );
  }

  void dispose() {
    _razorpay.clear();
    _completer = null;
  }

  void _onSuccess(PaymentSuccessResponse response) {
    PaymentAnalytics.checkoutCompleted(
      intentId: response.orderId ?? '',
    );
    _complete(
      RazorpayCheckoutCallback(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      ),
    );
  }

  void _onError(PaymentFailureResponse response) {
    final code = response.code;
    if (code == Razorpay.PAYMENT_CANCELLED) {
      _complete(null);
      return;
    }
    _completeError(response.message ?? 'Payment failed');
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (AppConfig.paymentLoggingVerbose) {
      PaymentAnalytics.gatewayLatency(phase: 'external_wallet', latencyMs: 0);
    }
  }

  void _complete(RazorpayCheckoutCallback? callback) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(callback);
    }
  }

  void _completeError(String message) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(PaymentFailure(message));
    }
  }
}
