import 'package:freezed_annotation/freezed_annotation.dart';

enum SubscriptionStatus {
  @JsonValue('active')
  active,
  @JsonValue('expired')
  expired,
  @JsonValue('pending')
  pending,
  @JsonValue('cancelled')
  cancelled;

  static SubscriptionStatus fromApi(String value) => switch (value) {
    'expired' => SubscriptionStatus.expired,
    'pending' => SubscriptionStatus.pending,
    'cancelled' => SubscriptionStatus.cancelled,
    _ => SubscriptionStatus.active,
  };
}
