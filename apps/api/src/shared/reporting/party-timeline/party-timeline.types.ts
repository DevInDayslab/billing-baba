import type { PartyLedgerFilter } from '../party-ledger';

export type PartyTimelineSourceId =
  | 'sales_documents'
  | 'purchase_documents'
  | 'payments'
  | 'expenses'
  | 'sale_fa_batches'
  | 'purchase_fa_batches'
  | 'job_work_orders';

export type PartyKind = 'customer' | 'supplier' | 'both';

export type PartyTimelineRow = {
  id: string;
  source: PartyTimelineSourceId;
  sourceType: string;
  type: string;
  referenceId: string;
  referenceType: PartyTimelineSourceId;
  referenceNumber: string | null;
  createdAt: Date;
  documentDate: Date;
  total: string;
  balance: string;
  dueDate: string | null;
  status: string | null;
  direction?: 'received' | 'paid';
  paymentStatus?: 'Paid' | 'Partial' | 'Unpaid' | null;
};

export type PartyTimelineContext = {
  db: import('../../../db/client').Database;
  businessId: string;
  partyId: string;
  partyKind: PartyKind;
  filter?: PartyLedgerFilter;
  from?: string;
  to?: string;
};

export type PartyTimelineSource = {
  id: PartyTimelineSourceId;
  partyKinds: PartyKind[];
  fetch: (ctx: PartyTimelineContext) => Promise<PartyTimelineRow[]>;
};
