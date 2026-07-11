class SaleFaListQuery {
  const SaleFaListQuery({
    this.page = 1,
    this.limit = 20,
    this.q,
    this.partyId,
    this.status,
    this.from,
    this.to,
    this.sort = 'sale_date',
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

class CreateSaleFaAssetRequest {
  const CreateSaleFaAssetRequest({
    required this.assetName,
    required this.salePrice,
    required this.lineTotal,
    this.id,
    this.itemCode,
    this.assetCategory,
    this.serialNumber,
    this.location,
    this.description,
    this.qty,
    this.taxRate,
    this.taxAmount,
    this.sortOrder,
    this.purchaseFixedAssetId,
  });

  final String? id;
  final String assetName;
  final String? itemCode;
  final String? assetCategory;
  final String? serialNumber;
  final String salePrice;
  final String? location;
  final String? description;
  final String? qty;
  final String? taxRate;
  final String? taxAmount;
  final String lineTotal;
  final int? sortOrder;
  final String? purchaseFixedAssetId;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'asset_name': assetName,
    if (itemCode != null) 'item_code': itemCode,
    if (assetCategory != null) 'asset_category': assetCategory,
    if (serialNumber != null) 'serial_number': serialNumber,
    'sale_price': salePrice,
    if (location != null) 'location': location,
    if (description != null) 'description': description,
    if (qty != null) 'qty': qty,
    if (taxRate != null) 'tax_rate': taxRate,
    if (taxAmount != null) 'tax_amount': taxAmount,
    'line_total': lineTotal,
    if (sortOrder != null) 'sort_order': sortOrder,
    if (purchaseFixedAssetId != null)
      'purchase_fixed_asset_id': purchaseFixedAssetId,
  };
}

class CreateSaleFaRequest {
  const CreateSaleFaRequest({
    required this.partyId,
    required this.saleDate,
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
  final String saleDate;
  final String? dueDate;
  final String? paymentMode;
  final String? status;
  final String? notes;
  final String? description;
  final String? subtotal;
  final String? taxAmount;
  final String totalAmount;
  final String? balanceDue;
  final List<CreateSaleFaAssetRequest> assets;

  Map<String, dynamic> toJson() => {
    'party_id': partyId,
    if (referenceNumber != null) 'reference_number': referenceNumber,
    'sale_date': saleDate,
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

class UpdateSaleFaRequest {
  const UpdateSaleFaRequest({
    this.partyId,
    this.referenceNumber,
    this.saleDate,
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
  final String? saleDate;
  final String? dueDate;
  final String? paymentMode;
  final String? status;
  final String? notes;
  final String? description;
  final String? subtotal;
  final String? taxAmount;
  final String? totalAmount;
  final String? balanceDue;
  final List<CreateSaleFaAssetRequest>? assets;

  Map<String, dynamic> toJson() => {
    if (partyId != null) 'party_id': partyId,
    if (referenceNumber != null) 'reference_number': referenceNumber,
    if (saleDate != null) 'sale_date': saleDate,
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
