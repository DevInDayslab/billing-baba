import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_plan.freezed.dart';

@freezed
abstract class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required SubscriptionPlanType planType,
    required String title,
    required String description,
    required int durationDays,
    required String durationLabel,
    required double amount,
    @Default('INR') String currency,
    required int deviceLimit,
    required String licenseType,
    String? badge,
    @Default(false) bool isPopular,
    @Default(<String>[]) List<String> features,
    @Default(true) bool isActive,
  }) = _SubscriptionPlan;
}
