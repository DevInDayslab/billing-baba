import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_history.freezed.dart';

@freezed
abstract class PurchaseHistory with _$PurchaseHistory {
  const factory PurchaseHistory({
    required String id,
    required SubscriptionPlanType oldPlan,
    required SubscriptionPlanType newPlan,
    required String event,
    required DateTime createdAt, Map<String, dynamic>? metadata,
  }) = _PurchaseHistory;
}
