import 'package:billing_baba/features/subscription/application/subscription_service_provider.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_plans_provider.g.dart';

@Riverpod(keepAlive: true)
class SubscriptionPlans extends _$SubscriptionPlans {
  @override
  Future<List<SubscriptionPlan>> build() async {
    final service = await ref.watch(subscriptionServiceProvider.future);
    return service.getPlans();
  }

  Future<void> reload({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = await ref.read(subscriptionServiceProvider.future);
      return service.getPlans();
    });
  }
}
