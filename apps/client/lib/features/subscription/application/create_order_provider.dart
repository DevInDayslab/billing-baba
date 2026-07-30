import 'package:billing_baba/features/subscription/application/subscription_error_mapper.dart';
import 'package:billing_baba/features/subscription/application/subscription_service_provider.dart';
import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_order_provider.g.dart';

@Riverpod(keepAlive: true)
class CreateOrderController extends _$CreateOrderController {
  @override
  AsyncValue<CreateOrderResult?> build() => const AsyncData(null);

  Future<CreateOrderResult?> createOrder(SubscriptionPlanType planType) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(subscriptionServiceProvider.future);
      final result = await service.createOrder(planType);
      debugPrint('create-order response: $result');
      return result;
    });
    return state.asData?.value;
  }

  String? errorMessage() {
    final error = state.error;
    if (error == null) return null;
    return SubscriptionErrorMapper.messageFor(error);
  }
}
