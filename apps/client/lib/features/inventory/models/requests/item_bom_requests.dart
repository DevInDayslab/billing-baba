class ItemBomMaterialInput {
  const ItemBomMaterialInput({
    required this.rawItemId,
    required this.qty,
    required this.unitId,
    this.purchasePrice = '0',
    this.sortOrder = 0,
  });

  final String rawItemId;
  final String qty;
  final String unitId;
  final String purchasePrice;
  final int sortOrder;

  Map<String, dynamic> toJson() => {
    'raw_item_id': rawItemId,
    'qty': qty,
    'unit_id': unitId,
    'purchase_price': purchasePrice,
    'sort_order': sortOrder,
  };
}

class ItemBomCostInput {
  const ItemBomCostInput({
    this.id,
    required this.description,
    required this.amount,
    this.sortOrder = 0,
  });

  final String? id;
  final String description;
  final String amount;
  final int sortOrder;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'description': description,
    'amount': amount,
    'sort_order': sortOrder,
  };
}

class ReplaceItemBomRequest {
  const ReplaceItemBomRequest({
    required this.materials,
    required this.costs,
  });

  final List<ItemBomMaterialInput> materials;
  final List<ItemBomCostInput> costs;

  Map<String, dynamic> toJson() => {
    'materials': materials.map((material) => material.toJson()).toList(),
    'costs': costs.map((cost) => cost.toJson()).toList(),
  };
}
