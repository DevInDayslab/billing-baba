import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'current_subscription.freezed.dart';

@freezed
abstract class CurrentSubscription with _$CurrentSubscription {

  const factory CurrentSubscription({
    required SubscriptionPlanType planType,
    required String planName,
    required SubscriptionStatus status,
    DateTime? expiresAt,
    int? remainingDays,
    DateTime? purchaseDate,
    DateTime? renewalDate,
  }) = _CurrentSubscription;
  const CurrentSubscription._();

  bool get hasActivePlan =>
      planType != SubscriptionPlanType.none &&
      status == SubscriptionStatus.active;

  bool get isActiveGold =>
      hasActivePlan && planType == SubscriptionPlanType.gold;

  bool get isActivePlatinum =>
      hasActivePlan && planType == SubscriptionPlanType.platinum;

  bool get hasNoSubscription => !hasActivePlan;
}
