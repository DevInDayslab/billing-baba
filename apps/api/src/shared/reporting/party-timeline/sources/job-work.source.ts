import { and, eq, ne } from 'drizzle-orm';
import { jobWorkOrders } from '../../../../db/schema/job-work/tables';
import { resolveTimelineTypeLabel } from '../party-timeline-labels';
import type {
  PartyTimelineContext,
  PartyTimelineSource,
} from '../party-timeline.types';
import {
  normalizeTimelineMoney,
  parseTimelineMoney,
  partyKindMatches,
  resolveJobWorkStatusLabel,
} from '../party-timeline.utils';

export const jobWorkTimelineSource: PartyTimelineSource = {
  id: 'job_work_orders',
  partyKinds: ['customer', 'both'],
  async fetch(ctx) {
    if (!partyKindMatches(ctx.partyKind, ['customer', 'both'])) {
      return [];
    }

    const rows = await ctx.db
      .select({
        id: jobWorkOrders.id,
        jobNumber: jobWorkOrders.jobNumber,
        createdAt: jobWorkOrders.createdAt,
        orderDate: jobWorkOrders.orderDate,
        deliveryDate: jobWorkOrders.deliveryDate,
        grandTotal: jobWorkOrders.grandTotal,
        status: jobWorkOrders.status,
      })
      .from(jobWorkOrders)
      .where(
        and(
          eq(jobWorkOrders.businessId, ctx.businessId),
          eq(jobWorkOrders.partyId, ctx.partyId),
          eq(jobWorkOrders.isDeleted, false),
          ne(jobWorkOrders.status, 'cancelled'),
        ),
      );

    return rows.map((row) => {
      const total = parseTimelineMoney(row.grandTotal);

      return {
        id: row.id,
        source: 'job_work_orders' as const,
        sourceType: row.status,
        type: resolveTimelineTypeLabel('job_work_orders', row.status),
        referenceId: row.id,
        referenceType: 'job_work_orders' as const,
        referenceNumber: row.jobNumber,
        createdAt: row.createdAt,
        documentDate: row.orderDate,
        total: normalizeTimelineMoney(total),
        balance: normalizeTimelineMoney(total),
        dueDate: row.deliveryDate
          ? row.deliveryDate.toISOString().slice(0, 10)
          : null,
        status: resolveJobWorkStatusLabel(row.status),
        paymentStatus: null,
      };
    });
  },
};
