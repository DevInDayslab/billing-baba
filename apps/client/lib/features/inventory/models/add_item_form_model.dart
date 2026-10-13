import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/opening_stock_batch_row.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';

enum PriceTaxMode { withoutTax, withTax }

enum PriceDiscountKind { percentage, amount }

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
    this.rawItemId,
    this.itemName = '',
    this.qty = 0,
    this.unitId,
    this.unitLabel = 'None',
    this.purchasePrice = 0,
  });

  final String id;
  final String? rawItemId;
  final String itemName;
  final double qty;
  final String? unitId;
  final String unitLabel;
  final double purchasePrice;

  double get estimatedCost => qty * purchasePrice;

  RawMaterialRow copyWith({
    String? rawItemId,
    bool clearRawItemId = false,
    String? itemName,
    double? qty,
    String? unitId,
    bool clearUnitId = false,
    String? unitLabel,
    double? purchasePrice,
  }) {
    return RawMaterialRow(
      id: id,
      rawItemId: clearRawItemId ? null : (rawItemId ?? this.rawItemId),
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      unitId: clearUnitId ? null : (unitId ?? this.unitId),
      unitLabel: unitLabel ?? this.unitLabel,
      purchasePrice: purchasePrice ?? this.purchasePrice,
    );
  }
}

/// Product fields used to pre-fill supplier rows when parties are linked.
class SuppliersProductSnapshot {
  const SuppliersProductSnapshot({
    this.itemId,
    this.productImageUrl = '',
    this.brandName = '',
    this.mrp = 0,
    this.pricing = 0,
    this.minOrderQuantity = 0,
    this.productNotes = '',
  });

  final String? itemId;
  final String productImageUrl;
  final String brandName;
  final double mrp;
  final double pricing;
  final double minOrderQuantity;
  final String productNotes;
}

/// Per-supplier purchase details on the add-item form (UI state; party link syncs).
class ItemSupplierFormRow {
  const ItemSupplierFormRow({
    required this.partyId,
    this.productImageUrl = '',
    this.brandName = '',
    this.mrp = 0,
    this.pricing = 0,
    this.minOrderQuantity = 1,
    this.paymentPolicy = '',
    this.qualityRating = 0,
    this.notes = '',
    this.sellerAddress = '',
  });

  final String partyId;
  final String productImageUrl;
  final String brandName;
  final double mrp;
  final double pricing;
  final double minOrderQuantity;
  final String paymentPolicy;
  final int qualityRating;
  final String notes;
  final String sellerAddress;

