import { and, eq, ne } from 'drizzle-orm';
import { saleFaBatches } from '../../../../db/schema/sales/tables';
import { resolveTimelineTypeLabel } from '../party-timeline-labels';
import type {
  PartyTimelineContext,
  PartyTimelineSource,
} from '../party-timeline.types';
import {
  normalizeTimelineMoney,
  parseTimelineMoney,
  partyKindMatches,
  resolveFaStatusLabel,
  resolveOverdueStatus,
} from '../party-timeline.utils';

export const saleFaTimelineSource: PartyTimelineSource = {
  id: 'sale_fa_batches',
  partyKinds: ['customer', 'both'],
  async fetch(ctx) {
    if (!partyKindMatches(ctx.partyKind, ['customer', 'both'])) {
      return [];
    }

    const rows = await ctx.db
      .select({
        id: saleFaBatches.id,
        referenceNumber: saleFaBatches.referenceNumber,
        createdAt: saleFaBatches.createdAt,
        saleDate: saleFaBatches.saleDate,
        dueDate: saleFaBatches.dueDate,
        totalAmount: saleFaBatches.totalAmount,
        balanceDue: saleFaBatches.balanceDue,
        status: saleFaBatches.status,
      })
      .from(saleFaBatches)
      .where(
        and(
          eq(saleFaBatches.businessId, ctx.businessId),
          eq(saleFaBatches.partyId, ctx.partyId),
          eq(saleFaBatches.isDeleted, false),
          ne(saleFaBatches.status, 'cancelled'),
        ),
      );

    return rows.map((row) => {
      const total = parseTimelineMoney(row.totalAmount);
      const balance = parseTimelineMoney(row.balanceDue);
      let status = resolveFaStatusLabel(row.status);
      if (row.status === 'unpaid' && row.dueDate) {
        status = resolveOverdueStatus(row.dueDate) ?? status;
      }

      return {
        id: row.id,
        source: 'sale_fa_batches' as const,
        sourceType: row.status,
        type: resolveTimelineTypeLabel('sale_fa_batches', row.status),
        referenceId: row.id,
        referenceType: 'sale_fa_batches' as const,
        referenceNumber: row.referenceNumber,
        createdAt: row.createdAt,
        documentDate: new Date(`${row.saleDate}T00:00:00.000Z`),
        total: normalizeTimelineMoney(total),
        balance: normalizeTimelineMoney(balance),
        dueDate: row.dueDate,
        status,
        paymentStatus:
          balance <= 0 ? 'Paid' : balance < total ? 'Partial' : 'Unpaid',
      };
    });
  },
};
