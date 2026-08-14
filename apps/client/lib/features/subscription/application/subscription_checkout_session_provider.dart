import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/subscription/application/mock_coupon_service.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_session.dart';
import 'package:billing_baba/features/subscription/application/subscription_mobile_checkout_flow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionCheckoutSessionProvider =
    NotifierProvider<
      SubscriptionCheckoutSessionNotifier,
      SubscriptionCheckoutSession?
    >(
      SubscriptionCheckoutSessionNotifier.new,
    );

class SubscriptionCheckoutSessionNotifier
    extends Notifier<SubscriptionCheckoutSession?> {
  static const _couponService = MockCouponService();

  @override
  SubscriptionCheckoutSession? build() => null;

  void startSession(SubscriptionCheckoutSession session) {
    state = session;
  }

  void updateGstin(String? gstin) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(
      gstin: gstin?.trim().isEmpty ?? true ? null : gstin?.trim(),
      clearGstin: gstin == null || gstin.trim().isEmpty,
    );
  }

  String? applyCoupon(String code) {
    if (!AppConfig.subscriptionMockPayment) {
      return 'Coupons are not available for online checkout yet.';
    }

    final current = state;
    if (current == null) return 'No active checkout session.';

    final taxableBase = current.input.discountedPrice / 1.18;
    final validation = _couponService.validate(
      code: code,
      taxableBase: taxableBase,
    );

    switch (validation) {
      case MockCouponValid(:final code, :final discountOnTaxable):
        state = current.copyWith(
          appliedCouponCode: code,
          couponDiscountOnTaxable: discountOnTaxable,
        );
        return null;
      case MockCouponInvalid(:final message):
        return message;
    }
  }

  void removeCoupon() {
    final current = state;
    if (current == null) return;
    state = current.copyWith(clearCoupon: true, couponDiscountOnTaxable: 0);
  }

  void recordTransactionId(String? transactionId) {
    final current = state;
    if (current == null || transactionId == null || transactionId.isEmpty) {
      return;
    }
    state = current.copyWith(lastTransactionId: transactionId);
  }

  void recordPendingPayment(SubscriptionPendingPaymentCredentials credentials) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(pendingPaymentCredentials: credentials);
  }

  void clearSession() {
    state = null;
  }
}
