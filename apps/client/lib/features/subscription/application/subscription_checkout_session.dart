import 'package:billing_baba/features/subscription/application/subscription_mobile_checkout_flow.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/review_order_summary_input.dart';

/// In-memory checkout session preserved across review → payment → retry.
class SubscriptionCheckoutSession {
  const SubscriptionCheckoutSession({
    required this.input,
    this.appliedCouponCode,
    this.couponDiscountOnTaxable = 0,
    this.gstin,
    this.lastTransactionId,
    this.pendingPaymentCredentials,
  });

  final ReviewOrderSummaryInput input;
  final String? appliedCouponCode;
  final double couponDiscountOnTaxable;
  final String? gstin;
  final String? lastTransactionId;
  final SubscriptionPendingPaymentCredentials? pendingPaymentCredentials;

  bool get hasCoupon => appliedCouponCode != null;

  SubscriptionCheckoutSession copyWith({
    ReviewOrderSummaryInput? input,
    String? appliedCouponCode,
    double? couponDiscountOnTaxable,
    String? gstin,
    String? lastTransactionId,
    SubscriptionPendingPaymentCredentials? pendingPaymentCredentials,
    bool clearCoupon = false,
    bool clearGstin = false,
    bool clearTransactionId = false,
    bool clearPendingPayment = false,
  }) {
    return SubscriptionCheckoutSession(
      input: input ?? this.input,
      appliedCouponCode: clearCoupon
          ? null
          : (appliedCouponCode ?? this.appliedCouponCode),
      couponDiscountOnTaxable:
          couponDiscountOnTaxable ?? this.couponDiscountOnTaxable,
      gstin: clearGstin ? null : (gstin ?? this.gstin),
      lastTransactionId: clearTransactionId
          ? null
          : (lastTransactionId ?? this.lastTransactionId),
      pendingPaymentCredentials: clearPendingPayment
          ? null
          : (pendingPaymentCredentials ?? this.pendingPaymentCredentials),
    );
  }
}
