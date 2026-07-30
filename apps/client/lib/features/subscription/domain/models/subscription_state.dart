import 'package:billing_baba/features/subscription/domain/models/current_subscription.dart';
import 'package:billing_baba/features/subscription/domain/models/purchase_history.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_state.freezed.dart';

@freezed
abstract class SubscriptionState with _$SubscriptionState {
  const SubscriptionState._();

  const factory SubscriptionState.loading() = SubscriptionStateLoading;

  const factory SubscriptionState.refreshing({
    required List<SubscriptionPlan> plans,
    required CurrentSubscription current,
    required List<PurchaseHistory> history,
  }) = SubscriptionStateRefreshing;

  const factory SubscriptionState.loaded({
    required List<SubscriptionPlan> plans,
    required CurrentSubscription current,
    required List<PurchaseHistory> history,
  }) = SubscriptionStateLoaded;

  const factory SubscriptionState.error({
    required String message,
    List<SubscriptionPlan>? plans,
    CurrentSubscription? current,
    List<PurchaseHistory>? history,
  }) = SubscriptionStateError;

  List<SubscriptionPlan>? get plansOrNull => mapOrNull(
    refreshing: (s) => s.plans,
    loaded: (s) => s.plans,
    error: (s) => s.plans,
  );

  CurrentSubscription? get currentOrNull => mapOrNull(
    refreshing: (s) => s.current,
    loaded: (s) => s.current,
    error: (s) => s.current,
  );

  List<PurchaseHistory>? get historyOrNull => mapOrNull(
    refreshing: (s) => s.history,
    loaded: (s) => s.history,
    error: (s) => s.history,
  );

  bool get isNoSubscription =>
      currentOrNull?.hasNoSubscription ?? true;

  bool get isActiveGold => currentOrNull?.isActiveGold ?? false;

  bool get isActivePlatinum => currentOrNull?.isActivePlatinum ?? false;

  bool get isPurchaseHistoryLoaded => historyOrNull != null;
}
