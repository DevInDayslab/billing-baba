import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/subscription/application/current_subscription_provider.dart';
import 'package:billing_baba/features/subscription/application/plans_pricing_view_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_session.dart';
import 'package:billing_baba/features/subscription/domain/models/current_subscription.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Updates local subscription state after a successful mock payment.
void activateLocalSubscription(
  Ref ref, {
  required SubscriptionCheckoutSession session,
}) {
  final input = session.input;
  final now = DateTime.now();
  final validityDays = switch (input.duration) {
    PlanDuration.oneYear => 365,
    PlanDuration.threeYears => 365 * 3,
  };
  final expiresAt = now.add(Duration(days: validityDays));

  final subscription = CurrentSubscription(
    planType: input.planType,
    planName: input.planName,
    status: SubscriptionStatus.active,
    expiresAt: expiresAt,
    remainingDays: validityDays,
    purchaseDate: now,
    renewalDate: expiresAt,
  );

  ref
      .read(currentSubscriptionStateProvider.notifier)
      .applyLocalPurchase(subscription);
  ref.read(plansPricingViewProvider.notifier).applyLocalPurchase(subscription);
}
