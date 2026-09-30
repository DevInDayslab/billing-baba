class BulkItemUpdatePayload {
  const BulkItemUpdatePayload({
    this.salePrice,
    this.purchasePrice,
    this.mrp,
    this.categoryId,
    this.clearCategory = false,
    this.hsnCode,
    this.clearHsn = false,
  });

  final String? salePrice;
  final String? purchasePrice;
  final String? mrp;
  final String? categoryId;
  final bool clearCategory;
  final String? hsnCode;
  final bool clearHsn;

  bool get hasChanges =>
      salePrice != null ||
      purchasePrice != null ||
      mrp != null ||
      categoryId != null ||
      clearCategory ||
      (hsnCode != null && hsnCode!.isNotEmpty) ||
      clearHsn;
}
