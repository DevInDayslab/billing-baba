import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/utilities/application/import_items_excel_parser.dart';

/// Builds an Excel-compatible export sheet for all inventory items.
abstract final class ExportItemsExcelService {
  static const _sheetName = 'Items';

  static const detailHeaders = [
    'Barcode',
    'MRP',
    'Description',
    'Category',
    'Brand',
    'Short Name',
    'Alias',
    'Reorder Level',
    'Raw Material',
  ];

  static List<String> get headers => [
    ...ImportItemsExcelParser.templateHeaders,
    ...detailHeaders,
  ];

  static const _columnTypes = [
    ExportCellType.text,
    ExportCellType.text,
    ExportCellType.number,
    ExportCellType.number,
    ExportCellType.number,
    ExportCellType.text,
    ExportCellType.text,
    ExportCellType.number,
    ExportCellType.text,
    ExportCellType.number,
    ExportCellType.text,
    ExportCellType.text,
    ExportCellType.text,
    ExportCellType.text,
    ExportCellType.text,
    ExportCellType.number,
    ExportCellType.text,
  ];

  static ExportSheet buildSheet({
    required List<InventoryItem> items,
    required Map<String, String> categoryNamesById,
    required Map<String, String> brandNamesById,
  }) {
    final sorted = [...items]
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

    return ExportSheet.fromStrings(
      name: _sheetName,
      headers: headers,
      columnTypes: _columnTypes,
      rows: [
        for (final item in sorted)
          _rowForItem(
            item,
            categoryNamesById: categoryNamesById,
            brandNamesById: brandNamesById,
          ),
      ],
    );
  }

  static List<String> _rowForItem(
    InventoryItem item, {
    required Map<String, String> categoryNamesById,
    required Map<String, String> brandNamesById,
  }) {
    final openingQty = item.type == ItemType.product ? item.quantity : null;

    return [
      item.name,
      item.type.name,
      _formatOptionalNumber(item.salePrice),
      _formatOptionalNumber(item.purchasePrice),
      _formatOptionalNumber(item.defaultTaxRate),
      item.baseUnitShortName ?? '',
      item.hsnCode ?? '',
      _formatOptionalNumber(openingQty),
      item.barcode ?? '',
      _formatOptionalNumber(item.mrp),
      item.description ?? '',
      _lookupName(categoryNamesById, item.categoryId),
      _lookupName(brandNamesById, item.brandId),
      item.shortName ?? '',
      item.alias ?? '',
      _formatOptionalNumber(item.reorderLevel),
      item.isRawMaterial ? 'yes' : 'no',
    ];
  }

  static String _lookupName(Map<String, String> namesById, String? id) {
    if (id == null || id.isEmpty) return '';
    return namesById[id] ?? '';
  }

  static String _formatOptionalNumber(double? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    final text = value.toString();
    if (text.contains('e') || text.contains('E')) {
      return value.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
    }
    return text;
  }
}
