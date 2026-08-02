import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';

const salePurchaseOrderTypeOptions = [
  'ALL ORDERS',
  'SALE ORDER',
  'PURCHASE ORDER',
  'SALE RETURN ORDER',
  'PURCHASE RETURN ORDER',
];

const salePurchaseOrderStatusOptions = [
  'All Orders',
  'Open',
  'Closed',
  'Partial',
  'Cancelled',
];

String salePurchaseOrderTypeLabel(String? typeFilter) => switch (typeFilter) {
  'sale' => 'SALE ORDER',
  'purchase' => 'PURCHASE ORDER',
  'sale_return' => 'SALE RETURN ORDER',
  'purchase_return' => 'PURCHASE RETURN ORDER',
  _ => 'ALL ORDERS',
};

String? salePurchaseOrderTypeValue(String label) => switch (label) {
  'SALE ORDER' => 'sale',
  'PURCHASE ORDER' => 'purchase',
  'SALE RETURN ORDER' => 'sale_return',
  'PURCHASE RETURN ORDER' => 'purchase_return',
  _ => null,
};

String salePurchaseOrderStatusLabel(String? statusFilter) =>
    switch (statusFilter) {
      'draft' => 'Open',
      'finalized' => 'Closed',
      'converted' => 'Partial',
      'cancelled' => 'Cancelled',
      _ => 'All Orders',
    };

String? salePurchaseOrderStatusValue(String label) => switch (label) {
  'Open' => 'draft',
  'Closed' => 'finalized',
  'Partial' => 'converted',
  'Cancelled' => 'cancelled',
  _ => null,
};

List<ReportOrderRow> filterSalePurchaseOrderRows(
  List<ReportOrderRow> rows,
  ReportFiltersState filters,
) {
  final typeFilter = filters.documentType;
  final statusFilter = filters.status;
  final query = filters.searchQuery.trim().toLowerCase();

  return rows.where((row) {
    if (typeFilter != null && row.type != typeFilter) {
      return false;
    }
    if (statusFilter != null && row.status != statusFilter) {
      return false;
    }
    if (query.isNotEmpty &&
        !row.partyName.toLowerCase().contains(query) &&
        !row.orderNo.toLowerCase().contains(query)) {
      return false;
    }
    return true;
  }).toList();
}
