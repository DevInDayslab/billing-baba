import 'package:billing_baba/features/subscription/data/subscription_api.dart';
import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/current_subscription.dart';
import 'package:billing_baba/features/subscription/domain/models/purchase_history.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_status.dart';
import 'package:billing_baba/features/subscription/domain/models/verify_payment_result.dart';
import 'package:billing_baba/features/subscription/domain/subscription_plan_metadata.dart';

class SubscriptionRepository {
  SubscriptionRepository({required this._api});

  final SubscriptionApi _api;

  Future<List<SubscriptionPlan>> fetchPlans() async {
    final items = await _api.fetchPlans();
    return items
        .where((item) => SubscriptionPlanType.fromApi(item.plan).isPurchasable)
        .map(_mapPlan)
        .toList();
  }

  Future<CurrentSubscription> fetchCurrent() async {
    final dto = await _api.fetchCurrent();
    return _mapCurrent(dto);
  }

  Future<List<PurchaseHistory>> fetchHistory() async {
    final items = await _api.fetchHistory();
    return items.map(_mapHistory).toList();
  }

  Future<CreateOrderResult> createOrder(SubscriptionPlanType planType) {
    return _api.createOrder(planType);
  }

  Future<VerifyPaymentResult> verifyPayment({
    required String paymentUuid,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) {
    return _api.verifyPayment(
      paymentUuid: paymentUuid,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );
  }

  SubscriptionPlan _mapPlan(PlanCatalogItemDto dto) {
    final planType = SubscriptionPlanType.fromApi(dto.plan);
    final metadata = metadataFor(planType);
    final amount = double.tryParse(dto.price) ?? 0;

    return SubscriptionPlan(
      id: planType.name,
      planType: planType,
      title: dto.name,
      description: metadata.description,
      durationDays: dto.durationDays,
      durationLabel: metadata.durationLabel,
      amount: amount,
      deviceLimit: metadata.deviceLimit,
      licenseType: metadata.licenseType,
      badge: metadata.badge,
      isPopular: metadata.isPopular,
      features: featureNamesFor(planType),
      isActive: dto.isActive,
    );
  }

  CurrentSubscription _mapCurrent(CurrentSubscriptionDto dto) {
    return CurrentSubscription(
      planType: SubscriptionPlanType.fromApi(dto.plan),
      planName: dto.planName,
      status: SubscriptionStatus.fromApi(dto.status),
      expiresAt: _parseDate(dto.expiresAt),
      remainingDays: dto.remainingDays,
      purchaseDate: _parseDate(dto.purchaseDate),
      renewalDate: _parseDate(dto.renewalDate),
    );
  }

  PurchaseHistory _mapHistory(SubscriptionHistoryItemDto dto) {
    return PurchaseHistory(
      id: dto.id,
      oldPlan: SubscriptionPlanType.fromApi(dto.oldPlan),
      newPlan: SubscriptionPlanType.fromApi(dto.newPlan),
      event: dto.event,
      metadata: dto.metadata,
      createdAt: DateTime.parse(dto.createdAt).toLocal(),
    );
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.parse(value).toLocal();
  }
}
