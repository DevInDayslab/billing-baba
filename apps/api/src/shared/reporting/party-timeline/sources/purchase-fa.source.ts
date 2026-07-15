import { and, eq, ne } from 'drizzle-orm';
import { purchaseFaBatches } from '../../../../db/schema/purchases/tables';
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
import { resolveTimelineTypeLabel } from '../party-timeline-labels';

export const purchaseFaTimelineSource: PartyTimelineSource = {
  id: 'purchase_fa_batches',
  partyKinds: ['supplier', 'both'],
  async fetch(ctx) {
    if (!partyKindMatches(ctx.partyKind, ['supplier', 'both'])) {
      return [];
    }

    const rows = await ctx.db
      .select({
        id: purchaseFaBatches.id,
        referenceNumber: purchaseFaBatches.referenceNumber,
        createdAt: purchaseFaBatches.createdAt,
        purchaseDate: purchaseFaBatches.purchaseDate,
        dueDate: purchaseFaBatches.dueDate,
        totalAmount: purchaseFaBatches.totalAmount,
        balanceDue: purchaseFaBatches.balanceDue,
        status: purchaseFaBatches.status,
      })
      .from(purchaseFaBatches)
      .where(
        and(
          eq(purchaseFaBatches.businessId, ctx.businessId),
          eq(purchaseFaBatches.partyId, ctx.partyId),
          eq(purchaseFaBatches.isDeleted, false),
          ne(purchaseFaBatches.status, 'cancelled'),
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
        source: 'purchase_fa_batches' as const,
        sourceType: row.status,
        type: resolveTimelineTypeLabel('purchase_fa_batches', row.status),
        referenceId: row.id,
        referenceType: 'purchase_fa_batches' as const,
        referenceNumber: row.referenceNumber,
        createdAt: row.createdAt,
        documentDate: new Date(`${row.purchaseDate}T00:00:00.000Z`),
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
