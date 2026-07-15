import { and, eq } from 'drizzle-orm';
import { expenses } from '../../../../db/schema/purchases/tables';
import type {
  PartyTimelineContext,
  PartyTimelineSource,
} from '../party-timeline.types';
import {
  normalizeTimelineMoney,
  parseTimelineMoney,
  partyKindMatches,
} from '../party-timeline.utils';
import { resolveTimelineTypeLabel } from '../party-timeline-labels';

export const expensesTimelineSource: PartyTimelineSource = {
  id: 'expenses',
  partyKinds: ['supplier', 'both'],
  async fetch(ctx) {
    if (!partyKindMatches(ctx.partyKind, ['supplier', 'both'])) {
      return [];
    }

    const rows = await ctx.db
      .select({
        id: expenses.id,
        referenceNumber: expenses.referenceNumber,
        description: expenses.description,
        createdAt: expenses.createdAt,
        expenseDate: expenses.expenseDate,
        amount: expenses.amount,
      })
      .from(expenses)
      .where(
        and(
          eq(expenses.businessId, ctx.businessId),
          eq(expenses.partyId, ctx.partyId),
          eq(expenses.isDeleted, false),
        ),
      );

    return rows.map((row) => {
      const total = parseTimelineMoney(row.amount);

      return {
        id: row.id,
        source: 'expenses' as const,
        sourceType: 'expense',
        type: resolveTimelineTypeLabel('expenses', 'expense'),
        referenceId: row.id,
        referenceType: 'expenses' as const,
        referenceNumber: row.referenceNumber ?? row.description,
        createdAt: row.createdAt,
        documentDate: new Date(`${row.expenseDate}T00:00:00.000Z`),
        total: normalizeTimelineMoney(total),
        balance: normalizeTimelineMoney(total),
        dueDate: null,
        status: 'Paid',
        paymentStatus: 'Paid',
      };
    });
  },
};
