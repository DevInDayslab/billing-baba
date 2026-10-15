export 'package:billing_baba/features/sales/models/requests/sales_requests.dart'
    show CreatePaymentRequest, PaymentAllocationRequest, PaymentListQuery;

class PurchaseDocumentListQuery {
  const PurchaseDocumentListQuery({
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

  Map<String, dynamic> toQueryParameters() => {
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

class CreatePurchaseDocumentRequest {
  const CreatePurchaseDocumentRequest({
    required this.documentType,
    required this.documentSeries,
    required this.partyId,
    this.isGstFormal = false,
    this.partyStateCode,
    this.documentDate,
    this.convertedFromId,
    this.supplierInvoiceNumber,
    this.dueDate,
    this.notes,
  });

  final String documentType;
  final String documentSeries;
  final String partyId;
  final bool isGstFormal;
  final String? partyStateCode;
  final String? documentDate;
  final String? convertedFromId;
  final String? supplierInvoiceNumber;
  final String? dueDate;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'document_type': documentType,
    'document_series': documentSeries,
    'party_id': partyId,
    'is_gst_formal': isGstFormal,
    if (partyStateCode != null) 'party_state_code': partyStateCode,
    if (documentDate != null) 'document_date': documentDate,
    if (convertedFromId != null) 'converted_from_id': convertedFromId,
    if (supplierInvoiceNumber != null)
      'supplier_invoice_number': supplierInvoiceNumber,
    if (dueDate != null) 'due_date': dueDate,
    if (notes != null) 'notes': notes,
  };
}

class UpdatePurchaseDocumentRequest {
  const UpdatePurchaseDocumentRequest({
    this.partyId,
    this.isGstFormal,
    this.partyStateCode,
    this.documentDate,
    this.documentSeries,
    this.supplierInvoiceNumber,
    this.dueDate,
    this.notes,
  });

  final String? partyId;
  final bool? isGstFormal;
  final String? partyStateCode;
  final String? documentDate;
  final String? documentSeries;
  final String? supplierInvoiceNumber;
  final String? dueDate;
  final String? notes;

  Map<String, dynamic> toJson() => {
    if (partyId != null) 'party_id': partyId,
    if (isGstFormal != null) 'is_gst_formal': isGstFormal,
    if (partyStateCode != null) 'party_state_code': partyStateCode,
    if (documentDate != null) 'document_date': documentDate,
    if (documentSeries != null) 'document_series': documentSeries,
    if (supplierInvoiceNumber != null)
      'supplier_invoice_number': supplierInvoiceNumber,
    if (dueDate != null) 'due_date': dueDate,
    if (notes != null) 'notes': notes,
  };
}

class CreatePurchaseLineRequest {
  const CreatePurchaseLineRequest({
    required this.itemId,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    this.discountAmount = '0',
    this.taxType = 'none',
    this.taxRate = '0',
    this.taxInclusive = false,
    this.sortOrder,
  });

  final String itemId;
  final String quantity;
  final String unit;
  final String unitPrice;
  final String discountAmount;
  final String taxType;
  final String taxRate;
  final bool taxInclusive;
  final int? sortOrder;

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'quantity': quantity,
    'unit': unit,
    'unit_price': unitPrice,
    'discount_amount': discountAmount,
    'tax_type': taxType,
    'tax_rate': taxRate,
    'tax_inclusive': taxInclusive,
    if (sortOrder != null) 'sort_order': sortOrder,
  };
}

class UpdatePurchaseLineRequest {
  const UpdatePurchaseLineRequest({
    this.itemId,
    this.quantity,
    this.unit,
    this.unitPrice,
    this.discountAmount,
    this.taxType,
    this.taxRate,
    this.taxInclusive,
    this.sortOrder,
  });

  final String? itemId;
  final String? quantity;
  final String? unit;
  final String? unitPrice;
  final String? discountAmount;
  final String? taxType;
  final String? taxRate;
  final bool? taxInclusive;
  final int? sortOrder;

  Map<String, dynamic> toJson() => {
    if (itemId != null) 'item_id': itemId,
    if (quantity != null) 'quantity': quantity,
    if (unit != null) 'unit': unit,
    if (unitPrice != null) 'unit_price': unitPrice,
    if (discountAmount != null) 'discount_amount': discountAmount,
    if (taxType != null) 'tax_type': taxType,
    if (taxRate != null) 'tax_rate': taxRate,
    if (taxInclusive != null) 'tax_inclusive': taxInclusive,
    if (sortOrder != null) 'sort_order': sortOrder,
  };
}

class ConvertPurchaseDocumentRequest {
  const ConvertPurchaseDocumentRequest({required this.targetType});

  final String targetType;

  Map<String, dynamic> toJson() => {'target_type': targetType};
}

class OtherIncomeListQuery {
  const OtherIncomeListQuery({
    this.page = 1,
    this.limit = 20,
    this.categoryId,
    this.partyId,
    this.from,
    this.to,
    this.sort = 'income_date',
    this.order = 'desc',
  });

  final int page;
  final int limit;
  final String? categoryId;
  final String? partyId;
  final String? from;
  final String? to;
  final String sort;
  final String order;

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (categoryId != null) 'category_id': categoryId,
    if (partyId != null) 'party_id': partyId,
    if (from != null) 'from': from,
    if (to != null) 'to': to,
    'sort': sort,
    'order': order,
  };
}

class CreateOtherIncomeRequest {
  const CreateOtherIncomeRequest({
    required this.categoryId,
    required this.amount,
    required this.incomeDate,
    this.incomeItemId,
    this.partyId,
    this.description,
    this.notes,
    this.referenceNumber,
    this.taxAmount,
    this.taxRate,
    this.attachments,
    this.paymentMode,
    this.bankAccountId,
  });

