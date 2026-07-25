import 'package:billing_baba/features/subscription/application/plans_pricing_mapper.dart';
import 'package:billing_baba/features/subscription/application/current_subscription_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_plans_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plans_pricing_view_provider.g.dart';

@Riverpod(keepAlive: true)
class PlansPricingView extends _$PlansPricingView {
  @override
  Future<PlansPricingViewData> build() async {
    final plans = await ref.watch(subscriptionPlansProvider.future);
    final current = await ref.watch(currentSubscriptionStateProvider.future);
    return PlansPricingMapper.build(plans: plans, current: current);
  }

  Future<void> reload({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      await Future.wait([
        ref.read(subscriptionPlansProvider.notifier).reload(showLoading: false),
        ref
            .read(currentSubscriptionStateProvider.notifier)
            .reload(showLoading: false),
      ]);
      final plans = await ref.read(subscriptionPlansProvider.future);
      final current = await ref.read(currentSubscriptionStateProvider.future);
      return PlansPricingMapper.build(plans: plans, current: current);
    });
  }
}
