import 'package:flutter/material.dart';

enum PricingPlanType { gold, platinum }

enum PlanPlatform { desktopMobile, desktop, mobile }

enum PlanDuration { oneYear, threeYears }

extension PlanPlatformLabel on PlanPlatform {
  String get label => switch (this) {
    PlanPlatform.desktopMobile => 'Desktop + Mobile',
    PlanPlatform.desktop => 'Desktop',
    PlanPlatform.mobile => 'Mobile',
  };
}

extension PlanDurationLabel on PlanDuration {
  String get label => switch (this) {
    PlanDuration.oneYear => '1 Year',
    PlanDuration.threeYears => '3 Years',
  };
}

typedef PlanPriceKey = (PlanPlatform, PlanDuration);

class PlanFeature {
  const PlanFeature({
    required this.name,
    this.goldIncluded,
    this.platinumIncluded,
    this.goldValue,
    this.platinumValue,
    this.category,
  });

  final String name;
  final bool? goldIncluded;
  final bool? platinumIncluded;
  final String? goldValue;
  final String? platinumValue;
  final String? category;

  bool get isCategoryHeader => category != null;
}

class PlanPricing {
  const PlanPricing({
    required this.originalPrice,
    required this.discountedPrice,
    required this.perMonthPrice,
    required this.ctaLabel,
  });

  final double originalPrice;
  final double discountedPrice;
  final double perMonthPrice;
  final String ctaLabel;
}

class PricingPlan {
  const PricingPlan({
    required this.name,
    required this.isMostPopular,
    required this.pricing,
    required this.featuresByPlatform,
  });

  final String name;
  final bool isMostPopular;
  final Map<PlanPriceKey, PlanPricing> pricing;
  final Map<PlanPlatform, List<PlanFeature>> featuresByPlatform;

  bool get isGold => name == 'Gold';

  PlanPricing pricingFor(PlanPlatform platform, PlanDuration duration) =>
      pricing[(platform, duration)]!;
}

class AddonPricing {
  const AddonPricing({
    required this.originalPrice,
    required this.discountedPrice,
  });

  final double originalPrice;
  final double discountedPrice;
}

class AddonPlan {
  const AddonPlan({
    required this.id,
    required this.name,
    required this.pricing,
    this.isHighlighted = false,
    this.icon = Icons.change_history,
    this.iconColor = const Color(0xFFE65100),
    this.iconBgColor = const Color(0xFFFFF3E0),
  });

  final String id;
  final String name;
  final Map<PlanPriceKey, AddonPricing> pricing;
  final bool isHighlighted;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  AddonPricing pricingFor(PlanPlatform platform, PlanDuration duration) =>
      pricing[(platform, duration)]!;
}
