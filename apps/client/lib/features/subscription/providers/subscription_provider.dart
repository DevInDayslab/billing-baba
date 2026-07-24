import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/subscription/data/subscription_repository.dart';
import 'package:billing_baba/features/subscription/models/subscription_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionRepositoryProvider =
    FutureProvider<SubscriptionRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return SubscriptionRepository(api.dio);
});

final subscriptionPlansProvider =
    AsyncNotifierProvider<SubscriptionPlansNotifier, List<SubscriptionPlanModel>>(
  SubscriptionPlansNotifier.new,
);

final currentSubscriptionProvider =
    AsyncNotifierProvider<CurrentSubscriptionNotifier, CurrentSubscriptionModel>(
  CurrentSubscriptionNotifier.new,
);

final subscriptionHistoryProvider = AsyncNotifierProvider<
    SubscriptionHistoryNotifier, List<SubscriptionHistoryModel>>(
  SubscriptionHistoryNotifier.new,
);

/// True while a subscription purchase (create-order + checkout) is in flight.
final subscriptionPurchaseInProgressProvider =
    NotifierProvider<SubscriptionPurchaseInProgressNotifier, bool>(
  SubscriptionPurchaseInProgressNotifier.new,
);

class SubscriptionPurchaseInProgressNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  bool start() {
    if (state) {
      return false;
    }
    state = true;
    return true;
  }

  void finish() {
    state = false;
  }
}

class SubscriptionPlansNotifier
    extends AsyncNotifier<List<SubscriptionPlanModel>> {
  @override
  Future<List<SubscriptionPlanModel>> build() async {
    final repository = await ref.watch(subscriptionRepositoryProvider.future);
    return repository.fetchPlans();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      return repository.fetchPlans();
    });
  }
}

class CurrentSubscriptionNotifier
    extends AsyncNotifier<CurrentSubscriptionModel> {
  @override
  Future<CurrentSubscriptionModel> build() async {
    final repository = await ref.watch(subscriptionRepositoryProvider.future);
    return repository.fetchCurrent();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      return repository.refreshCurrent();
    });
  }
}

class SubscriptionHistoryNotifier
    extends AsyncNotifier<List<SubscriptionHistoryModel>> {
  @override
  Future<List<SubscriptionHistoryModel>> build() async {
    final repository = await ref.watch(subscriptionRepositoryProvider.future);
    return repository.fetchHistory();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      return repository.fetchHistory();
    });
  }
}

Future<CreateOrderResponseModel> createSubscriptionOrder(
  WidgetRef ref,
  SubscriptionPlanCode plan,
) async {
  final repository = await ref.read(subscriptionRepositoryProvider.future);
  return repository.createOrder(plan);
}
