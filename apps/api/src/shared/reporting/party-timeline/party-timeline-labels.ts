import type { PartyTimelineSourceId } from './party-timeline.types';

const PROFORMA_SERIES = 'PI';

export type TimelineLabelMetadata = {
  documentSeries?: string | null;
};

export function resolveTimelineTypeLabel(
  source: PartyTimelineSourceId,
  sourceType: string,
  metadata: TimelineLabelMetadata = {},
): string {
  if (source === 'sales_documents') {
    if (sourceType === 'estimate') {
      return metadata.documentSeries === PROFORMA_SERIES
        ? 'Proforma Invoice'
        : 'Estimate / Quotation';
    }
    return (
      SALES_DOCUMENT_LABELS[sourceType] ??
      formatSourceTypeLabel(sourceType)
    );
  }

  if (source === 'purchase_documents') {
    return (
      PURCHASE_DOCUMENT_LABELS[sourceType] ??
      formatSourceTypeLabel(sourceType)
    );
  }

  if (source === 'payments') {
    return sourceType === 'paid' ? 'Payment Out' : 'Payment In';
  }

  if (source === 'expenses') {
    return 'Expense';
  }

  if (source === 'sale_fa_batches') {
    return 'Sale FA';
  }

  if (source === 'purchase_fa_batches') {
    return 'Purchase FA';
  }

  if (source === 'job_work_orders') {
    return 'Job Work Out (Challan)';
  }

  return formatSourceTypeLabel(sourceType);
}

const SALES_DOCUMENT_LABELS: Record<string, string> = {
  sale_order: 'Sale Order',
  delivery_challan: 'Delivery Challan',
  tax_invoice: 'Sale Invoice',
  bill_of_supply: 'Sale Invoice',
  normal_invoice: 'Sale Invoice',
  pos: 'Sale Invoice',
  sales_return: 'Sale Return / Credit Note',
};

const PURCHASE_DOCUMENT_LABELS: Record<string, string> = {
  purchase_order: 'Purchase Order',
  purchase_bill: 'Purchase Bill',
  purchase_return: 'Purchase Return / Debit Note',
};

function formatSourceTypeLabel(value: string): string {
  return value
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}
