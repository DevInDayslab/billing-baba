import { and, eq, inArray, sql } from 'drizzle-orm';
import { paymentAllocations } from '../../../../db/schema/accounting/tables';
import { salesDocuments } from '../../../../db/schema/sales/tables';
import { resolveTimelineTypeLabel } from '../party-timeline-labels';
import type {
  PartyTimelineContext,
  PartyTimelineSource,
} from '../party-timeline.types';
import {
  isReceivableSalesDocument,
  normalizeTimelineMoney,
  parseTimelineMoney,
  partyKindMatches,
  resolveInvoicePaymentStatus,
  resolveOverdueStatus,
} from '../party-timeline.utils';

function salesAllocationSubquery(db: PartyTimelineContext['db'], businessId: string) {
  return db
    .select({
      salesDocumentId: paymentAllocations.salesDocumentId,
      allocated: sql<string>`COALESCE(SUM(${paymentAllocations.allocatedAmount}::numeric), 0)`.as(
        'sales_allocated',
      ),
    })
    .from(paymentAllocations)
    .where(
      and(
        eq(paymentAllocations.businessId, businessId),
        eq(paymentAllocations.isDeleted, false),
      ),
    )
    .groupBy(paymentAllocations.salesDocumentId)
    .as('sales_alloc');
}

export const salesDocumentsTimelineSource: PartyTimelineSource = {
  id: 'sales_documents',
  partyKinds: ['customer', 'both'],
  async fetch(ctx) {
    if (!partyKindMatches(ctx.partyKind, ['customer', 'both'])) {
      return [];
    }

    const salesAlloc = salesAllocationSubquery(ctx.db, ctx.businessId);

    const rows = await ctx.db
      .select({
        id: salesDocuments.id,
        documentType: salesDocuments.documentType,
        documentSeries: salesDocuments.documentSeries,
        documentNumber: salesDocuments.documentNumber,
        createdAt: salesDocuments.createdAt,
        documentDate: salesDocuments.documentDate,
        totalAmount: salesDocuments.totalAmount,
        allocated: salesAlloc.allocated,
      })
      .from(salesDocuments)
      .leftJoin(salesAlloc, eq(salesAlloc.salesDocumentId, salesDocuments.id))
      .where(
        and(
          eq(salesDocuments.businessId, ctx.businessId),
          eq(salesDocuments.partyId, ctx.partyId),
          inArray(salesDocuments.status, ['finalized', 'converted']),
          eq(salesDocuments.isDeleted, false),
        ),
      );

    return rows.map((row) => {
      const total = parseTimelineMoney(row.totalAmount);
      const paid = parseTimelineMoney(row.allocated);
      const isInvoice = isReceivableSalesDocument(row.documentType);
      const isReturn = row.documentType === 'sales_return';
      const balance = isInvoice || isReturn
        ? Math.max(0, total - paid)
        : total;

      const paymentStatus = isInvoice || isReturn
        ? resolveInvoicePaymentStatus(total, paid)
        : null;

      let status = paymentStatus;
      if (isInvoice && paymentStatus === 'Unpaid') {
        const overdue = resolveOverdueStatus(null);
        if (overdue) {
          status = overdue;
        }
      }

      return {
        id: row.id,
        source: 'sales_documents' as const,
        sourceType: row.documentType,
        type: resolveTimelineTypeLabel('sales_documents', row.documentType, {
          documentSeries: row.documentSeries,
        }),
        referenceId: row.id,
        referenceType: 'sales_documents' as const,
        referenceNumber: row.documentNumber,
        createdAt: row.createdAt,
        documentDate: row.documentDate,
        total: normalizeTimelineMoney(total),
        balance: normalizeTimelineMoney(balance),
        dueDate: null,
        status,
        paymentStatus,
      };
    });
  },
};
