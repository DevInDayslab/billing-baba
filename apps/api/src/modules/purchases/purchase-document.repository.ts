import {
  and,
  asc,
  count,
  desc,
  eq,
  gte,
  ilike,
  isNotNull,
  lte,
  sql,
} from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  paymentAllocations,
  payments,
} from '../../db/schema/accounting/tables';
import { parties } from '../../db/schema/crm/tables';
import { godowns, items } from '../../db/schema/inventory/tables';
import {
  purchaseDocumentLines,
  purchaseDocuments,
} from '../../db/schema/purchases/tables';
import {
  toPurchaseDocumentLineRecord,
  toPurchaseDocumentRecord,
} from './purchase-document.mapper';
import type {
  ListPurchaseDocumentsParams,
  PurchaseDocumentInsertValues,
  PurchaseDocumentRecord,
  PurchaseDocumentUpdateValues,
  PurchaseLineInsertValues,
  PurchaseLineUpdateValues,
} from './purchase-document.types';

export class PurchaseDocumentRepository {
  constructor(private readonly db: Database) {}

  private allocationTotalsSubquery(businessId: string) {
    return this.db
      .select({
        purchaseDocumentId: paymentAllocations.purchaseDocumentId,
        allocated:
          sql<string>`COALESCE(SUM(${paymentAllocations.allocatedAmount}::numeric), 0)`.as(
            'allocated',
          ),
      })
      .from(paymentAllocations)
      .where(
        and(
          eq(paymentAllocations.businessId, businessId),
          eq(paymentAllocations.isDeleted, false),
          isNotNull(paymentAllocations.purchaseDocumentId),
        ),
      )
      .groupBy(paymentAllocations.purchaseDocumentId)
      .as('alloc');
  }

  private firstPaymentModeSubquery(businessId: string) {
    const ranked = this.db
      .select({
        purchaseDocumentId: paymentAllocations.purchaseDocumentId,
        paymentMode: payments.paymentMode,
        rowNum: sql<number>`ROW_NUMBER() OVER (
          PARTITION BY ${paymentAllocations.purchaseDocumentId}
          ORDER BY ${paymentAllocations.createdAt} ASC
        )`.as('row_num'),
      })
      .from(paymentAllocations)
      .innerJoin(payments, eq(paymentAllocations.paymentId, payments.id))
      .where(
        and(
          eq(paymentAllocations.businessId, businessId),
          eq(paymentAllocations.isDeleted, false),
          eq(payments.isDeleted, false),
          isNotNull(paymentAllocations.purchaseDocumentId),
        ),
      )
      .as('ranked_payments');

    return this.db
      .select({
        purchaseDocumentId: ranked.purchaseDocumentId,
        paymentMode: ranked.paymentMode,
      })
      .from(ranked)
      .where(eq(ranked.rowNum, 1))
      .as('first_payment');
  }

