class SalesDocumentListQuery {
  const SalesDocumentListQuery({
    this.page = 1,
    this.limit = 20,
    this.documentType,
    this.status,
    this.partyId,
    this.from,
    this.to,
    this.q,
    this.sort = 'document_date',
    this.order = 'desc',
  });

  final int page;
  final int limit;
  final String? documentType;
  final String? status;
  final String? partyId;
  final String? from;
  final String? to;
  final String? q;
  final String sort;
  final String order;

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (documentType != null) 'document_type': documentType,
      if (status != null) 'status': status,
      if (partyId != null) 'party_id': partyId,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (q != null && q!.isNotEmpty) 'q': q,
      'sort': sort,
      'order': order,
    };
  }
}

class CreateSalesDocumentRequest {
  const CreateSalesDocumentRequest({
    required this.documentType,
    required this.documentSeries,
    this.partyId,
    this.isGstFormal = false,
    this.partyStateCode,
    this.documentDate,
    this.convertedFromId,
    this.posSessionId,
    this.notes,
  });

  final String documentType;
  final String documentSeries;
  final String? partyId;
  final bool isGstFormal;
  final String? partyStateCode;
  final String? documentDate;
  final String? convertedFromId;
  final String? posSessionId;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'document_type': documentType,
    'document_series': documentSeries,
    if (partyId != null) 'party_id': partyId,
    'is_gst_formal': isGstFormal,
    if (partyStateCode != null) 'party_state_code': partyStateCode,
    if (documentDate != null) 'document_date': documentDate,
    if (convertedFromId != null) 'converted_from_id': convertedFromId,
    if (posSessionId != null) 'pos_session_id': posSessionId,
    if (notes != null) 'notes': notes,
  };
}

class CreateSalesLineRequest {
  const CreateSalesLineRequest({
    required this.itemId,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    this.marketPrice,
    this.discountAmount = '0',
    this.taxType = 'none',
    this.taxRate = '0',
    this.sortOrder,
  });

  final String itemId;
  final String quantity;
  final String unit;
  final String unitPrice;
  final String? marketPrice;
  final String discountAmount;
  final String taxType;
  final String taxRate;
  final int? sortOrder;

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'quantity': quantity,
    'unit': unit,
    'unit_price': unitPrice,
    if (marketPrice != null) 'market_price': marketPrice,
    'discount_amount': discountAmount,
    'tax_type': taxType,
    'tax_rate': taxRate,
    if (sortOrder != null) 'sort_order': sortOrder,
  };
}

class CreatePaymentRequest {
  const CreatePaymentRequest({
    required this.partyId,
    required this.direction,
    required this.amount,
    required this.paymentMode,
    this.paymentDate,
    this.referenceNumber,
    this.notes,
    this.shortPaymentHandling,
    this.allocations = const [],
    this.source = 'manual',
  });

  final String partyId;
  final String direction;
  final String amount;
  final String paymentMode;
  final String? paymentDate;
  final String? referenceNumber;
  final String? notes;
  final String? shortPaymentHandling;
  final List<PaymentAllocationRequest> allocations;
  final String source;

  Map<String, dynamic> toJson() => {
    'party_id': partyId,
    'direction': direction,
    'amount': amount,
    'payment_mode': paymentMode,
    if (paymentDate != null) 'payment_date': paymentDate,
    if (referenceNumber != null) 'reference_number': referenceNumber,
    if (notes != null) 'notes': notes,
    if (shortPaymentHandling != null)
      'short_payment_handling': shortPaymentHandling,
    'source': source,
    'allocations': allocations.map((a) => a.toJson()).toList(),
  };
}

class PaymentAllocationRequest {
  const PaymentAllocationRequest({
    required this.allocatedAmount,
    this.salesDocumentId,
    this.purchaseDocumentId,
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

class UpdateSalesDocumentRequest {
  const UpdateSalesDocumentRequest({
    this.partyId,
    this.isGstFormal,
    this.partyStateCode,
    this.documentDate,
    this.documentSeries,
    this.notes,
  });

  final String? partyId;
  final bool? isGstFormal;
  final String? partyStateCode;
  final String? documentDate;
  final String? documentSeries;
  final String? notes;

  Map<String, dynamic> toJson() => {
    if (partyId != null) 'party_id': partyId,
    if (isGstFormal != null) 'is_gst_formal': isGstFormal,
    if (partyStateCode != null) 'party_state_code': partyStateCode,
    if (documentDate != null) 'document_date': documentDate,
    if (documentSeries != null) 'document_series': documentSeries,
    if (notes != null) 'notes': notes,
  };
}

class UpdateSalesLineRequest {
  const UpdateSalesLineRequest({
    this.itemId,
    this.quantity,
    this.unit,
    this.unitPrice,
    this.marketPrice,
    this.discountAmount,
    this.taxType,
    this.taxRate,
    this.sortOrder,
  });

  final String? itemId;
  final String? quantity;
  final String? unit;
  final String? unitPrice;
  final String? marketPrice;
  final String? discountAmount;
  final String? taxType;
  final String? taxRate;
  final int? sortOrder;

  Map<String, dynamic> toJson() => {
    if (itemId != null) 'item_id': itemId,
    if (quantity != null) 'quantity': quantity,
    if (unit != null) 'unit': unit,
    if (unitPrice != null) 'unit_price': unitPrice,
    if (marketPrice != null) 'market_price': marketPrice,
    if (discountAmount != null) 'discount_amount': discountAmount,
    if (taxType != null) 'tax_type': taxType,
    if (taxRate != null) 'tax_rate': taxRate,
    if (sortOrder != null) 'sort_order': sortOrder,
  };
}

class PaymentListQuery {
  const PaymentListQuery({
    this.page = 1,
    this.limit = 20,
    this.partyId,
    this.direction,
    this.from,
    this.to,
    this.sort = 'payment_date',
    this.order = 'desc',
  });

  final int page;
  final int limit;
  final String? partyId;
  final String? direction;
  final String? from;
  final String? to;
  final String sort;
  final String order;

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (partyId != null) 'party_id': partyId,
    if (direction != null) 'direction': direction,
    if (from != null) 'from': from,
    if (to != null) 'to': to,
    'sort': sort,
    'order': order,
  };
}

class ConvertSalesDocumentRequest {
  const ConvertSalesDocumentRequest({
    required this.targetType,
    this.applyGst = false,
  });

  final String targetType;
  final bool applyGst;

  Map<String, dynamic> toJson() => {
    'target_type': targetType,
    'apply_gst': applyGst,
  };
}

class UpdatePaymentRequest {
  const UpdatePaymentRequest({
    this.notes,
    this.referenceNumber,
  });

  final String? notes;
  final String? referenceNumber;

  Map<String, dynamic> toJson() => {
    if (notes != null) 'notes': notes,
    if (referenceNumber != null) 'reference_number': referenceNumber,
  };
}