  ItemSupplierFormRow copyWith({
    String? productImageUrl,
    String? brandName,
    double? mrp,
    double? pricing,
    double? minOrderQuantity,
    String? paymentPolicy,
    int? qualityRating,
    String? notes,
    String? sellerAddress,
  }) {
    return ItemSupplierFormRow(
      partyId: partyId,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      brandName: brandName ?? this.brandName,
      mrp: mrp ?? this.mrp,
      pricing: pricing ?? this.pricing,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      paymentPolicy: paymentPolicy ?? this.paymentPolicy,
      qualityRating: qualityRating ?? this.qualityRating,
      notes: notes ?? this.notes,
      sellerAddress: sellerAddress ?? this.sellerAddress,
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
    this.activeTab = 0,
    this.mrp = 0,
    this.mrpSaleDiscount = 0,
    this.mrpSaleDiscountKind = PriceDiscountKind.percentage,
    this.salePrice = 0,
    this.salePriceDiscount = 0,
    this.salePriceDiscountKind = PriceDiscountKind.percentage,
    this.salePriceTaxMode = PriceTaxMode.withoutTax,
    this.wholesalePrice = 0,
    this.wholesalePriceTaxMode = PriceTaxMode.withoutTax,
    this.wholesaleSectionVisible = false,
    this.minWholesaleQty = 0,
    this.minWholesaleQtyUnitId,
    this.openingQtyUnitId,
    this.minStockUnitId,
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
    this.supplierPartyIds = const [],
    this.supplierRows = const [],
    this.defaultSupplierPartyId,
    this.itemNameError = false,
    this.baseUnitError = false,
    this.fieldErrors = const {},
    this.isDirty = false,
    this.batchTrackingEnabled = false,
    this.openingStockBatches = const [],
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
  final int activeTab;
  final double mrp;
  final double mrpSaleDiscount;
  final PriceDiscountKind mrpSaleDiscountKind;
  final double salePrice;
  final double salePriceDiscount;
  final PriceDiscountKind salePriceDiscountKind;
  final PriceTaxMode salePriceTaxMode;
  final double wholesalePrice;
  final PriceTaxMode wholesalePriceTaxMode;
  final bool wholesaleSectionVisible;
  final double minWholesaleQty;

  /// Unit for [minWholesaleQty]; defaults to [baseUnitId] when null.
  final String? minWholesaleQtyUnitId;

  /// Display unit for [openingQty] (stored in [baseUnitId]); defaults to base.
  final String? openingQtyUnitId;

  /// Display unit for [minStock] (stored in base unit); defaults to base.
  final String? minStockUnitId;
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
  final List<String> supplierPartyIds;
  final List<ItemSupplierFormRow> supplierRows;
  final String? defaultSupplierPartyId;
  final bool itemNameError;
  final bool baseUnitError;

  /// Server / extra validation messages keyed by API field name.
  final Map<String, String> fieldErrors;
  final bool isDirty;
  final bool batchTrackingEnabled;
  final List<OpeningStockBatchRow> openingStockBatches;

  String? errorFor(String field) => fieldErrors[field];

  bool get usesOpeningStockBatches =>
      batchTrackingEnabled && openingStockBatches.isNotEmpty;

  double get rawMaterialTotal =>
      rawMaterials.fold(0, (sum, row) => sum + row.estimatedCost);

  double get additionalCostTotal =>
      additionalCosts.fold(0, (sum, row) => sum + row.amount);

  double get totalEstimatedCost => rawMaterialTotal + additionalCostTotal;

  Map<String, double> get tierPriceMap => {
    for (final row in tierPrices)
      if (row.price > 0) row.tierKey: row.price,
  };

  /// Tier prices to persist, including wholesale from the pricing tab.
  Map<String, double> get resolvedTierPriceMap {
    final map = Map<String, double>.from(tierPriceMap);
    if (wholesalePrice > 0) {
      map[PriceTier.wholesale] = wholesalePrice;
    }
    return map;
  }

  bool get showWholesaleSection =>
      wholesaleSectionVisible ||
      wholesalePrice > 0 ||
      minWholesaleQty > 0 ||
      tierPrices.any((row) => row.tierKey == PriceTier.wholesale);

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
    int? activeTab,
    double? mrp,
    double? mrpSaleDiscount,
    PriceDiscountKind? mrpSaleDiscountKind,
    double? salePrice,
    double? salePriceDiscount,
    PriceDiscountKind? salePriceDiscountKind,
    PriceTaxMode? salePriceTaxMode,
    double? wholesalePrice,
    PriceTaxMode? wholesalePriceTaxMode,
    bool? wholesaleSectionVisible,
    double? minWholesaleQty,
    String? minWholesaleQtyUnitId,
    bool clearMinWholesaleQtyUnit = false,
    String? openingQtyUnitId,
    bool clearOpeningQtyUnit = false,
    String? minStockUnitId,
    bool clearMinStockUnit = false,
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
    List<String>? supplierPartyIds,
    List<ItemSupplierFormRow>? supplierRows,
    String? defaultSupplierPartyId,
    bool clearDefaultSupplier = false,
    bool? itemNameError,
    bool? baseUnitError,
    Map<String, String>? fieldErrors,
    bool clearFieldErrors = false,
    bool? isDirty,
    bool? batchTrackingEnabled,
    List<OpeningStockBatchRow>? openingStockBatches,
    bool clearOpeningStockBatches = false,
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
      activeTab: activeTab ?? this.activeTab,
      mrp: mrp ?? this.mrp,
      mrpSaleDiscount: mrpSaleDiscount ?? this.mrpSaleDiscount,
      mrpSaleDiscountKind: mrpSaleDiscountKind ?? this.mrpSaleDiscountKind,
      salePrice: salePrice ?? this.salePrice,
      salePriceDiscount: salePriceDiscount ?? this.salePriceDiscount,
      salePriceDiscountKind:
          salePriceDiscountKind ?? this.salePriceDiscountKind,
      salePriceTaxMode: salePriceTaxMode ?? this.salePriceTaxMode,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      wholesalePriceTaxMode:
          wholesalePriceTaxMode ?? this.wholesalePriceTaxMode,
      wholesaleSectionVisible:
          wholesaleSectionVisible ?? this.wholesaleSectionVisible,
      minWholesaleQty: minWholesaleQty ?? this.minWholesaleQty,
      minWholesaleQtyUnitId: clearMinWholesaleQtyUnit
          ? null
          : (minWholesaleQtyUnitId ?? this.minWholesaleQtyUnitId),
      openingQtyUnitId: clearOpeningQtyUnit
          ? null
          : (openingQtyUnitId ?? this.openingQtyUnitId),
      minStockUnitId: clearMinStockUnit
          ? null
          : (minStockUnitId ?? this.minStockUnitId),
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
      supplierPartyIds: supplierPartyIds ?? this.supplierPartyIds,
      supplierRows: supplierRows ?? this.supplierRows,
      defaultSupplierPartyId: clearDefaultSupplier
          ? null
          : (defaultSupplierPartyId ?? this.defaultSupplierPartyId),
      itemNameError: itemNameError ?? this.itemNameError,
      baseUnitError: baseUnitError ?? this.baseUnitError,
      fieldErrors: clearFieldErrors
          ? const {}
          : (fieldErrors ?? this.fieldErrors),
      isDirty: isDirty ?? this.isDirty,
      batchTrackingEnabled: batchTrackingEnabled ?? this.batchTrackingEnabled,
      openingStockBatches: clearOpeningStockBatches
          ? const []
          : (openingStockBatches ?? this.openingStockBatches),
    );
  }
}

String priceTaxModeLabel(PriceTaxMode mode) => switch (mode) {
  PriceTaxMode.withoutTax => 'Without Tax',
  PriceTaxMode.withTax => 'With Tax',
};
