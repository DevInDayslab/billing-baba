enum SubscriptionPlanCode { noPlan, gold, platinum }

enum SubscriptionStatusCode { active, expired, pending, cancelled }

SubscriptionPlanCode subscriptionPlanCodeFromApi(String value) {
  return switch (value) {
    'gold' => SubscriptionPlanCode.gold,
    'platinum' => SubscriptionPlanCode.platinum,
    _ => SubscriptionPlanCode.noPlan,
  };
}

String subscriptionPlanCodeToApi(SubscriptionPlanCode plan) {
  return switch (plan) {
    SubscriptionPlanCode.gold => 'gold',
    SubscriptionPlanCode.platinum => 'platinum',
    SubscriptionPlanCode.noPlan => 'no_plan',
  };
}

SubscriptionStatusCode subscriptionStatusCodeFromApi(String value) {
  return switch (value) {
    'expired' => SubscriptionStatusCode.expired,
    'pending' => SubscriptionStatusCode.pending,
    'cancelled' => SubscriptionStatusCode.cancelled,
    _ => SubscriptionStatusCode.active,
  };
}

class SubscriptionPlanModel {
  const SubscriptionPlanModel({
    required this.plan,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.isActive,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      plan: subscriptionPlanCodeFromApi(json['plan'] as String? ?? 'no_plan'),
      name: json['name'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      durationDays: json['durationDays'] as int? ??
          json['duration_days'] as int? ??
          0,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? false,
    );
  }

  final SubscriptionPlanCode plan;
  final String name;
  final double price;
  final int durationDays;
  final bool isActive;
}

class CurrentSubscriptionModel {
  const CurrentSubscriptionModel({
    required this.plan,
    required this.planName,
    required this.status,
    this.expiresAt,
    this.remainingDays,
    this.purchaseDate,
    this.renewalDate,
  });

  factory CurrentSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return CurrentSubscriptionModel(
      plan: subscriptionPlanCodeFromApi(json['plan'] as String? ?? 'no_plan'),
      planName: json['planName'] as String? ??
          json['plan_name'] as String? ??
          'No Plan',
      status: subscriptionStatusCodeFromApi(
        json['status'] as String? ?? 'active',
      ),
      expiresAt: _parseDate(json['expiresAt'] ?? json['expires_at']),
      remainingDays: json['remainingDays'] as int? ??
          json['remaining_days'] as int?,
      purchaseDate: _parseDate(json['purchaseDate'] ?? json['purchase_date']),
      renewalDate: _parseDate(json['renewalDate'] ?? json['renewal_date']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  final SubscriptionPlanCode plan;
  final String planName;
  final SubscriptionStatusCode status;
  final DateTime? expiresAt;
  final int? remainingDays;
  final DateTime? purchaseDate;
  final DateTime? renewalDate;

  bool get hasPaidPlan =>
      plan == SubscriptionPlanCode.gold ||
      plan == SubscriptionPlanCode.platinum;
}

class SubscriptionHistoryModel {
  const SubscriptionHistoryModel({
    required this.id,
    required this.oldPlan,
    required this.newPlan,
    required this.event,
    required this.createdAt,
    this.metadata,
  });

  factory SubscriptionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryModel(
      id: json['id'] as String? ?? '',
      oldPlan: subscriptionPlanCodeFromApi(
        json['oldPlan'] as String? ?? json['old_plan'] as String? ?? 'no_plan',
      ),
      newPlan: subscriptionPlanCodeFromApi(
        json['newPlan'] as String? ?? json['new_plan'] as String? ?? 'no_plan',
      ),
      event: json['event'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ??
              json['created_at']?.toString() ??
              '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final SubscriptionPlanCode oldPlan;
  final SubscriptionPlanCode newPlan;
  final String event;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
}

class CreateOrderResponseModel {
  const CreateOrderResponseModel({
    required this.paymentUuid,
    required this.razorpayOrderId,
    required this.razorpayKey,
    required this.amount,
    required this.currency,
    required this.businessName,
    required this.ownerName,
    required this.businessEmail,
    required this.businessPhone,
  });

  factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponseModel(
      paymentUuid: json['paymentUuid'] as String? ??
          json['payment_uuid'] as String? ??
          json['paymentId'] as String? ??
          json['payment_id'] as String? ??
          '',
      razorpayOrderId: json['razorpayOrderId'] as String? ??
          json['razorpay_order_id'] as String? ??
          '',
      razorpayKey: json['razorpayKey'] as String? ??
          json['razorpay_key'] as String? ??
          '',
      amount: json['amount'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      businessName: json['businessName'] as String? ??
          json['business_name'] as String? ??
          'Billing Baba',
      ownerName: json['ownerName'] as String? ??
          json['owner_name'] as String? ??
          '',
      businessEmail: json['businessEmail'] as String? ??
          json['business_email'] as String? ??
          '',
      businessPhone: json['businessPhone'] as String? ??
          json['business_phone'] as String? ??
          '',
    );
  }

  final String paymentUuid;
  final String razorpayOrderId;
  final String razorpayKey;
  final int amount;
  final String currency;
  final String businessName;
  final String ownerName;
  final String businessEmail;
  final String businessPhone;

  double get amountInRupees => amount / 100;
}

class VerifyPaymentResponseModel {
  const VerifyPaymentResponseModel({
    required this.activated,
    required this.plan,
    required this.expiresAt,
  });

  factory VerifyPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentResponseModel(
      activated: json['activated'] as bool? ?? false,
      plan: subscriptionPlanCodeFromApi(json['plan'] as String? ?? 'no_plan'),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ??
              json['expires_at']?.toString() ??
              '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final bool activated;
  final SubscriptionPlanCode plan;
  final DateTime expiresAt;
}
