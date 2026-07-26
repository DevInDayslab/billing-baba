/// Polymorphic transaction attachment entity types (API-aligned).
enum DocumentAttachmentEntityType {
  sale('sale'),
  purchase('purchase'),
  estimate('estimate'),
  saleOrder('sale_order'),
  purchaseOrder('purchase_order'),
  deliveryChallan('delivery_challan'),
  paymentIn('payment_in'),
  paymentOut('payment_out'),
  expense('expense'),
  jobWork('job_work');

  const DocumentAttachmentEntityType(this.apiValue);
  final String apiValue;
}

DocumentAttachmentEntityType? documentAttachmentEntityFromSalesType(
  String? documentType,
) {
  return switch (documentType) {
    'estimate' => DocumentAttachmentEntityType.estimate,
    'sale_order' => DocumentAttachmentEntityType.saleOrder,
    'delivery_challan' => DocumentAttachmentEntityType.deliveryChallan,
    'tax_invoice' ||
    'bill_of_supply' ||
    'normal_invoice' ||
    'pos' ||
    'sales_return' => DocumentAttachmentEntityType.sale,
    _ => null,
  };
}

DocumentAttachmentEntityType? documentAttachmentEntityFromPurchaseType(
  String? documentType,
) {
  return switch (documentType) {
    'purchase_order' => DocumentAttachmentEntityType.purchaseOrder,
    'purchase_bill' ||
    'purchase_return' => DocumentAttachmentEntityType.purchase,
    _ => null,
  };
}
