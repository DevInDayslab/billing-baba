import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

const stockDetailExportHeaders = [
  'Item Name',
  'Opening',
  'In',
  'Out',
  'Closing',
];

List<String> stockDetailExportRow(ReportStockDetailRow row) {
  return [
    row.itemName,
    formatQuantityValue(row.openingQty),
    formatQuantityValue(row.inQty),
    formatQuantityValue(row.outQty),
    formatQuantityValue(row.closingQty),
  ];
}
