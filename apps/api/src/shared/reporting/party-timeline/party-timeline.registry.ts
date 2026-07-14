import type { PartyTimelineSource } from './party-timeline.types';
import { expensesTimelineSource } from './sources/expenses.source';
import { jobWorkTimelineSource } from './sources/job-work.source';
import { paymentsTimelineSource } from './sources/payments.source';
import { purchaseDocumentsTimelineSource } from './sources/purchase-documents.source';
import { purchaseFaTimelineSource } from './sources/purchase-fa.source';
import { saleFaTimelineSource } from './sources/sale-fa.source';
import { salesDocumentsTimelineSource } from './sources/sales-documents.source';

const timelineSources: PartyTimelineSource[] = [];

export function registerTimelineSource(source: PartyTimelineSource): void {
  timelineSources.push(source);
}

export function getTimelineSources(): readonly PartyTimelineSource[] {
  return timelineSources;
}

registerTimelineSource(salesDocumentsTimelineSource);
registerTimelineSource(purchaseDocumentsTimelineSource);
registerTimelineSource(paymentsTimelineSource);
registerTimelineSource(expensesTimelineSource);
registerTimelineSource(saleFaTimelineSource);
registerTimelineSource(purchaseFaTimelineSource);
registerTimelineSource(jobWorkTimelineSource);
