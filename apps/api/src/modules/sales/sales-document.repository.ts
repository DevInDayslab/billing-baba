import {
  and,
  asc,
  count,
  desc,
  eq,
  gte,
  ilike,
  inArray,
  isNotNull,
  isNull,
  lte,
  sql,
} from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  paymentAllocations,
  payments,
} from '../../db/schema/accounting/tables';
import { parties } from '../../db/schema/crm/tables';
import { users } from '../../db/schema/identity/tables';
import {
  godowns,
  inventoryMovements,
  items,
} from '../../db/schema/inventory/tables';
import { documentNumberSequences } from '../../db/schema/settings/tables';
import {
  posSessions,
  salesDocumentLines,
  salesDocuments,
} from '../../db/schema/sales/tables';
import {
  toSalesDocumentLineRecord,
  toSalesDocumentRecord,
} from './sales-document.mapper';
import { normalizeMoney } from '../inventory/inventory.utils';
import type {
  ListSalesDocumentsFilterParams,
  ListSalesDocumentsParams,
  PosSessionRecord,
  SalesDocumentInsertValues,
  SalesDocumentRecord,
  SalesDocumentsListSummary,
  SalesDocumentUpdateValues,
  SalesLineInsertValues,
  SalesLineUpdateValues,
} from './sales-document.types';

export class SalesDocumentRepository {
  constructor(private readonly db: Database) {}

  private buildListFilters(params: ListSalesDocumentsFilterParams) {
    const filters = [
      eq(salesDocuments.businessId, params.businessId),
      eq(salesDocuments.isDeleted, false),
    ];

    if (params.documentType) {
      filters.push(eq(salesDocuments.documentType, params.documentType));
    }
    if (params.status) {
      filters.push(eq(salesDocuments.status, params.status));
    }
    if (params.partyId) {
      filters.push(eq(salesDocuments.partyId, params.partyId));
    }
    if (params.posSessionId) {
      filters.push(eq(salesDocuments.posSessionId, params.posSessionId));
    }
    if (params.from) {
      filters.push(gte(salesDocuments.documentDate, params.from));
    }
    if (params.to) {
      filters.push(lte(salesDocuments.documentDate, params.to));
    }
    if (params.q) {
      filters.push(ilike(salesDocuments.documentNumber, `%${params.q}%`));
    }

    return and(...filters);
  }

  private allocationTotalsSubquery(businessId: string) {
    return this.db
      .select({
        salesDocumentId: paymentAllocations.salesDocumentId,
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
          isNotNull(paymentAllocations.salesDocumentId),
        ),
      )
      .groupBy(paymentAllocations.salesDocumentId)
      .as('alloc');
  }

