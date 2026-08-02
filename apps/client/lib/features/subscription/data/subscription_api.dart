import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/subscription/data/subscription_api_errors.dart';
import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/domain/models/verify_payment_result.dart';
import 'package:dio/dio.dart';

class PlanCatalogItemDto {
  const PlanCatalogItemDto({
    required this.plan,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.isActive,
  });

  factory PlanCatalogItemDto.fromJson(Map<String, dynamic> json) {
    return PlanCatalogItemDto(
      plan: json['plan'] as String? ?? 'no_plan',
      name: json['name'] as String? ?? '',
      price: json['price'] as String? ?? '0',
      durationDays: json['durationDays'] as int? ?? 365,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  final String plan;
  final String name;
  final String price;
  final int durationDays;
  final bool isActive;
}

class CurrentSubscriptionDto {
  const CurrentSubscriptionDto({
    required this.plan,
    required this.planName,
    required this.status,
    this.expiresAt,
    this.remainingDays,
    this.purchaseDate,
    this.renewalDate,
  });

  factory CurrentSubscriptionDto.fromJson(Map<String, dynamic> json) {
    return CurrentSubscriptionDto(
      plan: json['plan'] as String? ?? 'no_plan',
      planName: json['planName'] as String? ?? 'No Plan',
      status: json['status'] as String? ?? 'active',
      expiresAt: json['expiresAt'] as String?,
      remainingDays: json['remainingDays'] as int?,
      purchaseDate: json['purchaseDate'] as String?,
      renewalDate: json['renewalDate'] as String?,
    );
  }

  final String plan;
  final String planName;
  final String status;
  final String? expiresAt;
  final int? remainingDays;
  final String? purchaseDate;
  final String? renewalDate;
}

class SubscriptionHistoryItemDto {
  const SubscriptionHistoryItemDto({
    required this.id,
    required this.oldPlan,
    required this.newPlan,
    required this.event,
    required this.createdAt,
    this.metadata,
  });

  factory SubscriptionHistoryItemDto.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    return SubscriptionHistoryItemDto(
      id: json['id'] as String? ?? '',
      oldPlan: json['oldPlan'] as String? ?? 'no_plan',
      newPlan: json['newPlan'] as String? ?? 'no_plan',
      event: json['event'] as String? ?? '',
      metadata: metadata is Map<String, dynamic>
          ? Map<String, dynamic>.from(metadata)
          : null,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  final String id;
  final String oldPlan;
  final String newPlan;
  final String event;
  final Map<String, dynamic>? metadata;
  final String createdAt;
}

class SubscriptionApi {
  SubscriptionApi(this._dio);

  final Dio _dio;

  Future<List<PlanCatalogItemDto>> fetchPlans() async {
    return _run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.subscriptionPlans,
      );
      return _readList(response).map(PlanCatalogItemDto.fromJson).toList();
    });
  }

  Future<CurrentSubscriptionDto> fetchCurrent() async {
    return _run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.subscriptionCurrent,
      );
      return CurrentSubscriptionDto.fromJson(_readData(response));
    });
  }

  Future<List<SubscriptionHistoryItemDto>> fetchHistory() async {
    return _run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.subscriptionHistory,
      );
      return _readList(
        response,
      ).map(SubscriptionHistoryItemDto.fromJson).toList();
    });
  }

  Future<CreateOrderResult> createOrder(SubscriptionPlanType planType) async {
    return _run(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.subscriptionCreateOrder,
        data: {'plan': planType.apiValue},
      );
      return CreateOrderResult.fromJson(_readData(response));
    });
  }

  Future<VerifyPaymentResult> verifyPayment({
    required String paymentUuid,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    return _run(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.subscriptionVerify,
        data: {
          'paymentUuid': paymentUuid,
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );
      final data = _readData(response);
      return VerifyPaymentResult(
        activated: data['activated'] as bool? ?? false,
        plan: SubscriptionPlanType.fromApi(
          data['plan'] as String? ?? 'no_plan',
        ),
        expiresAt: DateTime.parse(data['expiresAt'] as String).toLocal(),
      );
    });
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (error) {
      throwSubscriptionApiError(error);
    }
  }

  Map<String, dynamic> _readData(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid subscription API response',
      );
    }
    return data;
  }

  List<Map<String, dynamic>> _readList(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data?['data'];
    if (data is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid subscription API response',
      );
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(Map<String, dynamic>.from)
        .toList();
  }
}
