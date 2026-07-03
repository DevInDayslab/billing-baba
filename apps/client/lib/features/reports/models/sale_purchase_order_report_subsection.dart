enum SalePurchaseOrderReportSubSection {
  salePurchaseOrders('Sale/Purchase Orders'),
  salePurchaseOrderItem('Sale/Purchase Order Item');

  const SalePurchaseOrderReportSubSection(this.label);

  final String label;
}