  private firstPaymentModeSubquery(businessId: string) {
    const ranked = this.db
      .select({
        salesDocumentId: paymentAllocations.salesDocumentId,
        paymentMode: payments.paymentMode,
        rowNum: sql<number>`ROW_NUMBER() OVER (
          PARTITION BY ${paymentAllocations.salesDocumentId}
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
          isNotNull(paymentAllocations.salesDocumentId),
        ),
      )
      .as('ranked_payments');

    return this.db
      .select({
        salesDocumentId: ranked.salesDocumentId,
        paymentMode: ranked.paymentMode,
      })
      .from(ranked)
      .where(eq(ranked.rowNum, 1))
      .as('first_payment');
  }

  async aggregateListSummary(
    params: ListSalesDocumentsFilterParams,
  ): Promise<SalesDocumentsListSummary> {
    const whereClause = this.buildListFilters(params);
    const alloc = this.allocationTotalsSubquery(params.businessId);

    const [totals] = await this.db
      .select({
        totalAmount: sql<string>`COALESCE(SUM(${salesDocuments.totalAmount}::numeric), 0)`,
      })
      .from(salesDocuments)
      .where(whereClause);

    const [received] = await this.db
      .select({
        receivedAmount: sql<string>`COALESCE(SUM(COALESCE(${alloc.allocated}, 0)::numeric), 0)`,
      })
      .from(salesDocuments)
      .leftJoin(alloc, eq(alloc.salesDocumentId, salesDocuments.id))
      .where(whereClause);

    const total = Number(totals?.totalAmount ?? 0);
    const receivedTotal = Number(received?.receivedAmount ?? 0);
    const balance = Math.max(total - receivedTotal, 0);

    return {
      total_amount: normalizeMoney(total),
      received_amount: normalizeMoney(receivedTotal),
      balance_amount: normalizeMoney(balance),
    };
  }

  async list(params: ListSalesDocumentsParams): Promise<{
    rows: SalesDocumentRecord[];
    total: number;
  }> {
    const whereClause = this.buildListFilters(params);

    const countResult = await this.db
      .select({ total: count() })
      .from(salesDocuments)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? salesDocuments.createdAt
        : params.sort === 'document_number'
          ? salesDocuments.documentNumber
          : salesDocuments.documentDate;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const alloc = this.allocationTotalsSubquery(params.businessId);
    const firstPayment = this.firstPaymentModeSubquery(params.businessId);

    const rows = await this.db
      .select({
        document: salesDocuments,
        paidAmount: sql<string>`COALESCE(${alloc.allocated}, 0)`,
        paymentMode: firstPayment.paymentMode,
        createdByName: users.name,
      })
      .from(salesDocuments)
      .leftJoin(alloc, eq(alloc.salesDocumentId, salesDocuments.id))
      .leftJoin(
        firstPayment,
        eq(firstPayment.salesDocumentId, salesDocuments.id),
      )
      .leftJoin(users, eq(salesDocuments.createdBy, users.id))
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    const documentIds = rows.map((row) => row.document.id);
    const godownNamesByDocumentId = await this.getGodownNamesForDocuments(
      params.businessId,
      documentIds,
    );

    return {
      rows: rows.map((row) =>
        toSalesDocumentRecord(
          {
            ...row.document,
            paidAmount: row.paidAmount,
            paymentMode: row.paymentMode,
          },
          undefined,
          {
            createdByName: row.createdByName,
            godownName: godownNamesByDocumentId.get(row.document.id) ?? null,
          },
        ),
      ),
      total,
    };
  }

  private async getGodownNamesForDocuments(
    businessId: string,
    documentIds: string[],
  ): Promise<Map<string, string>> {
    if (documentIds.length === 0) {
      return new Map();
    }

    const rows = await this.db
      .selectDistinctOn([inventoryMovements.referenceId], {
        referenceId: inventoryMovements.referenceId,
        godownName: godowns.name,
      })
      .from(inventoryMovements)
      .innerJoin(godowns, eq(inventoryMovements.godownId, godowns.id))
      .where(
        and(
          eq(inventoryMovements.businessId, businessId),
          eq(inventoryMovements.referenceType, 'sales_documents'),
          inArray(inventoryMovements.referenceId, documentIds),
        ),
      )
      .orderBy(
        inventoryMovements.referenceId,
        asc(inventoryMovements.createdAt),
      );

    const godownNames = new Map<string, string>();
    for (const row of rows) {
      if (row.referenceId != null) {
        godownNames.set(row.referenceId, row.godownName);
      }
    }

    return godownNames;
  }

  async findById(
    businessId: string,
    documentId: string,
    includeLines = false,
  ): Promise<SalesDocumentRecord | null> {
    const [row] = await this.db
      .select()
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.id, documentId),
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
        ),
      )
      .limit(1);

    if (!row) {
      return null;
    }

    if (!includeLines) {
      return toSalesDocumentRecord(row);
    }

    const lines = await this.listLines(businessId, documentId);
    return toSalesDocumentRecord(row, lines);
  }

  async findRowById(
    businessId: string,
    documentId: string,
  ): Promise<typeof salesDocuments.$inferSelect | null> {
    const [row] = await this.db
      .select()
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.id, documentId),
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async create(
    values: SalesDocumentInsertValues,
  ): Promise<SalesDocumentRecord> {
    const [row] = await this.db
      .insert(salesDocuments)
      .values({
        businessId: values.businessId,
        documentType: values.documentType,
        documentSeries: values.documentSeries,
        partyId: values.partyId ?? null,
        isGstFormal: values.isGstFormal ?? false,
        partyStateCode: values.partyStateCode ?? null,
        documentDate: values.documentDate ?? new Date(),
        convertedFromId: values.convertedFromId ?? null,
        posSessionId: values.posSessionId ?? null,
        notes: values.notes ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create sales document');
    }

    return toSalesDocumentRecord(row);
  }

  async update(
    businessId: string,
    documentId: string,
    values: SalesDocumentUpdateValues,
  ): Promise<SalesDocumentRecord | null> {
    const [row] = await this.db
      .update(salesDocuments)
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
        ...(values.notes !== undefined ? { notes: values.notes } : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${salesDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(salesDocuments.id, documentId),
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
        ),
      )
      .returning();

    return row ? toSalesDocumentRecord(row) : null;
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
      .update(salesDocuments)
      .set({
        subtotal: totals.subtotal,
        discountTotal: totals.discountTotal,
        taxAmount: totals.taxAmount,
        totalAmount: totals.totalAmount,
        updatedAt: new Date(),
        syncVersion: sql`${salesDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(salesDocuments.id, documentId),
          eq(salesDocuments.businessId, businessId),
        ),
      );
  }

  async finalize(
    businessId: string,
    documentId: string,
    documentNumber: string,
    updatedBy?: string | null,
  ): Promise<SalesDocumentRecord | null> {
    const [row] = await this.db
      .update(salesDocuments)
      .set({
        status: 'finalized',
        documentNumber,
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${salesDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(salesDocuments.id, documentId),
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.status, 'draft'),
          eq(salesDocuments.isDeleted, false),
        ),
      )
      .returning();

    return row ? toSalesDocumentRecord(row) : null;
  }

  async markConverted(
    businessId: string,
    documentId: string,
    updatedBy?: string | null,
  ): Promise<void> {
    await this.db
      .update(salesDocuments)
      .set({
        status: 'converted',
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${salesDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(salesDocuments.id, documentId),
          eq(salesDocuments.businessId, businessId),
        ),
      );
  }

  async cancel(
    businessId: string,
    documentId: string,
    updatedBy?: string | null,
  ): Promise<SalesDocumentRecord | null> {
    const [row] = await this.db
      .update(salesDocuments)
      .set({
        status: 'cancelled',
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${salesDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(salesDocuments.id, documentId),
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
        ),
      )
      .returning();

    return row ? toSalesDocumentRecord(row) : null;
  }

  async softDelete(
    businessId: string,
    documentId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(salesDocuments)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${salesDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(salesDocuments.id, documentId),
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.status, 'draft'),
          eq(salesDocuments.isDeleted, false),
        ),
      )
      .returning({ id: salesDocuments.id });

    return Boolean(row);
  }

  async listLines(businessId: string, documentId: string) {
    return this.db
      .select()
      .from(salesDocumentLines)
      .where(
        and(
          eq(salesDocumentLines.salesDocumentId, documentId),
          eq(salesDocumentLines.businessId, businessId),
          eq(salesDocumentLines.isDeleted, false),
        ),
      )
      .orderBy(
        asc(salesDocumentLines.sortOrder),
        asc(salesDocumentLines.createdAt),
      );
  }

  async findLineById(businessId: string, documentId: string, lineId: string) {
    const [row] = await this.db
      .select()
      .from(salesDocumentLines)
      .where(
        and(
          eq(salesDocumentLines.id, lineId),
          eq(salesDocumentLines.salesDocumentId, documentId),
          eq(salesDocumentLines.businessId, businessId),
          eq(salesDocumentLines.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async createLine(values: SalesLineInsertValues) {
    const [row] = await this.db
      .insert(salesDocumentLines)
      .values({
        businessId: values.businessId,
        salesDocumentId: values.salesDocumentId,
        itemId: values.itemId,
        quantity: values.quantity,
        unit: values.unit,
        unitPrice: values.unitPrice,
        marketPrice: values.marketPrice ?? null,
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
      throw new Error('Failed to create sales document line');
    }

    return toSalesDocumentLineRecord(row);
  }

  async updateLine(
    businessId: string,
    lineId: string,
    values: SalesLineUpdateValues,
  ) {
    const [row] = await this.db
      .update(salesDocumentLines)
      .set({
        ...(values.itemId !== undefined ? { itemId: values.itemId } : {}),
        ...(values.quantity !== undefined ? { quantity: values.quantity } : {}),
        ...(values.unit !== undefined ? { unit: values.unit } : {}),
        ...(values.unitPrice !== undefined
          ? { unitPrice: values.unitPrice }
          : {}),
        ...(values.marketPrice !== undefined
          ? { marketPrice: values.marketPrice }
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
        syncVersion: sql`${salesDocumentLines.syncVersion} + 1`,
      })
      .where(
        and(
          eq(salesDocumentLines.id, lineId),
          eq(salesDocumentLines.businessId, businessId),
          eq(salesDocumentLines.isDeleted, false),
        ),
      )
      .returning();

    return row ? toSalesDocumentLineRecord(row) : null;
  }

  async softDeleteLine(
    businessId: string,
    documentId: string,
    lineId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(salesDocumentLines)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${salesDocumentLines.syncVersion} + 1`,
      })
      .where(
        and(
          eq(salesDocumentLines.id, lineId),
          eq(salesDocumentLines.salesDocumentId, documentId),
          eq(salesDocumentLines.businessId, businessId),
          eq(salesDocumentLines.isDeleted, false),
        ),
      )
      .returning({ id: salesDocumentLines.id });

    return Boolean(row);
  }

  async findParty(
    businessId: string,
    partyId: string,
  ): Promise<{
    id: string;
    stateCode: string | null;
    creditLimit: string;
  } | null> {
    const [row] = await this.db
      .select({
        id: parties.id,
        stateCode: parties.stateCode,
        creditLimit: parties.creditLimit,
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
  ): Promise<{ id: string; baseUnit: string; brandId: string | null } | null> {
    const [row] = await this.db
      .select({
        id: items.id,
        baseUnit: items.baseUnit,
        brandId: items.brandId,
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
    const { businesses } = await import('../../db/schema/business/tables.js');
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

  async openPosSessionExists(
    businessId: string,
    sessionId: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .select({ id: posSessions.id })
      .from(posSessions)
      .where(
        and(
          eq(posSessions.id, sessionId),
          eq(posSessions.businessId, businessId),
          eq(posSessions.isDeleted, false),
          isNull(posSessions.endedAt),
        ),
      )
      .limit(1);

    return Boolean(row);
  }

  async listDocumentSequences(
    businessId: string,
    fiscalYear: string,
  ): Promise<
    Array<{
      id: string;
      document_series: string;
      prefix: string | null;
      next_number: number;
      fiscal_year: string;
    }>
  > {
    const rows = await this.db
      .select()
      .from(documentNumberSequences)
      .where(
        and(
          eq(documentNumberSequences.businessId, businessId),
          eq(documentNumberSequences.fiscalYear, fiscalYear),
          eq(documentNumberSequences.isDeleted, false),
        ),
      )
      .orderBy(asc(documentNumberSequences.documentSeries));

    return rows.map((row) => ({
      id: row.id,
      document_series: row.documentSeries,
      prefix: row.prefix,
      next_number: row.nextNumber,
      fiscal_year: row.fiscalYear,
    }));
  }

  async findDocumentSequenceById(businessId: string, sequenceId: string) {
    const [row] = await this.db
      .select()
      .from(documentNumberSequences)
      .where(
        and(
          eq(documentNumberSequences.id, sequenceId),
          eq(documentNumberSequences.businessId, businessId),
          eq(documentNumberSequences.isDeleted, false),
        ),
      )
      .limit(1);

    if (!row) {
      return null;
    }

    return {
      id: row.id,
      document_series: row.documentSeries,
      prefix: row.prefix,
      next_number: row.nextNumber,
      fiscal_year: row.fiscalYear,
    };
  }

  async updateDocumentSequence(
    businessId: string,
    sequenceId: string,
    values: { prefix?: string | null; nextNumber?: number },
  ) {
    const [row] = await this.db
      .update(documentNumberSequences)
      .set({
        ...(values.prefix !== undefined ? { prefix: values.prefix } : {}),
        ...(values.nextNumber !== undefined
          ? { nextNumber: values.nextNumber }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${documentNumberSequences.syncVersion} + 1`,
      })
      .where(
        and(
          eq(documentNumberSequences.id, sequenceId),
          eq(documentNumberSequences.businessId, businessId),
          eq(documentNumberSequences.isDeleted, false),
        ),
      )
      .returning();

    if (!row) {
      return null;
    }

    return {
      id: row.id,
      document_series: row.documentSeries,
      prefix: row.prefix,
      next_number: row.nextNumber,
      fiscal_year: row.fiscalYear,
    };
  }

  async swapLineItemBrands(
    businessId: string,
    documentId: string,
    brandId: string,
    updatedBy?: string | null,
  ): Promise<number> {
    const lines = await this.listLines(businessId, documentId);
    let updatedCount = 0;

    for (const line of lines) {
      const [replacement] = await this.db
        .select({ id: items.id })
        .from(items)
        .where(
          and(
            eq(items.businessId, businessId),
            eq(items.brandId, brandId),
            eq(items.isDeleted, false),
            sql`lower(${items.name}) = (SELECT lower(name) FROM items WHERE id = ${line.itemId})`,
          ),
        )
        .limit(1);

      if (replacement && replacement.id !== line.itemId) {
        await this.updateLine(businessId, line.id, {
          itemId: replacement.id,
          updatedBy: updatedBy ?? null,
        });
        updatedCount += 1;
      }
    }

    return updatedCount;
  }

  async listPosSessions(
    businessId: string,
    page: number,
    limit: number,
    sort: 'started_at' | 'created_at',
    order: 'asc' | 'desc',
  ): Promise<{ rows: PosSessionRecord[]; total: number }> {
    const whereClause = and(
      eq(posSessions.businessId, businessId),
      eq(posSessions.isDeleted, false),
    );

    const countResult = await this.db
      .select({ total: count() })
      .from(posSessions)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);
    const sortColumn =
      sort === 'created_at' ? posSessions.createdAt : posSessions.startedAt;
    const orderBy = order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (page - 1) * limit;

    const rows = await this.db
      .select()
      .from(posSessions)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(limit)
      .offset(offset);

    return {
      rows: rows.map((row) => ({
        id: row.id,
        user_id: row.userId,
        started_at: row.startedAt.toISOString(),
        ended_at: row.endedAt?.toISOString() ?? null,
        opening_cash: row.openingCash,
        closing_cash: row.closingCash,
        created_at: row.createdAt.toISOString(),
        updated_at: row.updatedAt.toISOString(),
      })),
      total,
    };
  }

  async createPosSession(
    businessId: string,
    userId: string,
    openingCash?: string | null,
  ): Promise<PosSessionRecord> {
    const [row] = await this.db
      .insert(posSessions)
      .values({
        businessId,
        userId,
        openingCash: openingCash ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create POS session');
    }

    return {
      id: row.id,
      user_id: row.userId,
      started_at: row.startedAt.toISOString(),
      ended_at: row.endedAt?.toISOString() ?? null,
      opening_cash: row.openingCash,
      closing_cash: row.closingCash,
      created_at: row.createdAt.toISOString(),
      updated_at: row.updatedAt.toISOString(),
    };
  }

  async findPosSession(
    businessId: string,
    sessionId: string,
  ): Promise<PosSessionRecord | null> {
    const [row] = await this.db
      .select()
      .from(posSessions)
      .where(
        and(
          eq(posSessions.id, sessionId),
          eq(posSessions.businessId, businessId),
          eq(posSessions.isDeleted, false),
        ),
      )
      .limit(1);

    if (!row) {
      return null;
    }

    return {
      id: row.id,
      user_id: row.userId,
      started_at: row.startedAt.toISOString(),
      ended_at: row.endedAt?.toISOString() ?? null,
      opening_cash: row.openingCash,
      closing_cash: row.closingCash,
      created_at: row.createdAt.toISOString(),
      updated_at: row.updatedAt.toISOString(),
    };
  }

  async closePosSession(
    businessId: string,
    sessionId: string,
    endedAt: Date,
    closingCash?: string | null,
  ): Promise<PosSessionRecord | null> {
    const [row] = await this.db
      .update(posSessions)
      .set({
        endedAt,
        closingCash: closingCash ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${posSessions.syncVersion} + 1`,
      })
      .where(
        and(
          eq(posSessions.id, sessionId),
          eq(posSessions.businessId, businessId),
          eq(posSessions.isDeleted, false),
        ),
      )
      .returning();

    if (!row) {
      return null;
    }

    return {
      id: row.id,
      user_id: row.userId,
      started_at: row.startedAt.toISOString(),
      ended_at: row.endedAt?.toISOString() ?? null,
      opening_cash: row.openingCash,
      closing_cash: row.closingCash,
      created_at: row.createdAt.toISOString(),
      updated_at: row.updatedAt.toISOString(),
    };
  }
}
