import 'package:billing_baba/features/subscription/application/subscription_service_provider.dart';
import 'package:billing_baba/features/subscription/domain/models/current_subscription.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_subscription_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentSubscriptionState extends _$CurrentSubscriptionState {
  @override
  Future<CurrentSubscription> build() async {
    final service = await ref.watch(subscriptionServiceProvider.future);
    return service.getCurrent();
  }

  Future<void> reload({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = await ref.read(subscriptionServiceProvider.future);
      return service.getCurrent();
    });
  }
}
