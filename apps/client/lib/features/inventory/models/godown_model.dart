class GodownModel {
  const GodownModel({
    required this.id,
    required this.name,
    this.address,
    this.isDefault = false,
    this.stockItemCount = 0,
  });

  final String id;
  final String name;
  final String? address;
  final bool isDefault;
  final int stockItemCount;
}
