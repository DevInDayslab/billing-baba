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
}
