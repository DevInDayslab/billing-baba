class ItemLocationModel {
  const ItemLocationModel({
    required this.id,
    required this.itemId,
    required this.godownId,
    required this.updatedAt,
    this.rack,
    this.shelf,
    this.photoUrl,
    this.photoTakenAt,
  });

  final String id;
  final String itemId;
  final String godownId;
  final DateTime updatedAt;
  final String? rack;
  final String? shelf;
  final String? photoUrl;
  final DateTime? photoTakenAt;
}
