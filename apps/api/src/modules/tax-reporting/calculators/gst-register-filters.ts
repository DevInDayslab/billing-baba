import type {
  GstDataset,
  GstPurchaseDocumentModel,
  GstSalesDocumentModel,
} from '../../gst-reports/core/models';
import type { TaxReportQuery } from '../tax-reporting.schema';

export type RegisterDoc =
  | { side: 'sale'; doc: GstSalesDocumentModel }
  | { side: 'purchase'; doc: GstPurchaseDocumentModel };

export function transactionKind(
  doc: GstSalesDocumentModel | GstPurchaseDocumentModel,
  side: 'sale' | 'purchase',
): 'sale' | 'purchase' | 'credit_note' | 'debit_note' {
  if (side === 'sale') {
    return doc.documentType === 'sales_return' ? 'credit_note' : 'sale';
  }
  return doc.documentType === 'purchase_return' ? 'debit_note' : 'purchase';
}

export function transactionLabel(kind: ReturnType<typeof transactionKind>): string {
  return (
    {
      sale: 'Sale',
      purchase: 'Purchase',
      credit_note: 'Credit Note',
      debit_note: 'Debit Note',
    } as const
  )[kind];
}

function matchesSearch(doc: RegisterDoc, q: string): boolean {
  const needle = q.toLowerCase();
  const { doc: d } = doc;
  const number = (d.documentNumber ?? '').toLowerCase();
  const party = (d.party.name ?? '').toLowerCase();
  return number.includes(needle) || party.includes(needle);
}

export function filterRegisterDocs(
  dataset: GstDataset,
  query: TaxReportQuery,
): RegisterDoc[] {
  const rows: RegisterDoc[] = [
    ...dataset.sales.map((doc) => ({ side: 'sale' as const, doc })),
    ...dataset.purchases.map((doc) => ({ side: 'purchase' as const, doc })),
  ];

  return rows.filter((entry) => {
    const { doc } = entry;
    if (query.party_id && doc.party.id !== query.party_id) return false;

    const kind = transactionKind(doc, entry.side);
    if (query.transaction_type !== 'all' && query.transaction_type !== kind) {
      return false;
    }

    if (query.gst_formal === 'formal' && !doc.isGstFormal) return false;
    if (query.gst_formal === 'non_formal' && doc.isGstFormal) return false;

    if (query.q && !matchesSearch(entry, query.q)) return false;

    return true;
  });
}
