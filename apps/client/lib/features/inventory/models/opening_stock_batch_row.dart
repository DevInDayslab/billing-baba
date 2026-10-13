/// One opening-stock batch line on the add/edit item form.
class OpeningStockBatchRow {
  const OpeningStockBatchRow({
    required this.id,
    this.batchNo = '',
    this.modelNo = '',
    this.size = '',
    this.mfgDate,
    this.expDate,
    this.openingQty = 0,
  });

  final String id;
  final String batchNo;
  final String modelNo;
  final String size;
  final DateTime? mfgDate;
  final DateTime? expDate;
  final double openingQty;

  OpeningStockBatchRow copyWith({
    String? batchNo,
    String? modelNo,
    String? size,
    DateTime? mfgDate,
    bool clearMfgDate = false,
    DateTime? expDate,
    bool clearExpDate = false,
    double? openingQty,
  }) {
    return OpeningStockBatchRow(
      id: id,
      batchNo: batchNo ?? this.batchNo,
      modelNo: modelNo ?? this.modelNo,
      size: size ?? this.size,
      mfgDate: clearMfgDate ? null : (mfgDate ?? this.mfgDate),
      expDate: clearExpDate ? null : (expDate ?? this.expDate),
      openingQty: openingQty ?? this.openingQty,
    );
  }

  static double totalQty(List<OpeningStockBatchRow> rows) {
    return rows.fold(0, (sum, row) => sum + row.openingQty);
  }
}
