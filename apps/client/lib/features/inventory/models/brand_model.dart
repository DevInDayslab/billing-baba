class BrandModel {
  const BrandModel({
    required this.id,
    required this.name,
    this.itemCount = 0,
    this.isUnbranded = false,
  });

  final String id;
  final String name;
  final int itemCount;
  final bool isUnbranded;
}
