class PurchaseFaListQuery {
  const PurchaseFaListQuery({
    this.page = 1,
    this.limit = 20,
    this.q,
    this.partyId,
    this.status,
    this.from,
    this.to,
    this.sort = 'purchase_date',
    this.order = 'desc',
  });

  final int page;
  final int limit;
  final String? q;
  final String? partyId;
  final String? status;
  final String? from;
  final String? to;
  final String sort;
  final String order;

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (q != null && q!.isNotEmpty) 'q': q,
    if (partyId != null) 'party_id': partyId,
    if (status != null) 'status': status,
    if (from != null) 'from': from,
    if (to != null) 'to': to,
    'sort': sort,
    'order': order,
  };
}

class CreatePurchaseFaAssetRequest {
  const CreatePurchaseFaAssetRequest({
    required this.assetName,
    required this.purchasePrice,
    required this.lineTotal,
    this.id,
    this.assetCategory,
    this.serialNumber,
    this.location,
    this.warrantyExpiry,
    this.description,
    this.qty,
    this.taxRate,
    this.taxAmount,
    this.sortOrder,
    this.purchaseDocumentId,
  });

  final String? id;
  final String assetName;
  final String? assetCategory;
  final String? serialNumber;
  final String purchasePrice;
  final String? location;
  final String? warrantyExpiry;
  final String? description;
  final String? qty;
  final String? taxRate;
  final String? taxAmount;
  final String lineTotal;
  final int? sortOrder;
  final String? purchaseDocumentId;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'asset_name': assetName,
    if (assetCategory != null) 'asset_category': assetCategory,
    if (serialNumber != null) 'serial_number': serialNumber,
    'purchase_price': purchasePrice,
    if (location != null) 'location': location,
    if (warrantyExpiry != null) 'warranty_expiry': warrantyExpiry,
    if (description != null) 'description': description,
    if (qty != null) 'qty': qty,
    if (taxRate != null) 'tax_rate': taxRate,
    if (taxAmount != null) 'tax_amount': taxAmount,
    'line_total': lineTotal,
    if (sortOrder != null) 'sort_order': sortOrder,
    if (purchaseDocumentId != null)
      'purchase_document_id': purchaseDocumentId,
  };
}

class CreatePurchaseFaRequest {
  const CreatePurchaseFaRequest({
    required this.partyId,
    required this.purchaseDate,
    required this.totalAmount,
    required this.assets,
    this.referenceNumber,
    this.dueDate,
    this.paymentMode,
    this.status,
    this.notes,
    this.description,
    this.subtotal,
    this.taxAmount,
    this.balanceDue,
  });

  final String partyId;
  final String? referenceNumber;
  final String purchaseDate;
  final String? dueDate;
  final String? paymentMode;
  final String? status;
  final String? notes;
  final String? description;
  final String? subtotal;
  final String? taxAmount;
  final String totalAmount;
  final String? balanceDue;
  final List<CreatePurchaseFaAssetRequest> assets;

  Map<String, dynamic> toJson() => {
    'party_id': partyId,
    if (referenceNumber != null) 'reference_number': referenceNumber,
    'purchase_date': purchaseDate,
    if (dueDate != null) 'due_date': dueDate,
    if (paymentMode != null) 'payment_mode': paymentMode,
    if (status != null) 'status': status,
    if (notes != null) 'notes': notes,
    if (description != null) 'description': description,
    if (subtotal != null) 'subtotal': subtotal,
    if (taxAmount != null) 'tax_amount': taxAmount,
    'total_amount': totalAmount,
    if (balanceDue != null) 'balance_due': balanceDue,
    'assets': assets.map((asset) => asset.toJson()).toList(),
  };
}

class UpdatePurchaseFaRequest {
  const UpdatePurchaseFaRequest({
    this.partyId,
    this.referenceNumber,
    this.purchaseDate,
    this.dueDate,
    this.paymentMode,
    this.status,
    this.notes,
    this.description,
    this.subtotal,
    this.taxAmount,
    this.totalAmount,
    this.balanceDue,
    this.assets,
  });

  final String? partyId;
  final String? referenceNumber;
  final String? purchaseDate;
  final String? dueDate;
  final String? paymentMode;
  final String? status;
  final String? notes;
  final String? description;
  final String? subtotal;
  final String? taxAmount;
  final String? totalAmount;
  final String? balanceDue;
  final List<CreatePurchaseFaAssetRequest>? assets;

  Map<String, dynamic> toJson() => {
    if (partyId != null) 'party_id': partyId,
    if (referenceNumber != null) 'reference_number': referenceNumber,
    if (purchaseDate != null) 'purchase_date': purchaseDate,
    if (dueDate != null) 'due_date': dueDate,
    if (paymentMode != null) 'payment_mode': paymentMode,
    if (status != null) 'status': status,
    if (notes != null) 'notes': notes,
    if (description != null) 'description': description,
    if (subtotal != null) 'subtotal': subtotal,
    if (taxAmount != null) 'tax_amount': taxAmount,
    if (totalAmount != null) 'total_amount': totalAmount,
    if (balanceDue != null) 'balance_due': balanceDue,
    if (assets != null)
      'assets': assets!.map((asset) => asset.toJson()).toList(),
  };
}
