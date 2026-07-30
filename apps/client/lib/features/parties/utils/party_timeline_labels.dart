const _proformaSeries = 'PI';

const _salesDocumentLabels = <String, String>{
  'sale_order': 'Sale Order',
  'delivery_challan': 'Delivery Challan',
  'tax_invoice': 'Sale Invoice',
  'bill_of_supply': 'Sale Invoice',
  'normal_invoice': 'Sale Invoice',
  'pos': 'Sale Invoice',
  'sales_return': 'Sale Return / Credit Note',
};

const _purchaseDocumentLabels = <String, String>{
  'purchase_order': 'Purchase Order',
  'purchase_bill': 'Purchase Bill',
  'purchase_return': 'Purchase Return / Debit Note',
};

String resolveTimelineTypeLabel({
  required String source,
  required String sourceType,
  String? documentSeries,
}) {
  if (source == 'sales_documents') {
    if (sourceType == 'estimate') {
      return documentSeries == _proformaSeries
          ? 'Proforma Invoice'
          : 'Estimate / Quotation';
    }
    return _salesDocumentLabels[sourceType] ??
        _formatSourceTypeLabel(sourceType);
  }

  if (source == 'purchase_documents') {
    return _purchaseDocumentLabels[sourceType] ??
        _formatSourceTypeLabel(sourceType);
  }

  if (source == 'payments') {
    return sourceType == 'paid' ? 'Payment Out' : 'Payment In';
  }

  if (source == 'expenses') {
    return 'Expense';
  }

  return _formatSourceTypeLabel(sourceType);
}

String _formatSourceTypeLabel(String value) {
  return value
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
