import 'package:billing_baba/features/subscription/data/subscription_repository.dart';
import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/current_subscription.dart';
import 'package:billing_baba/features/subscription/domain/models/purchase_history.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/domain/models/verify_payment_result.dart';

class SubscriptionService {
  SubscriptionService(this._repository);

  final SubscriptionRepository _repository;

  Future<List<SubscriptionPlan>> getPlans() => _repository.fetchPlans();

  Future<CurrentSubscription> getCurrent() => _repository.fetchCurrent();

  Future<List<PurchaseHistory>> getHistory() => _repository.fetchHistory();

  Future<CreateOrderResult> createOrder(SubscriptionPlanType planType) {
    return _repository.createOrder(planType);
  }

  Future<VerifyPaymentResult> verifyPayment({
    required String paymentUuid,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) {
    return _repository.verifyPayment(
      paymentUuid: paymentUuid,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );
  }
}
