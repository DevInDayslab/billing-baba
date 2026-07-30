class PriceHistoryModel {
  const PriceHistoryModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.createdAt,
    this.pricingTier,
    this.changedBy,
  });

  final String id;
  final String itemId;
  final String itemName;
  final double price;
  final String? pricingTier;
  final String? changedBy;
  final DateTime createdAt;
}
