import 'package:billing_baba/features/reports/application/consumption_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportConsumptionRow> applyConsumptionColumnFilters(
  List<ReportConsumptionRow> rows,
  ConsumptionColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(row.date)) {
      return false;
    }
    if (filters.refNoColumnFilter != null &&
        !filters.refNoColumnFilter!.matches(row.refNo)) {
      return false;
    }
    if (filters.itemNameColumnFilter != null &&
        !filters.itemNameColumnFilter!.matches(row.itemName)) {
      return false;
    }
    if (filters.quantityColumnFilter != null &&
        !filters.quantityColumnFilter!.matches(row.quantity)) {
      return false;
    }
    if (filters.valueColumnFilter != null &&
        !filters.valueColumnFilter!.matches(row.value)) {
      return false;
    }
    return true;
  }).toList();
}