  async list(params: ListPurchaseDocumentsParams): Promise<{
    rows: PurchaseDocumentRecord[];
    total: number;
  }> {
    const filters = [
      eq(purchaseDocuments.businessId, params.businessId),
      eq(purchaseDocuments.isDeleted, false),
    ];

    if (params.documentType) {
      filters.push(eq(purchaseDocuments.documentType, params.documentType));
    }
    if (params.status) {
      filters.push(eq(purchaseDocuments.status, params.status));
    }
    if (params.partyId) {
      filters.push(eq(purchaseDocuments.partyId, params.partyId));
    }
    if (params.from) {
      filters.push(gte(purchaseDocuments.documentDate, params.from));
    }
    if (params.to) {
      filters.push(lte(purchaseDocuments.documentDate, params.to));
    }
    if (params.q) {
      filters.push(ilike(purchaseDocuments.documentNumber, `%${params.q}%`));
    }

    const whereClause = and(...filters);

    const countResult = await this.db
      .select({ total: count() })
      .from(purchaseDocuments)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? purchaseDocuments.createdAt
        : params.sort === 'document_number'
          ? purchaseDocuments.documentNumber
          : purchaseDocuments.documentDate;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const alloc = this.allocationTotalsSubquery(params.businessId);
    const firstPayment = this.firstPaymentModeSubquery(params.businessId);

    const rows = await this.db
      .select({
        id: purchaseDocuments.id,
        documentType: purchaseDocuments.documentType,
        status: purchaseDocuments.status,
        documentNumber: purchaseDocuments.documentNumber,
        documentSeries: purchaseDocuments.documentSeries,
        partyId: purchaseDocuments.partyId,
        isGstFormal: purchaseDocuments.isGstFormal,
        partyStateCode: purchaseDocuments.partyStateCode,
        subtotal: purchaseDocuments.subtotal,
        discountTotal: purchaseDocuments.discountTotal,
        taxAmount: purchaseDocuments.taxAmount,
        totalAmount: purchaseDocuments.totalAmount,
        documentDate: purchaseDocuments.documentDate,
        convertedFromId: purchaseDocuments.convertedFromId,
        supplierInvoiceNumber: purchaseDocuments.supplierInvoiceNumber,
        dueDate: purchaseDocuments.dueDate,
        notes: purchaseDocuments.notes,
        createdAt: purchaseDocuments.createdAt,
        updatedAt: purchaseDocuments.updatedAt,
        paidAmount: sql<string>`COALESCE(${alloc.allocated}, 0)`,
        paymentMode: firstPayment.paymentMode,
      })
      .from(purchaseDocuments)
      .leftJoin(alloc, eq(alloc.purchaseDocumentId, purchaseDocuments.id))
      .leftJoin(
        firstPayment,
        eq(firstPayment.purchaseDocumentId, purchaseDocuments.id),
      )
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toPurchaseDocumentRecord(row)),
      total,
    };
  }

  async findById(
    businessId: string,
    documentId: string,
    includeLines = false,
  ): Promise<PurchaseDocumentRecord | null> {
    const [row] = await this.db
      .select()
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.id, documentId),
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
        ),
      )
      .limit(1);

    if (!row) {
      return null;
    }

    if (!includeLines) {
      return toPurchaseDocumentRecord(row);
    }

    const lines = await this.listLines(businessId, documentId);
    return toPurchaseDocumentRecord(row, lines);
  }

  async findRowById(
    businessId: string,
    documentId: string,
  ): Promise<typeof purchaseDocuments.$inferSelect | null> {
    const [row] = await this.db
      .select()
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.id, documentId),
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async create(
    values: PurchaseDocumentInsertValues,
  ): Promise<PurchaseDocumentRecord> {
    const [row] = await this.db
      .insert(purchaseDocuments)
      .values({
        businessId: values.businessId,
        documentType: values.documentType,
        documentSeries: values.documentSeries,
        partyId: values.partyId,
        isGstFormal: values.isGstFormal ?? false,
        partyStateCode: values.partyStateCode ?? null,
        documentDate: values.documentDate ?? new Date(),
        convertedFromId: values.convertedFromId ?? null,
        supplierInvoiceNumber: values.supplierInvoiceNumber ?? null,
        dueDate: values.dueDate ?? null,
        notes: values.notes ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create purchase document');
    }

    return toPurchaseDocumentRecord(row);
  }

  async update(
    businessId: string,
    documentId: string,
    values: PurchaseDocumentUpdateValues,
  ): Promise<PurchaseDocumentRecord | null> {
    const [row] = await this.db
      .update(purchaseDocuments)
      .set({
        ...(values.partyId !== undefined ? { partyId: values.partyId } : {}),
        ...(values.isGstFormal !== undefined
          ? { isGstFormal: values.isGstFormal }
          : {}),
        ...(values.partyStateCode !== undefined
          ? { partyStateCode: values.partyStateCode }
          : {}),
        ...(values.documentDate !== undefined
          ? { documentDate: values.documentDate }
          : {}),
        ...(values.documentSeries !== undefined
          ? { documentSeries: values.documentSeries }
          : {}),
        ...(values.supplierInvoiceNumber !== undefined
          ? { supplierInvoiceNumber: values.supplierInvoiceNumber }
          : {}),
        ...(values.dueDate !== undefined ? { dueDate: values.dueDate } : {}),
        ...(values.notes !== undefined ? { notes: values.notes } : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${purchaseDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(purchaseDocuments.id, documentId),
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
        ),
      )
      .returning();

    return row ? toPurchaseDocumentRecord(row) : null;
  }

  async updateTotals(
    businessId: string,
    documentId: string,
    totals: {
      subtotal: string;
      discountTotal: string;
      taxAmount: string;
      totalAmount: string;
    },
  ): Promise<void> {
    await this.db
      .update(purchaseDocuments)
      .set({
        subtotal: totals.subtotal,
        discountTotal: totals.discountTotal,
        taxAmount: totals.taxAmount,
        totalAmount: totals.totalAmount,
        updatedAt: new Date(),
        syncVersion: sql`${purchaseDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(purchaseDocuments.id, documentId),
          eq(purchaseDocuments.businessId, businessId),
        ),
      );
  }

  async markConverted(
    businessId: string,
    documentId: string,
    updatedBy?: string | null,
  ): Promise<void> {
    await this.db
      .update(purchaseDocuments)
      .set({
        status: 'converted',
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${purchaseDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(purchaseDocuments.id, documentId),
          eq(purchaseDocuments.businessId, businessId),
        ),
      );
  }

  async cancel(
    businessId: string,
    documentId: string,
    updatedBy?: string | null,
  ): Promise<PurchaseDocumentRecord | null> {
    const [row] = await this.db
      .update(purchaseDocuments)
      .set({
        status: 'cancelled',
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${purchaseDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(purchaseDocuments.id, documentId),
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
        ),
      )
      .returning();

    return row ? toPurchaseDocumentRecord(row) : null;
  }

  async softDelete(
    businessId: string,
    documentId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(purchaseDocuments)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${purchaseDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(purchaseDocuments.id, documentId),
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.status, 'draft'),
          eq(purchaseDocuments.isDeleted, false),
        ),
      )
      .returning({ id: purchaseDocuments.id });

    return Boolean(row);
  }

  async listLines(businessId: string, documentId: string) {
    return this.db
      .select()
      .from(purchaseDocumentLines)
      .where(
        and(
          eq(purchaseDocumentLines.purchaseDocumentId, documentId),
          eq(purchaseDocumentLines.businessId, businessId),
          eq(purchaseDocumentLines.isDeleted, false),
        ),
      )
      .orderBy(
        asc(purchaseDocumentLines.sortOrder),
        asc(purchaseDocumentLines.createdAt),
      );
  }

  async findLineById(businessId: string, documentId: string, lineId: string) {
    const [row] = await this.db
      .select()
      .from(purchaseDocumentLines)
      .where(
        and(
          eq(purchaseDocumentLines.id, lineId),
          eq(purchaseDocumentLines.purchaseDocumentId, documentId),
          eq(purchaseDocumentLines.businessId, businessId),
          eq(purchaseDocumentLines.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async createLine(values: PurchaseLineInsertValues) {
    const [row] = await this.db
      .insert(purchaseDocumentLines)
      .values({
        businessId: values.businessId,
        purchaseDocumentId: values.purchaseDocumentId,
        itemId: values.itemId,
        quantity: values.quantity,
        unit: values.unit,
        unitPrice: values.unitPrice,
        discountAmount: values.discountAmount ?? '0',
        taxType: values.taxType ?? 'none',
        taxRate: values.taxRate ?? '0',
        cgstAmount: values.cgstAmount ?? '0',
        sgstAmount: values.sgstAmount ?? '0',
        igstAmount: values.igstAmount ?? '0',
        lineTotal: values.lineTotal,
        sortOrder: values.sortOrder ?? 0,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create purchase document line');
    }

    return toPurchaseDocumentLineRecord(row);
  }

  async updateLine(
    businessId: string,
    lineId: string,
    values: PurchaseLineUpdateValues,
  ) {
    const [row] = await this.db
      .update(purchaseDocumentLines)
      .set({
        ...(values.itemId !== undefined ? { itemId: values.itemId } : {}),
        ...(values.quantity !== undefined ? { quantity: values.quantity } : {}),
        ...(values.unit !== undefined ? { unit: values.unit } : {}),
        ...(values.unitPrice !== undefined
          ? { unitPrice: values.unitPrice }
          : {}),
        ...(values.discountAmount !== undefined
          ? { discountAmount: values.discountAmount }
          : {}),
        ...(values.taxType !== undefined ? { taxType: values.taxType } : {}),
        ...(values.taxRate !== undefined ? { taxRate: values.taxRate } : {}),
        ...(values.cgstAmount !== undefined
          ? { cgstAmount: values.cgstAmount }
          : {}),
        ...(values.sgstAmount !== undefined
          ? { sgstAmount: values.sgstAmount }
          : {}),
        ...(values.igstAmount !== undefined
          ? { igstAmount: values.igstAmount }
          : {}),
        ...(values.lineTotal !== undefined
          ? { lineTotal: values.lineTotal }
          : {}),
        ...(values.sortOrder !== undefined
          ? { sortOrder: values.sortOrder }
          : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${purchaseDocumentLines.syncVersion} + 1`,
      })
      .where(
        and(
          eq(purchaseDocumentLines.id, lineId),
          eq(purchaseDocumentLines.businessId, businessId),
          eq(purchaseDocumentLines.isDeleted, false),
        ),
      )
      .returning();

    return row ? toPurchaseDocumentLineRecord(row) : null;
  }

  async softDeleteLine(
    businessId: string,
    documentId: string,
    lineId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(purchaseDocumentLines)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${purchaseDocumentLines.syncVersion} + 1`,
      })
      .where(
        and(
          eq(purchaseDocumentLines.id, lineId),
          eq(purchaseDocumentLines.purchaseDocumentId, documentId),
          eq(purchaseDocumentLines.businessId, businessId),
          eq(purchaseDocumentLines.isDeleted, false),
        ),
      )
      .returning({ id: purchaseDocumentLines.id });

    return Boolean(row);
  }

  async findParty(
    businessId: string,
    partyId: string,
  ): Promise<{
    id: string;
    stateCode: string | null;
    partyType: 'customer' | 'supplier' | 'both';
  } | null> {
    const [row] = await this.db
      .select({
        id: parties.id,
        stateCode: parties.stateCode,
        partyType: parties.partyType,
      })
      .from(parties)
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async findItem(
    businessId: string,
    itemId: string,
  ): Promise<{ id: string; baseUnit: string } | null> {
    const [row] = await this.db
      .select({
        id: items.id,
        baseUnit: items.baseUnit,
      })
      .from(items)
      .where(
        and(
          eq(items.id, itemId),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async getBusinessStateCode(businessId: string): Promise<string | null> {
    const { businesses } = await import('../../db/schema/business/tables');
    const [row] = await this.db
      .select({ stateCode: businesses.stateCode })
      .from(businesses)
      .where(eq(businesses.id, businessId))
      .limit(1);

    return row?.stateCode ?? null;
  }

  async godownExists(businessId: string, godownId: string): Promise<boolean> {
    const [row] = await this.db
      .select({ id: godowns.id })
      .from(godowns)
      .where(
        and(
          eq(godowns.id, godownId),
          eq(godowns.businessId, businessId),
          eq(godowns.isDeleted, false),
        ),
      )
      .limit(1);

    return Boolean(row);
  }
}
