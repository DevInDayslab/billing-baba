import { and, eq, ne, sql } from 'drizzle-orm';
import {
  paymentAllocations,
  payments,
} from '../../../../db/schema/accounting/tables';
import { resolveTimelineTypeLabel } from '../party-timeline-labels';
import type {
  PartyTimelineContext,
  PartyTimelineSource,
} from '../party-timeline.types';
import {
  normalizeTimelineMoney,
  parseTimelineMoney,
} from '../party-timeline.utils';

function paymentAllocationSubquery(
  db: PartyTimelineContext['db'],
  businessId: string,
) {
  return db
    .select({
      paymentId: paymentAllocations.paymentId,
      allocated: sql<string>`COALESCE(SUM(${paymentAllocations.allocatedAmount}::numeric), 0)`.as(
        'payment_allocated',
      ),
    })
    .from(paymentAllocations)
    .where(
      and(
        eq(paymentAllocations.businessId, businessId),
        eq(paymentAllocations.isDeleted, false),
      ),
    )
    .groupBy(paymentAllocations.paymentId)
    .as('payment_alloc');
}

export const paymentsTimelineSource: PartyTimelineSource = {
  id: 'payments',
  partyKinds: ['customer', 'supplier', 'both'],
  async fetch(ctx) {
    const paymentAlloc = paymentAllocationSubquery(ctx.db, ctx.businessId);

    const rows = await ctx.db
      .select({
        id: payments.id,
        direction: payments.direction,
        referenceNumber: payments.referenceNumber,
        createdAt: payments.createdAt,
        paymentDate: payments.paymentDate,
        amount: payments.amount,
        allocated: paymentAlloc.allocated,
      })
      .from(payments)
      .leftJoin(paymentAlloc, eq(paymentAlloc.paymentId, payments.id))
      .where(
        and(
          eq(payments.businessId, ctx.businessId),
          eq(payments.partyId, ctx.partyId),
          eq(payments.isDeleted, false),
          ne(payments.source, 'document_finalize'),
        ),
      );

    return rows
      .filter((row) => {
        if (ctx.partyKind === 'customer') {
          return row.direction === 'received';
        }
        if (ctx.partyKind === 'supplier') {
          return row.direction === 'paid';
        }
        return true;
      })
      .map((row) => {
        const total = parseTimelineMoney(row.amount);
        const allocated = parseTimelineMoney(row.allocated);
        const unused = Math.max(0, total - allocated);
        const direction = row.direction as 'received' | 'paid';

        return {
          id: row.id,
          source: 'payments' as const,
          sourceType: direction,
          type: resolveTimelineTypeLabel('payments', direction),
          referenceId: row.id,
          referenceType: 'payments' as const,
          referenceNumber: row.referenceNumber,
          createdAt: row.createdAt,
          documentDate: row.paymentDate,
          total: normalizeTimelineMoney(total),
          balance: normalizeTimelineMoney(unused),
          dueDate: null,
          status: unused > 0 ? 'Unpaid' : 'Paid',
          direction,
          paymentStatus: unused > 0 ? 'Unpaid' : 'Paid',
        };
      });
  },
};
