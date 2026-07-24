import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/subscription/models/subscription_models.dart';
import 'package:dio/dio.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._dio);

  final Dio _dio;

  Future<List<SubscriptionPlanModel>> fetchPlans() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.subscriptionPlans,
    );
    final data = response.data?['data'];
    if (data is! List) {
      throw StateError('Invalid subscription plans response');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(SubscriptionPlanModel.fromJson)
        .toList();
  }

  Future<CurrentSubscriptionModel> fetchCurrent() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.subscriptionCurrent,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid current subscription response');
    }
    return CurrentSubscriptionModel.fromJson(data);
  }

  Future<CurrentSubscriptionModel> refreshCurrent() async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.subscriptionRefresh,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid subscription refresh response');
    }
    return CurrentSubscriptionModel.fromJson(data);
  }

  Future<List<SubscriptionHistoryModel>> fetchHistory() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.subscriptionHistory,
    );
    final data = response.data?['data'];
    if (data is! List) {
      throw StateError('Invalid subscription history response');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(SubscriptionHistoryModel.fromJson)
        .toList();
  }

  Future<CreateOrderResponseModel> createOrder(
    SubscriptionPlanCode plan,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.subscriptionCreateOrder,
      data: {'plan': subscriptionPlanCodeToApi(plan)},
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid create order response');
    }
    return CreateOrderResponseModel.fromJson(data);
  }

  Future<VerifyPaymentResponseModel> verifyPayment({
    required String paymentUuid,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.subscriptionVerify,
      data: {
        'paymentUuid': paymentUuid,
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid verify payment response');
    }
    return VerifyPaymentResponseModel.fromJson(data);
  }
}
