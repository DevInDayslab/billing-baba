import 'package:billing_baba/features/inventory/models/item_model.dart';

enum PriceTaxMode { withoutTax, withTax }

class ItemTierPriceRow {
  const ItemTierPriceRow({
    required this.id,
    required this.tierKey,
    this.price = 0,
  });

  final String id;
  final String tierKey;
  final double price;

  ItemTierPriceRow copyWith({String? tierKey, double? price}) {
    return ItemTierPriceRow(
      id: id,
      tierKey: tierKey ?? this.tierKey,
      price: price ?? this.price,
    );
  }
}

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

enum ItemTrackingMode { none, batch, serial }

class AddItemFormState {
  const AddItemFormState({
    this.itemType = ItemType.product,
    this.itemName = '',
    this.shortName = '',
    this.alias = '',
    this.searchKeywords = '',
    this.hsn = '',
    this.itemCode = '',
    this.baseUnitId,
    this.secondaryUnitId,
    this.categoryId,
    this.brandId,
    this.godownId,
    this.primaryImageUrl = '',
    this.description = '',
    this.trackingMode = ItemTrackingMode.none,
    this.activeTab = 0,
    this.mrp = 0,
    this.salePrice = 0,
    this.salePriceTaxMode = PriceTaxMode.withoutTax,
    this.wholesalePrice = 0,
    this.wholesalePriceTaxMode = PriceTaxMode.withoutTax,
    this.minWholesaleQty = 0,
    this.openingQty = 0,
    this.atPrice = 0,
    this.purchasePriceTaxMode = PriceTaxMode.withoutTax,
    this.taxRate = 'None',
    this.asOfDate,
    this.minStock = 0,
    this.location = '',
    this.onlineStorePrice = 0,
    this.onlineStoreDescription = '',
    this.rawMaterials = const [],
    this.additionalCosts = const [],
    this.tierPrices = const [],
    this.alternativeItemIds = const [],
    this.itemNameError = false,
    this.isDirty = false,
  });

  final ItemType itemType;
  final String itemName;
  final String shortName;
  final String alias;
  final String searchKeywords;
  final String hsn;
  final String itemCode;
  final String? baseUnitId;
  final String? secondaryUnitId;
  final String? categoryId;
  final String? brandId;
  final String? godownId;
  final String primaryImageUrl;
  final String description;
  final ItemTrackingMode trackingMode;
  final int activeTab;
  final double mrp;
  final double salePrice;
  final PriceTaxMode salePriceTaxMode;
  final double wholesalePrice;
  final PriceTaxMode wholesalePriceTaxMode;
  final double minWholesaleQty;
  final double openingQty;
  final double atPrice;
  final PriceTaxMode purchasePriceTaxMode;
  final String taxRate;
  final DateTime? asOfDate;
  final double minStock;
  final String location;
  final double onlineStorePrice;
  final String onlineStoreDescription;
  final List<RawMaterialRow> rawMaterials;
  final List<AdditionalCostRow> additionalCosts;
  final List<ItemTierPriceRow> tierPrices;
  final List<String> alternativeItemIds;
  final bool itemNameError;
  final bool isDirty;

  double get rawMaterialTotal =>
      rawMaterials.fold(0, (sum, row) => sum + row.estimatedCost);

  double get additionalCostTotal =>
      additionalCosts.fold(0, (sum, row) => sum + row.amount);

  double get totalEstimatedCost => rawMaterialTotal + additionalCostTotal;

  Map<String, double> get tierPriceMap => {
    for (final row in tierPrices)
      if (row.price > 0) row.tierKey: row.price,
  };

  AddItemFormState copyWith({
    ItemType? itemType,
    String? itemName,
    String? shortName,
    String? alias,
    String? searchKeywords,
    String? hsn,
    String? itemCode,
    String? baseUnitId,
    String? secondaryUnitId,
    bool clearBaseUnit = false,
    bool clearSecondaryUnit = false,
    String? categoryId,
    bool clearCategory = false,
    String? brandId,
    bool clearBrand = false,
    String? godownId,
    bool clearGodown = false,
    String? primaryImageUrl,
    String? description,
    ItemTrackingMode? trackingMode,
    int? activeTab,
    double? mrp,
    double? salePrice,
    PriceTaxMode? salePriceTaxMode,
    double? wholesalePrice,
    PriceTaxMode? wholesalePriceTaxMode,
    double? minWholesaleQty,
    double? openingQty,
    double? atPrice,
    PriceTaxMode? purchasePriceTaxMode,
    String? taxRate,
    DateTime? asOfDate,
    double? minStock,
    String? location,
    double? onlineStorePrice,
    String? onlineStoreDescription,
    List<RawMaterialRow>? rawMaterials,
    List<AdditionalCostRow>? additionalCosts,
    List<ItemTierPriceRow>? tierPrices,
    List<String>? alternativeItemIds,
    bool? itemNameError,
    bool? isDirty,
  }) {
    return AddItemFormState(
      itemType: itemType ?? this.itemType,
      itemName: itemName ?? this.itemName,
      shortName: shortName ?? this.shortName,
      alias: alias ?? this.alias,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      hsn: hsn ?? this.hsn,
      itemCode: itemCode ?? this.itemCode,
      baseUnitId: clearBaseUnit ? null : (baseUnitId ?? this.baseUnitId),
      secondaryUnitId: clearSecondaryUnit
          ? null
          : (secondaryUnitId ?? this.secondaryUnitId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      brandId: clearBrand ? null : (brandId ?? this.brandId),
      godownId: clearGodown ? null : (godownId ?? this.godownId),
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      description: description ?? this.description,
      trackingMode: trackingMode ?? this.trackingMode,
      activeTab: activeTab ?? this.activeTab,
      mrp: mrp ?? this.mrp,
      salePrice: salePrice ?? this.salePrice,
      salePriceTaxMode: salePriceTaxMode ?? this.salePriceTaxMode,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      wholesalePriceTaxMode:
          wholesalePriceTaxMode ?? this.wholesalePriceTaxMode,
      minWholesaleQty: minWholesaleQty ?? this.minWholesaleQty,
      openingQty: openingQty ?? this.openingQty,
      atPrice: atPrice ?? this.atPrice,
      purchasePriceTaxMode: purchasePriceTaxMode ?? this.purchasePriceTaxMode,
      taxRate: taxRate ?? this.taxRate,
      asOfDate: asOfDate ?? this.asOfDate,
      minStock: minStock ?? this.minStock,
      location: location ?? this.location,
      onlineStorePrice: onlineStorePrice ?? this.onlineStorePrice,
      onlineStoreDescription:
          onlineStoreDescription ?? this.onlineStoreDescription,
      rawMaterials: rawMaterials ?? this.rawMaterials,
      additionalCosts: additionalCosts ?? this.additionalCosts,
      tierPrices: tierPrices ?? this.tierPrices,
      alternativeItemIds: alternativeItemIds ?? this.alternativeItemIds,
      itemNameError: itemNameError ?? this.itemNameError,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

String priceTaxModeLabel(PriceTaxMode mode) => switch (mode) {
  PriceTaxMode.withoutTax => 'Without Tax',
  PriceTaxMode.withTax => 'With Tax',
};