  final String categoryId;
  final String amount;
  final String incomeDate;
  final String? incomeItemId;
  final String? partyId;
  final String? description;
  final String? notes;
  final String? referenceNumber;
  final String? taxAmount;
  final String? taxRate;
  final List<String>? attachments;
  final String? paymentMode;
  final String? bankAccountId;

  Map<String, dynamic> toJson() => {
    'category_id': categoryId,
    'amount': amount,
    'income_date': incomeDate,
    if (incomeItemId != null) 'income_item_id': incomeItemId,
    if (partyId != null) 'party_id': partyId,
    if (description != null) 'description': description,
    if (notes != null) 'notes': notes,
    if (referenceNumber != null) 'reference_number': referenceNumber,
    if (taxAmount != null) 'tax_amount': taxAmount,
    if (taxRate != null) 'tax_rate': taxRate,
    if (attachments != null && attachments!.isNotEmpty)
      'attachments': attachments,
    if (paymentMode != null) 'payment_mode': paymentMode,
    if (bankAccountId != null && bankAccountId!.isNotEmpty)
      'bank_account_id': bankAccountId,
  };
}

class UpdateOtherIncomeRequest {
  const UpdateOtherIncomeRequest({
    this.categoryId,
    this.amount,
    this.incomeDate,
    this.incomeItemId,
    this.partyId,
    this.description,
    this.notes,
    this.referenceNumber,
    this.taxAmount,
    this.taxRate,
    this.attachments,
    this.paymentMode,
    this.bankAccountId,
  });

  final String? categoryId;
  final String? amount;
  final String? incomeDate;
  final String? incomeItemId;
  final String? partyId;
  final String? description;
  final String? notes;
  final String? referenceNumber;
  final String? taxAmount;
  final String? taxRate;
  final List<String>? attachments;
  final String? paymentMode;
  final String? bankAccountId;

  Map<String, dynamic> toJson() => {
    if (categoryId != null) 'category_id': categoryId,
    if (amount != null) 'amount': amount,
    if (incomeDate != null) 'income_date': incomeDate,
    if (incomeItemId != null) 'income_item_id': incomeItemId,
    if (partyId != null) 'party_id': partyId,
    if (description != null) 'description': description,
    if (notes != null) 'notes': notes,
    if (referenceNumber != null) 'reference_number': referenceNumber,
    if (taxAmount != null) 'tax_amount': taxAmount,
    if (taxRate != null) 'tax_rate': taxRate,
    if (attachments != null) 'attachments': attachments,
    if (paymentMode != null) 'payment_mode': paymentMode,
    if (bankAccountId != null && bankAccountId!.isNotEmpty)
      'bank_account_id': bankAccountId,
  };
}

class CreateIncomeCategoryRequest {
  const CreateIncomeCategoryRequest({
    required this.name,
    this.categoryType = 'direct',
  });

  final String name;
  final String categoryType;

  Map<String, dynamic> toJson() => {
    'name': name,
    'category_type': categoryType,
  };
}

class UpdateIncomeCategoryRequest {
  const UpdateIncomeCategoryRequest({this.name, this.categoryType});

  final String? name;
  final String? categoryType;

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (categoryType != null) 'category_type': categoryType,
  };
}

class CreateIncomeItemRequest {
  const CreateIncomeItemRequest({
    required this.name,
    this.hsnSac,
    this.price = '0',
    this.priceIsTaxInclusive = false,
    this.taxRate = '0',
  });

  final String name;
  final String? hsnSac;
  final String price;
  final bool priceIsTaxInclusive;
  final String taxRate;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (hsnSac != null && hsnSac!.isNotEmpty) 'hsn_sac': hsnSac,
    'price': price,
    'price_is_tax_inclusive': priceIsTaxInclusive,
    'tax_rate': taxRate,
  };
}

class UpdateIncomeItemRequest {
  const UpdateIncomeItemRequest({
    this.name,
    this.hsnSac,
    this.price,
    this.priceIsTaxInclusive,
    this.taxRate,
  });

  final String? name;
  final String? hsnSac;
  final String? price;
  final bool? priceIsTaxInclusive;
  final String? taxRate;

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (hsnSac != null) 'hsn_sac': hsnSac,
    if (price != null) 'price': price,
    if (priceIsTaxInclusive != null)
      'price_is_tax_inclusive': priceIsTaxInclusive,
    if (taxRate != null) 'tax_rate': taxRate,
  };
}
