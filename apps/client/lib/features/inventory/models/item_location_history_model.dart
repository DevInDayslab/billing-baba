class ItemLocationHistoryModel {
  const ItemLocationHistoryModel({
    required this.id,
    required this.itemLocationId,
    required this.itemId,
    required this.createdAt,
    this.rack,
    this.shelf,
    this.photoUrl,
    this.employeeLabel,
    this.changedBy,
  });

  final String id;
  final String itemLocationId;
  final String itemId;
  final DateTime createdAt;
  final String? rack;
  final String? shelf;
  final String? photoUrl;
  final String? employeeLabel;
  final String? changedBy;
}
