import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';

PermissionModule permissionModuleForScope(SalesDocumentListScope scope) {
  return switch (scope.documentType) {
    SalesDocumentType.estimate =>
      scope.documentSeries == SalesConstants.proformaSeries
          ? PermissionModule.proforma
          : PermissionModule.estimate,
    SalesDocumentType.saleOrder => PermissionModule.saleOrder,
    SalesDocumentType.deliveryChallan => PermissionModule.deliveryChallan,
    SalesDocumentType.salesReturn => PermissionModule.creditNote,
    SalesDocumentType.taxInvoice ||
    SalesDocumentType.billOfSupply ||
    SalesDocumentType.normalInvoice ||
    SalesDocumentType.pos => PermissionModule.sale,
  };
}

PermissionModule permissionModuleForSaleRoute(String route) {
  if (route.contains('payment-in')) return PermissionModule.paymentIn;
  if (route.contains('estimate')) return PermissionModule.estimate;
  if (route.contains('proforma')) return PermissionModule.proforma;
  if (route.contains('order')) return PermissionModule.saleOrder;
  if (route.contains('delivery-challan')) {
    return PermissionModule.deliveryChallan;
  }
  if (route.contains('credit-note')) return PermissionModule.creditNote;
  if (route.contains('job-work')) return PermissionModule.sale;
  if (route.contains('fa')) return PermissionModule.sale;
  return PermissionModule.sale;
}
