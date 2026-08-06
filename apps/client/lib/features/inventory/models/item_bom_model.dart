class ItemBomMaterialModel {
  const ItemBomMaterialModel({
    required this.id,
    required this.itemId,
    required this.rawItemId,
    required this.qty,
    required this.unitId,
    required this.purchasePrice,
    required this.sortOrder,
    this.rawItemName = '',
    this.rawItemBaseUnit = '',
  });

  final String id;
  final String itemId;
  final String rawItemId;
  final double qty;
  final String unitId;
  final double purchasePrice;
  final int sortOrder;
  final String rawItemName;
  final String rawItemBaseUnit;

  double get estimatedCost => qty * purchasePrice;
}

class ItemBomCostModel {
  const ItemBomCostModel({
    required this.id,
    required this.itemId,
    required this.description,
    required this.amount,
    required this.sortOrder,
  });

  final String id;
  final String itemId;
  final String description;
  final double amount;
  final int sortOrder;
}

class ItemBomModel {
  const ItemBomModel({
    required this.materials,
    required this.costs,
  });

  final List<ItemBomMaterialModel> materials;
  final List<ItemBomCostModel> costs;

  double get rawMaterialTotal =>
      materials.fold(0, (sum, row) => sum + row.estimatedCost);

  double get additionalCostTotal =>
      costs.fold(0, (sum, row) => sum + row.amount);

  double get totalEstimatedCost => rawMaterialTotal + additionalCostTotal;
}
