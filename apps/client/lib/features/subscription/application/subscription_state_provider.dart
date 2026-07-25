import 'package:billing_baba/features/subscription/domain/models/subscription_state.dart';
import 'package:billing_baba/features/subscription/application/current_subscription_provider.dart';
import 'package:billing_baba/features/subscription/application/purchase_history_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_plans_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_state_provider.g.dart';

@Riverpod(keepAlive: true)
class SubscriptionStateController extends _$SubscriptionStateController {
  @override
  Future<SubscriptionState> build() async {
    return _loadAll();
  }

  Future<SubscriptionState> _loadAll() async {
    final plans = await ref.watch(subscriptionPlansProvider.future);
    final current = await ref.watch(currentSubscriptionStateProvider.future);
    final history = await ref.watch(purchaseHistoryStateProvider.future);

    return SubscriptionState.loaded(
      plans: plans,
      current: current,
      history: history,
    );
  }

  Future<void> refresh({bool showLoading = true}) async {
    final previous = state.asData?.value;
    if (!showLoading && previous != null) {
      previous.whenOrNull(
        loaded: (plans, current, history) {
          state = AsyncData(
            SubscriptionState.refreshing(
              plans: plans,
              current: current,
              history: history,
            ),
          );
        },
        refreshing: (plans, current, history) {
          state = AsyncData(
            SubscriptionState.refreshing(
              plans: plans,
              current: current,
              history: history,
            ),
          );
        },
      );
    } else if (showLoading) {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(() async {
      await Future.wait([
        ref.read(subscriptionPlansProvider.notifier).reload(showLoading: false),
        ref
            .read(currentSubscriptionStateProvider.notifier)
            .reload(showLoading: false),
        ref.read(purchaseHistoryStateProvider.notifier).reload(showLoading: false),
      ]);
      return _loadAll();
    });
  }
}
