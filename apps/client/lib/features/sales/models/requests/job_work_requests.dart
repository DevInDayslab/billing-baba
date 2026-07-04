class JobWorkOrderListQuery {
  const JobWorkOrderListQuery({
    this.page = 1,
    this.limit = 20,
    this.status,
    this.partyId,
    this.sort = 'order_date',
    this.order = 'desc',
  });

  final int page;
  final int limit;
  final String? status;
  final String? partyId;
  final String sort;
  final String order;

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (status != null) 'status': status,
    if (partyId != null) 'party_id': partyId,
    'sort': sort,
    'order': order,
  };
}

class JobWorkRawMaterialRequest {
  const JobWorkRawMaterialRequest({
    required this.itemId,
    required this.quantity,
    required this.unit,
    this.purchasePrice = '0',
  });

  final String itemId;
  final String quantity;
  final String unit;
  final String purchasePrice;

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'quantity': quantity,
    'unit': unit,
    'purchase_price': purchasePrice,
  };
}

class JobWorkAdditionalCostRequest {
  const JobWorkAdditionalCostRequest({
    required this.label,
    required this.amount,
  });

  final String label;
  final String amount;

  Map<String, dynamic> toJson() => {
    'label': label,
    'amount': amount,
  };
}

class CreateJobWorkOrderRequest {
  const CreateJobWorkOrderRequest({
    required this.finishedGoodName,
    this.partyId,
    this.jobNumber,
    this.orderDate,
    this.deliveryDate,
    this.finishedGoodQuantity = '1',
    this.finishedGoodUnit = 'PCS',
    this.notes,
    this.rawMaterials = const [],
    this.additionalCosts = const [],
  });

  final String? partyId;
  final String? jobNumber;
  final String? orderDate;
  final String? deliveryDate;
  final String finishedGoodName;
  final String finishedGoodQuantity;
  final String finishedGoodUnit;
  final String? notes;
  final List<JobWorkRawMaterialRequest> rawMaterials;
  final List<JobWorkAdditionalCostRequest> additionalCosts;

  Map<String, dynamic> toJson() => {
    if (partyId != null) 'party_id': partyId,
    if (jobNumber != null && jobNumber!.trim().isNotEmpty)
      'job_number': jobNumber,
    if (orderDate != null) 'order_date': orderDate,
    if (deliveryDate != null) 'delivery_date': deliveryDate,
    'finished_good_name': finishedGoodName,
    'finished_good_quantity': finishedGoodQuantity,
    'finished_good_unit': finishedGoodUnit,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    'raw_materials': rawMaterials.map((item) => item.toJson()).toList(),
    'additional_costs': additionalCosts.map((item) => item.toJson()).toList(),
  };
}

class UpdateJobWorkOrderRequest {
  const UpdateJobWorkOrderRequest({
    this.partyId,
    this.jobNumber,
    this.deliveryDate,
    this.finishedGoodName,
    this.finishedGoodQuantity,
    this.finishedGoodUnit,
    this.status,
    this.notes,
    this.rawMaterials,
    this.additionalCosts,
    this.clearPartyId = false,
    this.clearJobNumber = false,
    this.clearDeliveryDate = false,
    this.clearNotes = false,
  });

  final String? partyId;
  final String? jobNumber;
  final String? deliveryDate;
  final String? finishedGoodName;
  final String? finishedGoodQuantity;
  final String? finishedGoodUnit;
  final String? status;
  final String? notes;
  final List<JobWorkRawMaterialRequest>? rawMaterials;
  final List<JobWorkAdditionalCostRequest>? additionalCosts;
  final bool clearPartyId;
  final bool clearJobNumber;
  final bool clearDeliveryDate;
  final bool clearNotes;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (clearPartyId) {
      json['party_id'] = null;
    } else if (partyId != null) {
      json['party_id'] = partyId;
    }
    if (clearJobNumber) {
      json['job_number'] = null;
    } else if (jobNumber != null) {
      json['job_number'] = jobNumber;
    }
    if (clearDeliveryDate) {
      json['delivery_date'] = null;
    } else if (deliveryDate != null) {
      json['delivery_date'] = deliveryDate;
    }
    if (finishedGoodName != null) {
      json['finished_good_name'] = finishedGoodName;
    }
    if (finishedGoodQuantity != null) {
      json['finished_good_quantity'] = finishedGoodQuantity;
    }
    if (finishedGoodUnit != null) {
      json['finished_good_unit'] = finishedGoodUnit;
    }
    if (status != null) json['status'] = status;
    if (clearNotes) {
      json['notes'] = null;
    } else if (notes != null) {
      json['notes'] = notes;
    }
    if (rawMaterials != null) {
      json['raw_materials'] = rawMaterials!.map((item) => item.toJson()).toList();
    }
    if (additionalCosts != null) {
      json['additional_costs'] = additionalCosts!
          .map((item) => item.toJson())
          .toList();
    }
    return json;
  }
}
