import { and, eq, inArray, sql } from 'drizzle-orm';
import { paymentAllocations } from '../../../../db/schema/accounting/tables';
import { purchaseDocuments } from '../../../../db/schema/purchases/tables';
import type {
  PartyTimelineContext,
  PartyTimelineSource,
} from '../party-timeline.types';
import {
  isPayablePurchaseDocument,
  normalizeTimelineMoney,
  parseTimelineMoney,
  partyKindMatches,
  resolveInvoicePaymentStatus,
  resolveOverdueStatus,
} from '../party-timeline.utils';
import { resolveTimelineTypeLabel } from '../party-timeline-labels';

function purchaseAllocationSubquery(
  db: PartyTimelineContext['db'],
  businessId: string,
) {
  return db
    .select({
      purchaseDocumentId: paymentAllocations.purchaseDocumentId,
      allocated:
        sql<string>`COALESCE(SUM(${paymentAllocations.allocatedAmount}::numeric), 0)`.as(
          'purchase_allocated',
        ),
    })
    .from(paymentAllocations)
    .where(
      and(
        eq(paymentAllocations.businessId, businessId),
        eq(paymentAllocations.isDeleted, false),
      ),
    )
    .groupBy(paymentAllocations.purchaseDocumentId)
    .as('purchase_alloc');
}

export const purchaseDocumentsTimelineSource: PartyTimelineSource = {
  id: 'purchase_documents',
  partyKinds: ['supplier', 'both'],
  async fetch(ctx) {
    if (!partyKindMatches(ctx.partyKind, ['supplier', 'both'])) {
      return [];
    }

    const purchaseAlloc = purchaseAllocationSubquery(ctx.db, ctx.businessId);

    const rows = await ctx.db
      .select({
        id: purchaseDocuments.id,
        documentType: purchaseDocuments.documentType,
        documentNumber: purchaseDocuments.documentNumber,
        createdAt: purchaseDocuments.createdAt,
        documentDate: purchaseDocuments.documentDate,
        dueDate: purchaseDocuments.dueDate,
        totalAmount: purchaseDocuments.totalAmount,
        allocated: purchaseAlloc.allocated,
      })
      .from(purchaseDocuments)
      .leftJoin(
        purchaseAlloc,
        eq(purchaseAlloc.purchaseDocumentId, purchaseDocuments.id),
      )
      .where(
        and(
          eq(purchaseDocuments.businessId, ctx.businessId),
          eq(purchaseDocuments.partyId, ctx.partyId),
          inArray(purchaseDocuments.status, ['finalized', 'converted']),
          eq(purchaseDocuments.isDeleted, false),
        ),
      );

    return rows.map((row) => {
      const total = parseTimelineMoney(row.totalAmount);
      const paid = parseTimelineMoney(row.allocated);
      const isBill = isPayablePurchaseDocument(row.documentType);
      const isReturn = row.documentType === 'purchase_return';
      const balance = isBill || isReturn ? Math.max(0, total - paid) : total;

      const paymentStatus =
        isBill || isReturn ? resolveInvoicePaymentStatus(total, paid) : null;

      let status: string | null = paymentStatus;
      if (isBill && paymentStatus === 'Unpaid' && row.dueDate) {
        status = resolveOverdueStatus(row.dueDate) ?? paymentStatus;
      }

      return {
        id: row.id,
        source: 'purchase_documents' as const,
        sourceType: row.documentType,
        type: resolveTimelineTypeLabel('purchase_documents', row.documentType),
        referenceId: row.id,
        referenceType: 'purchase_documents' as const,
        referenceNumber: row.documentNumber,
        createdAt: row.createdAt,
        documentDate: row.documentDate,
        total: normalizeTimelineMoney(total),
        balance: normalizeTimelineMoney(balance),
        dueDate: row.dueDate,
        status,
        paymentStatus,
      };
    });
  },
};
