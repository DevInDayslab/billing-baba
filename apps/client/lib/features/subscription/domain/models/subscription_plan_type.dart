import 'package:freezed_annotation/freezed_annotation.dart';

enum SubscriptionPlanType {
  @JsonValue('no_plan')
  none,
  @JsonValue('gold')
  gold,
  @JsonValue('platinum')
  platinum;

  static SubscriptionPlanType fromApi(String value) => switch (value) {
    'gold' => SubscriptionPlanType.gold,
    'platinum' => SubscriptionPlanType.platinum,
    _ => SubscriptionPlanType.none,
  };
}

extension SubscriptionPlanTypeX on SubscriptionPlanType {
  String get apiValue => switch (this) {
    SubscriptionPlanType.none => 'no_plan',
    SubscriptionPlanType.gold => 'gold',
    SubscriptionPlanType.platinum => 'platinum',
  };

  String get displayName => switch (this) {
    SubscriptionPlanType.none => 'No Plan',
    SubscriptionPlanType.gold => 'Gold',
    SubscriptionPlanType.platinum => 'Platinum',
  };

  bool get isPurchasable =>
      this == SubscriptionPlanType.gold ||
      this == SubscriptionPlanType.platinum;
}
