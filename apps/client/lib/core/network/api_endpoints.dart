/// API endpoint path constants.
abstract final class ApiEndpoints {
  static const auth = '/api/v1/auth';
  static const businesses = '/api/v1/businesses';
  static const businessProfile = '/api/v1/business/profile';
  static const parties = '/api/v1/parties';
  static String party(String id) => '/api/v1/parties/$id';
  static const sync = '/api/v1/sync';
  static const health = '/api/v1/health';

  static const inventory = '/api/v1/inventory';
  static const inventoryCategories = '$inventory/categories';
  static String inventoryCategory(String id) => '$inventoryCategories/$id';

  static const inventoryBrands = '$inventory/brands';
  static String inventoryBrand(String id) => '$inventoryBrands/$id';

  static const inventoryUnits = '$inventory/units';
  static String inventoryUnit(String id) => '$inventoryUnits/$id';

  static const inventoryUnitConversions = '$inventory/unit-conversions';
  static String inventoryUnitConversion(String id) =>
      '$inventoryUnitConversions/$id';

  static const inventoryGodowns = '$inventory/godowns';
  static String inventoryGodown(String id) => '$inventoryGodowns/$id';

  static const inventoryItems = '$inventory/items';
  static String inventoryItem(String id) => '$inventoryItems/$id';
  static String inventoryItemImages(String itemId) =>
      '${inventoryItem(itemId)}/images';
  static String inventoryItemImage(String itemId, String imageId) =>
      '${inventoryItemImages(itemId)}/$imageId';
  static String inventoryItemTierPrices(String itemId) =>
      '${inventoryItem(itemId)}/tier-prices';
  static String inventoryItemTierPrice(String itemId, String tier) =>
      '${inventoryItemTierPrices(itemId)}/$tier';
  static String inventoryItemPriceHistory(String itemId) =>
      '${inventoryItem(itemId)}/price-history';

  static const inventoryItemLocations = '$inventory/item-locations';
  static String inventoryItemLocation(String id) =>
      '$inventoryItemLocations/$id';

  static const inventoryStockLevels = '$inventory/stock-levels';
  static String inventoryStockLevel(String id) => '$inventoryStockLevels/$id';

  static const inventoryMovements = '$inventory/movements';
  static String inventoryMovement(String id) => '$inventoryMovements/$id';

  static const inventoryPriceHistory = '$inventory/price-history';
  static String inventoryPriceHistoryRecord(String id) =>
      '$inventoryPriceHistory/$id';

  static const sales = '/api/v1/sales';
  static const salesDocuments = '$sales/sales-documents';
  static String salesDocument(String id) => '$salesDocuments/$id';
  static String salesDocumentLines(String id) => '${salesDocument(id)}/lines';
  static String salesDocumentLine(String id, String lineId) =>
      '${salesDocumentLines(id)}/$lineId';
  static String salesDocumentFinalize(String id) =>
      '${salesDocument(id)}/finalize';
  static String salesDocumentCancel(String id) => '${salesDocument(id)}/cancel';
  static String salesDocumentConvert(String id) => '${salesDocument(id)}/convert';
  static String salesDocumentBrandSwap(String id) =>
      '${salesDocument(id)}/brand-swap';

  static const posSessions = '$sales/pos-sessions';
  static String posSession(String id) => '$posSessions/$id';
  static String posSessionDocuments(String id) =>
      '${posSession(id)}/sales-documents';

  static const accounting = '/api/v1/accounting';
  static const payments = '$accounting/payments';
  static String payment(String id) => '$payments/$id';
  static String paymentAllocations(String id) => '${payment(id)}/allocations';
  static String paymentAllocation(String id, String allocationId) =>
      '${paymentAllocations(id)}/$allocationId';

  static const purchases = '/api/v1/purchases';
  static const purchaseDocuments = '$purchases/purchase-documents';
  static String purchaseDocument(String id) => '$purchaseDocuments/$id';
  static String purchaseDocumentLines(String id) =>
      '${purchaseDocument(id)}/lines';
  static String purchaseDocumentLine(String id, String lineId) =>
      '${purchaseDocumentLines(id)}/$lineId';
  static String purchaseDocumentFinalize(String id) =>
      '${purchaseDocument(id)}/finalize';
  static String purchaseDocumentCancel(String id) =>
      '${purchaseDocument(id)}/cancel';
  static String purchaseDocumentConvert(String id) =>
      '${purchaseDocument(id)}/convert';

  static const expenses = '$purchases/expenses';
  static String expense(String id) => '$expenses/$id';
  static const expenseCategories = '$purchases/expense-categories';
  static String expenseCategory(String id) => '$expenseCategories/$id';

  static const fixedAssetPurchases = '$purchases/fixed-asset-purchases';
  static String fixedAssetPurchase(String batchId) =>
      '$fixedAssetPurchases/$batchId';

  static const jobWork = '/api/v1/job-work';
  static const jobWorkOrders = '$jobWork/job-work-orders';
  static String jobWorkOrder(String id) => '$jobWorkOrders/$id';
}
