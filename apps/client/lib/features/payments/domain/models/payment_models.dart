import 'package:billing_baba/features/payments/domain/payment_intent_type.dart';

class PaymentAllocationIntent {
  const PaymentAllocationIntent({
    this.salesDocumentId,
    this.purchaseDocumentId,
    required this.allocatedAmount,
  });

  final String? salesDocumentId;
  final String? purchaseDocumentId;
  final String allocatedAmount;

  Map<String, dynamic> toJson() => {
    if (salesDocumentId != null) 'sales_document_id': salesDocumentId,
    if (purchaseDocumentId != null) 'purchase_document_id': purchaseDocumentId,
    'allocated_amount': allocatedAmount,
  };
}

class PaymentIntent {
  const PaymentIntent({
    required this.type,
    required this.partyId,
    required this.amount,
    this.discountAmount,
    this.notes,
    this.referenceNumber,
    this.invoiceNumber,
    this.allocations = const [],
    this.partyName,
  });

  final PaymentIntentType type;
  final String partyId;
  final String amount;
  final String? discountAmount;
  final String? notes;
  final String? referenceNumber;
  final String? invoiceNumber;
  final List<PaymentAllocationIntent> allocations;
  final String? partyName;

  Map<String, dynamic> toCreateOrderJson() => {
    'intent_type': type.apiValue,
    'party_id': partyId,
    'amount': amount,
    if (discountAmount != null) 'discount_amount': discountAmount,
    if (notes != null) 'notes': notes,
    if (referenceNumber != null) 'reference_number': referenceNumber,
    if (invoiceNumber != null) 'invoice_number': invoiceNumber,
    if (allocations.isNotEmpty)
      'allocations': allocations.map((a) => a.toJson()).toList(),
  };
}

class GatewayOrderResult {
  const GatewayOrderResult({
    required this.intentId,
    required this.orderId,
    required this.razorpayKey,
    required this.amount,
    required this.currency,
    required this.receipt,
    required this.customerName,
    required this.customerEmail,
    required this.customerContact,
    required this.merchantName,
    required this.themeColor,
    required this.checkoutTimeout,
  });

  factory GatewayOrderResult.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>? ?? {};
    final merchant = json['merchant'] as Map<String, dynamic>? ?? {};
    final theme = json['theme'] as Map<String, dynamic>? ?? {};
    final checkout = json['checkout'] as Map<String, dynamic>? ?? {};
    return GatewayOrderResult(
      intentId: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      razorpayKey: json['razorpay_key'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      receipt: json['receipt'] as String? ?? '',
      customerName: customer['name'] as String? ?? '',
      customerEmail: customer['email'] as String? ?? '',
      customerContact: customer['contact'] as String? ?? '',
      merchantName: merchant['name'] as String? ?? '',
      themeColor: theme['color'] as String? ?? '#6C3CE9',
      checkoutTimeout: checkout['timeout'] as int? ?? 900,
    );
  }

  final String intentId;
  final String orderId;
  final String razorpayKey;
  final int amount;
  final String currency;
  final String receipt;
  final String customerName;
  final String customerEmail;
  final String customerContact;
  final String merchantName;
  final String themeColor;
  final int checkoutTimeout;
}

class RazorpayCheckoutCallback {
  const RazorpayCheckoutCallback({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  final String paymentId;
  final String orderId;
  final String signature;
}

enum PaymentVerificationStatus { verified, failed, pending }

class PaymentVerificationResult {
  const PaymentVerificationResult({
    required this.status,
    this.paymentId,
    this.failureReason,
  });

  factory PaymentVerificationResult.fromJson(Map<String, dynamic> json) {
    final statusRaw = json['status'] as String? ?? 'pending';
    final status = switch (statusRaw) {
      'verified' => PaymentVerificationStatus.verified,
      'failed' => PaymentVerificationStatus.failed,
      _ => PaymentVerificationStatus.pending,
    };
    final payment = json['payment'] as Map<String, dynamic>?;
    return PaymentVerificationResult(
      status: status,
      paymentId: payment?['id'] as String?,
      failureReason: json['failure_reason'] as String?,
    );
  }

  final PaymentVerificationStatus status;
  final String? paymentId;
  final String? failureReason;
}

class PaymentResult {
  const PaymentResult.success({
    required this.intentId,
    required this.accountingPaymentId,
    required this.amountPaise,
  }) : failureReason = null,
       cancelled = false;

  const PaymentResult.failure(this.failureReason)
    : intentId = null,
      accountingPaymentId = null,
      amountPaise = null,
      cancelled = false;

  const PaymentResult.cancelled()
    : intentId = null,
      accountingPaymentId = null,
      amountPaise = null,
      failureReason = null,
      cancelled = true;

  final String? intentId;
  final String? accountingPaymentId;
  final int? amountPaise;
  final String? failureReason;
  final bool cancelled;

  bool get isSuccess => accountingPaymentId != null;
}

class PaymentFailure implements Exception {
  const PaymentFailure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}
