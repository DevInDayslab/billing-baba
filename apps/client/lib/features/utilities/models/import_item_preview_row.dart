import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';

enum ImportRowStatus { valid, duplicate, error }

class ImportItemPreviewRow {
  const ImportItemPreviewRow({
    required this.id,
    required this.sheetRowNumber,
    required this.itemName,
    required this.typeLabel,
    required this.salePrice,
    required this.purchasePrice,
    required this.taxRate,
    required this.unit,
    required this.hsnSac,
    required this.openingQty,
    required this.status,
    this.issueMessage,
    this.isSelected = false,
    this.importForm,
  });

  final String id;
  final int sheetRowNumber;
  final String itemName;
  final String typeLabel;
  final String salePrice;
  final String purchasePrice;
  final String taxRate;
  final String unit;
  final String hsnSac;
  final String openingQty;
  final ImportRowStatus status;
  final String? issueMessage;
  final bool isSelected;
  final AddItemFormState? importForm;

  bool get canImport =>
      status == ImportRowStatus.valid && isSelected && importForm != null;

  ImportItemPreviewRow copyWith({
    ImportRowStatus? status,
    String? issueMessage,
    bool? isSelected,
    AddItemFormState? importForm,
  }) {
    return ImportItemPreviewRow(
      id: id,
      sheetRowNumber: sheetRowNumber,
      itemName: itemName,
      typeLabel: typeLabel,
      salePrice: salePrice,
      purchasePrice: purchasePrice,
      taxRate: taxRate,
      unit: unit,
      hsnSac: hsnSac,
      openingQty: openingQty,
      status: status ?? this.status,
      issueMessage: issueMessage ?? this.issueMessage,
      isSelected: isSelected ?? this.isSelected,
      importForm: importForm ?? this.importForm,
    );
  }
}

class ImportItemsResult {
  const ImportItemsResult({
    required this.successCount,
    required this.failedCount,
    required this.skippedCount,
    this.errors = const [],
  });

  final int successCount;
  final int failedCount;
  final int skippedCount;
  final List<String> errors;
}
