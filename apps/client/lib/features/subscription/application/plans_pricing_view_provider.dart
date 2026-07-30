import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/subscription/application/current_subscription_provider.dart';
import 'package:billing_baba/features/subscription/application/plans_pricing_mapper.dart';
import 'package:billing_baba/features/subscription/application/subscription_local_catalog.dart';
import 'package:billing_baba/features/subscription/application/subscription_plans_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_service.dart';
import 'package:billing_baba/features/subscription/application/subscription_service_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_service_types.dart';
import 'package:billing_baba/features/subscription/domain/models/current_subscription.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plans_pricing_view_provider.g.dart';

@Riverpod(keepAlive: true)
class PlansPricingView extends _$PlansPricingView {
  @override
  Future<PlansPricingViewData> build() async {
    // Rebuild when the active business changes without awaiting invalidated [.future].
    ref.watch(currentBusinessProvider)?.id;
    return _loadViewData();
  }

  Future<void> reload({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(_loadViewData);
  }

  /// Frontend-only: refresh plans UI after a mock purchase.
  void applyLocalPurchase(CurrentSubscription current) {
    final plans = ref.read(subscriptionPlansProvider).value ??
        SubscriptionLocalCatalog.plans();
    _syncChildProviders(plans: plans, current: current);
    state = AsyncData(PlansPricingMapper.build(plans: plans, current: current));
  }

  Future<PlansPricingViewData> _loadViewData() async {
    final service = await ref.read(subscriptionServiceProvider.future);

    final results = await Future.wait([
      _loadPlans(service),
      _loadCurrent(service),
    ]);
    final plans = results[0] as List<SubscriptionPlan>;
    final current = results[1] as CurrentSubscription;

    _syncChildProviders(plans: plans, current: current);

    return PlansPricingMapper.build(plans: plans, current: current);
  }

  Future<List<SubscriptionPlan>> _loadPlans(SubscriptionService service) async {
    try {
      return await service.getPlans();
    } on Object catch (error) {
      if (_shouldUseLocalCatalog(error)) {
        return SubscriptionLocalCatalog.plans();
      }
      throw error;
    }
  }

  Future<CurrentSubscription> _loadCurrent(SubscriptionService service) async {
    try {
      return await service.getCurrent();
    } on Object catch (error) {
      if (_shouldUseLocalCatalog(error) ||
          error is SubscriptionValidationException) {
        return SubscriptionLocalCatalog.currentFallback();
      }
      throw error;
    }
  }

  void _syncChildProviders({
    required List<SubscriptionPlan> plans,
    required CurrentSubscription current,
  }) {
    ref.read(subscriptionPlansProvider.notifier).state = AsyncData(plans);
    ref.read(currentSubscriptionStateProvider.notifier).state = AsyncData(
      current,
    );
  }

  bool _shouldUseLocalCatalog(Object error) {
    if (error is SubscriptionUnavailableException) return true;
    if (error is! DioException) return false;

    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.response?.statusCode == 503;
  }
}
