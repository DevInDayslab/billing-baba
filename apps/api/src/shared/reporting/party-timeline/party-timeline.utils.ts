import type { PartyLedgerFilter } from '../party-ledger';
import type {
  PartyKind,
  PartyTimelineRow,
  PartyTimelineSourceId,
} from './party-timeline.types';

const REVENUE_SALES_TYPES = new Set([
  'tax_invoice',
  'bill_of_supply',
  'normal_invoice',
  'pos',
]);

const PURCHASE_BILL_TYPES = new Set(['purchase_bill']);

export function resolvePartyKind(partyType: string): PartyKind {
  if (partyType === 'supplier') return 'supplier';
  if (partyType === 'both') return 'both';
  return 'customer';
}

export function partyKindMatches(
  partyKind: PartyKind,
  allowed: PartyKind[],
): boolean {
  if (allowed.includes('both')) {
    return true;
  }
  if (partyKind === 'both') {
    return true;
  }
  return allowed.includes(partyKind);
}

export function normalizeTimelineMoney(value: number): string {
  return value.toFixed(2);
}

export function parseTimelineMoney(value: string | number | null | undefined): number {
  return Number(value ?? 0);
}

export function resolveInvoicePaymentStatus(
  total: number,
  paid: number,
): 'Paid' | 'Partial' | 'Unpaid' | null {
  if (total <= 0) {
    return null;
  }
  if (paid >= total) {
    return 'Paid';
  }
  if (paid > 0) {
    return 'Partial';
  }
  return 'Unpaid';
}

export function resolveOverdueStatus(dueDate: string | null): string | null {
  if (!dueDate) {
    return null;
  }

  const due = new Date(`${dueDate}T00:00:00.000Z`);
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);

  if (due >= today) {
    return null;
  }

  const diffMs = today.getTime() - due.getTime();
  const diffDays = Math.max(1, Math.floor(diffMs / (1000 * 60 * 60 * 24)));
  return `Overdue ${diffDays} Day${diffDays === 1 ? '' : 's'}`;
}

export function resolveFaStatusLabel(status: string): string {
  return status
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

export function resolveJobWorkStatusLabel(status: string): string {
  return status.charAt(0).toUpperCase() + status.slice(1);
}

export function isReceivableSalesDocument(sourceType: string): boolean {
  return REVENUE_SALES_TYPES.has(sourceType);
}

export function isPayablePurchaseDocument(sourceType: string): boolean {
  return PURCHASE_BILL_TYPES.has(sourceType);
}

export function applyTimelineFilter(
  rows: PartyTimelineRow[],
  filter: PartyLedgerFilter | undefined,
): PartyTimelineRow[] {
  if (!filter || filter === 'all') {
    return rows;
  }

  return rows.filter((row) => timelineRowMatchesFilter(row, filter));
}

function timelineRowMatchesFilter(
  row: PartyTimelineRow,
  filter: PartyLedgerFilter,
): boolean {
  switch (filter) {
    case 'sales':
      return (
        row.source === 'sales_documents' &&
        row.sourceType !== 'sales_return'
      ) ||
        row.source === 'sale_fa_batches' ||
        row.source === 'job_work_orders';
    case 'purchases':
      return (
        row.source === 'purchase_documents' &&
        row.sourceType !== 'purchase_return'
      ) ||
        row.source === 'purchase_fa_batches' ||
        row.source === 'expenses';
    case 'payments':
      return row.source === 'payments';
    case 'returns':
      return (
        row.sourceType === 'sales_return' ||
        row.sourceType === 'purchase_return'
      );
    default:
      return true;
  }
}

export function applyTimelineDateFilter(
  rows: PartyTimelineRow[],
  from?: string,
  to?: string,
): PartyTimelineRow[] {
  return rows.filter((row) => {
    const createdDate = row.createdAt.toISOString().slice(0, 10);
    if (from && createdDate < from) {
      return false;
    }
    if (to && createdDate > to) {
      return false;
    }
    return true;
  });
}

export function mapTimelineEntryType(
  row: PartyTimelineRow,
): string {
  if (row.source === 'payments') {
    return 'payment';
  }
  if (row.source === 'expenses') {
    return 'expense';
  }
  if (row.sourceType === 'sales_return' || row.sourceType === 'purchase_return') {
    return 'return';
  }
  if (row.source === 'purchase_documents') {
    return 'purchase';
  }
  if (
    row.source === 'sales_documents' &&
    isReceivableSalesDocument(row.sourceType)
  ) {
    return 'sale';
  }
  return row.sourceType;
}

export function mapTimelineDebitCredit(row: PartyTimelineRow): {
  debit: string;
  credit: string;
} {
  const total = parseTimelineMoney(row.total);

  if (row.source === 'payments') {
    if (row.direction === 'paid') {
      return { debit: normalizeTimelineMoney(total), credit: '0.00' };
    }
    return { debit: '0.00', credit: normalizeTimelineMoney(total) };
  }

  if (
    row.source === 'purchase_documents' ||
    row.source === 'purchase_fa_batches' ||
    row.source === 'expenses'
  ) {
    if (row.sourceType === 'purchase_return') {
      return { debit: '0.00', credit: normalizeTimelineMoney(total) };
    }
    return { debit: normalizeTimelineMoney(total), credit: '0.00' };
  }

  if (row.sourceType === 'sales_return') {
    return { debit: normalizeTimelineMoney(total), credit: '0.00' };
  }

  return { debit: '0.00', credit: normalizeTimelineMoney(total) };
}

export function sourceUsesPaymentDirection(
  source: PartyTimelineSourceId,
): boolean {
  return source === 'payments';
}
