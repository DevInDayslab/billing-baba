import 'package:billing_baba/features/subscription/domain/models/current_subscription.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_status.dart';
import 'package:billing_baba/features/subscription/domain/subscription_plan_metadata.dart';

/// Offline / API-unavailable catalog built from client metadata overlays.
abstract final class SubscriptionLocalCatalog {
  static const _goldBaseOneYear = 3046.0;
  static const _platinumBaseOneYear = 7742.0;

  static List<SubscriptionPlan> plans() {
    return [
      _planFor(SubscriptionPlanType.gold, _goldBaseOneYear),
      _planFor(SubscriptionPlanType.platinum, _platinumBaseOneYear),
    ];
  }

  static CurrentSubscription currentFallback() {
    return const CurrentSubscription(
      planType: SubscriptionPlanType.none,
      planName: 'No Plan',
      status: SubscriptionStatus.active,
    );
  }

  static SubscriptionPlan _planFor(
    SubscriptionPlanType planType,
    double amount,
  ) {
    final metadata = metadataFor(planType);
    return SubscriptionPlan(
      id: planType.name,
      planType: planType,
      title: planType.displayName,
      description: metadata.description,
      durationDays: 365,
      durationLabel: metadata.durationLabel,
      amount: amount,
      deviceLimit: metadata.deviceLimit,
      licenseType: metadata.licenseType,
      badge: metadata.badge,
      isPopular: metadata.isPopular,
      features: featureNamesFor(planType),
      isActive: true,
    );
  }
}
