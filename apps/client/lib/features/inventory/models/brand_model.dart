class BrandModel {
  const BrandModel({
    required this.id,
    required this.name,
    this.itemCount = 0,
  });

  final String id;
  final String name;
  final int itemCount;
}
