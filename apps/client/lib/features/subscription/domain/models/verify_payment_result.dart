import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_payment_result.freezed.dart';

@freezed
abstract class VerifyPaymentResult with _$VerifyPaymentResult {
  const factory VerifyPaymentResult({
    required bool activated,
    required SubscriptionPlanType plan,
    required DateTime expiresAt,
  }) = _VerifyPaymentResult;
}
