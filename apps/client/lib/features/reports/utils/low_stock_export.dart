import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

const lowStockExportHeaders = [
  'Item Name',
  'Min Stock',
  'Current Stock',
  'Shortage',
];

List<String> lowStockExportRow(ReportLowStockRow row) {
  return [
    row.itemName,
    formatQuantityValue(row.minStock),
    formatQuantityValue(row.currentStock),
    formatQuantityValue(row.shortage),
  ];
}
