import 'package:billing_baba/features/inventory/models/item_model.dart';

enum PriceTaxMode { withoutTax, withTax }

class RawMaterialRow {
  const RawMaterialRow({
    required this.id,
    this.itemName = '',
    this.qty = 0,
    this.unitLabel = 'None',
    this.purchasePrice = 0,
  });

  final String id;
  final String itemName;
  final double qty;
  final String unitLabel;
  final double purchasePrice;

  double get estimatedCost => qty * purchasePrice;

  RawMaterialRow copyWith({
    String? itemName,
    double? qty,
    String? unitLabel,
    double? purchasePrice,
  }) {
    return RawMaterialRow(
      id: id,
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      unitLabel: unitLabel ?? this.unitLabel,
      purchasePrice: purchasePrice ?? this.purchasePrice,
    );
  }
}

class AdditionalCostRow {
  const AdditionalCostRow({
    required this.id,
    this.description = '',
    this.amount = 0,
  });

  final String id;
  final String description;
  final double amount;

  AdditionalCostRow copyWith({String? description, double? amount}) {
    return AdditionalCostRow(
      id: id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
    );
  }
}

class AddItemFormState {
  const AddItemFormState({
    this.itemType = ItemType.product,
    this.itemName = '',
    this.hsn = '',
    this.itemCode = '',
    this.baseUnitId,
    this.secondaryUnitId,
    this.categoryId,
    this.description = '',
    this.activeTab = 0,
    this.salePrice = 0,
    this.salePriceTaxMode = PriceTaxMode.withoutTax,
    this.wholesalePrice = 0,
    this.wholesalePriceTaxMode = PriceTaxMode.withoutTax,
    this.minWholesaleQty = 0,
    this.openingQty = 0,
    this.atPrice = 0,
    this.asOfDate,
    this.minStock = 0,
    this.location = '',
    this.onlineStorePrice = 0,
    this.onlineStoreDescription = '',
    this.rawMaterials = const [],
    this.additionalCosts = const [],
    this.itemNameError = false,
    this.isDirty = false,
  });

  final ItemType itemType;
  final String itemName;
  final String hsn;
  final String itemCode;
  final String? baseUnitId;
  final String? secondaryUnitId;
  final String? categoryId;
  final String description;
  final int activeTab;
  final double salePrice;
  final PriceTaxMode salePriceTaxMode;
  final double wholesalePrice;
  final PriceTaxMode wholesalePriceTaxMode;
  final double minWholesaleQty;
  final double openingQty;
  final double atPrice;
  final DateTime? asOfDate;
  final double minStock;
  final String location;
  final double onlineStorePrice;
  final String onlineStoreDescription;
  final List<RawMaterialRow> rawMaterials;
  final List<AdditionalCostRow> additionalCosts;
  final bool itemNameError;
  final bool isDirty;

  double get rawMaterialTotal =>
      rawMaterials.fold(0, (sum, row) => sum + row.estimatedCost);

  double get additionalCostTotal =>
      additionalCosts.fold(0, (sum, row) => sum + row.amount);

  double get totalEstimatedCost => rawMaterialTotal + additionalCostTotal;

  AddItemFormState copyWith({
    ItemType? itemType,
    String? itemName,
    String? hsn,
    String? itemCode,
    String? baseUnitId,
    String? secondaryUnitId,
    bool clearBaseUnit = false,
    bool clearSecondaryUnit = false,
    String? categoryId,
    bool clearCategory = false,
    String? description,
    int? activeTab,
    double? salePrice,
    PriceTaxMode? salePriceTaxMode,
    double? wholesalePrice,
    PriceTaxMode? wholesalePriceTaxMode,
    double? minWholesaleQty,
    double? openingQty,
    double? atPrice,
    DateTime? asOfDate,
    double? minStock,
    String? location,
    double? onlineStorePrice,
    String? onlineStoreDescription,
    List<RawMaterialRow>? rawMaterials,
    List<AdditionalCostRow>? additionalCosts,
    bool? itemNameError,
    bool? isDirty,
  }) {
    return AddItemFormState(
      itemType: itemType ?? this.itemType,
      itemName: itemName ?? this.itemName,
      hsn: hsn ?? this.hsn,
      itemCode: itemCode ?? this.itemCode,
      baseUnitId: clearBaseUnit ? null : (baseUnitId ?? this.baseUnitId),
      secondaryUnitId:
          clearSecondaryUnit ? null : (secondaryUnitId ?? this.secondaryUnitId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      description: description ?? this.description,
      activeTab: activeTab ?? this.activeTab,
      salePrice: salePrice ?? this.salePrice,
      salePriceTaxMode: salePriceTaxMode ?? this.salePriceTaxMode,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      wholesalePriceTaxMode:
          wholesalePriceTaxMode ?? this.wholesalePriceTaxMode,
      minWholesaleQty: minWholesaleQty ?? this.minWholesaleQty,
      openingQty: openingQty ?? this.openingQty,
      atPrice: atPrice ?? this.atPrice,
      asOfDate: asOfDate ?? this.asOfDate,
      minStock: minStock ?? this.minStock,
      location: location ?? this.location,
      onlineStorePrice: onlineStorePrice ?? this.onlineStorePrice,
      onlineStoreDescription:
          onlineStoreDescription ?? this.onlineStoreDescription,
      rawMaterials: rawMaterials ?? this.rawMaterials,
      additionalCosts: additionalCosts ?? this.additionalCosts,
      itemNameError: itemNameError ?? this.itemNameError,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

String priceTaxModeLabel(PriceTaxMode mode) => switch (mode) {
  PriceTaxMode.withoutTax => 'Without Tax',
  PriceTaxMode.withTax => 'With Tax',
};
