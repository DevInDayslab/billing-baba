enum PaymentInStatus {
  paid,
  partial,
  unused,
}

class PaymentInModel {
  const PaymentInModel({
    required this.id,
    required this.receiptNo,
    required this.date,
    required this.partyName,
    required this.paymentType,
    required this.status,
    required this.totalAmount,
    required this.receivedAmount,
    this.partyId,
    this.discount = 0,
    this.description = '',
    this.user = 'Admin',
    this.godown = 'Main Location',
    this.firm = 'Main Firm',
  });

  final String id;
  final String receiptNo;
  final DateTime date;
  final String partyName;
  final String? partyId;
  final String paymentType;
  final PaymentInStatus status;
  final double totalAmount;
  final double receivedAmount;
  final double discount;
  final String description;
  final String user;
  final String godown;
  final String firm;

  double get balanceDue => totalAmount - receivedAmount - discount;

  PaymentInModel copyWith({
    String? id,
    String? receiptNo,
    DateTime? date,
    String? partyName,
    String? partyId,
    String? paymentType,
    PaymentInStatus? status,
    double? totalAmount,
    double? receivedAmount,
    double? discount,
    String? description,
    String? user,
    String? godown,
    String? firm,
  }) {
    return PaymentInModel(
      id: id ?? this.id,
      receiptNo: receiptNo ?? this.receiptNo,
      date: date ?? this.date,
      partyName: partyName ?? this.partyName,
      partyId: partyId ?? this.partyId,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      discount: discount ?? this.discount,
      description: description ?? this.description,
      user: user ?? this.user,
      godown: godown ?? this.godown,
      firm: firm ?? this.firm,
    );
  }
}

class PaymentInSummaryData {
  const PaymentInSummaryData({
    required this.totalAmount,
    required this.receivedAmount,
    this.growthPercent = 0,
  });

  final double totalAmount;
  final double receivedAmount;
  final double growthPercent;
}

class PaginatedPaymentIn {
  const PaginatedPaymentIn({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.summary,
  });

  final List<PaymentInModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final PaymentInSummaryData? summary;

  PaginatedPaymentIn copyWith({
    List<PaymentInModel>? items,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    PaymentInSummaryData? summary,
  }) {
    return PaginatedPaymentIn(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      summary: summary ?? this.summary,
    );
  }
}
