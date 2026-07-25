import 'package:billing_baba/features/subscription/domain/models/purchase_history.dart';
import 'package:billing_baba/features/subscription/presentation/providers/subscription_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_history_provider.g.dart';

@Riverpod(keepAlive: true)
class PurchaseHistoryState extends _$PurchaseHistoryState {
  @override
  Future<List<PurchaseHistory>> build() async {
    final service = await ref.watch(subscriptionServiceProvider.future);
    return service.getHistory();
  }

  Future<void> reload({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = await ref.read(subscriptionServiceProvider.future);
      return service.getHistory();
    });
  }
}
