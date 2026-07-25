import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';

/// Input for the Review Order Summary dialog before Razorpay checkout.
class ReviewOrderSummaryInput {
  const ReviewOrderSummaryInput({
    required this.planType,
    required this.planName,
    required this.platform,
    required this.duration,
    required this.discountedPrice,
    required this.originalPrice,
    required this.licenseType,
    required this.deviceLimit,
    required this.durationLabel,
  });

  final SubscriptionPlanType planType;
  final String planName;
  final PlanPlatform platform;
  final PlanDuration duration;
  final double discountedPrice;
  final double originalPrice;
  final String licenseType;
  final int deviceLimit;
  final String durationLabel;

  String get platformDurationLabel => '${platform.label} • ${duration.label}';

  double get discountAmount =>
      originalPrice > discountedPrice ? originalPrice - discountedPrice : 0;

  /// GST-inclusive total: derive 18% GST component from final price.
  double get gstAmount => discountedPrice - (discountedPrice / 1.18);

  double get taxableAmount => discountedPrice - gstAmount;
}
