class ItemLocationModel {
  const ItemLocationModel({
    required this.id,
    required this.itemId,
    required this.godownId,
    this.rack,
    this.shelf,
    this.photoUrl,
  });

  final String id;
  final String itemId;
  final String godownId;
  final String? rack;
  final String? shelf;
  final String? photoUrl;
}
