import { and, desc, eq, gt, isNull, or, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  businesses,
  invoiceShareTokens,
  items,
  parties,
  paymentAllocations,
  salesDocumentLines,
  salesDocuments,
} from '../../db/schema';

export class InvoiceShareRepository {
  constructor(private readonly db: Database) {}

  async createToken(values: {
    token: string;
    invoiceId: string;
    businessId: string;
    expiresAt: Date | null;
    createdBy: string | null;
  }) {
    const [row] = await this.db
      .insert(invoiceShareTokens)
      .values({
        token: values.token,
        invoiceId: values.invoiceId,
        businessId: values.businessId,
        expiresAt: values.expiresAt,
        createdBy: values.createdBy,
      })
      .returning();

    return row;
  }

  async findActiveTokenForInvoice(invoiceId: string, businessId: string) {
    const now = new Date();
    const [row] = await this.db
      .select()
      .from(invoiceShareTokens)
      .where(
        and(
          eq(invoiceShareTokens.invoiceId, invoiceId),
          eq(invoiceShareTokens.businessId, businessId),
          or(
            isNull(invoiceShareTokens.expiresAt),
            gt(invoiceShareTokens.expiresAt, now),
          ),
        ),
      )
      .orderBy(desc(invoiceShareTokens.createdAt))
      .limit(1);

    return row ?? null;
  }

  async findTokenByValue(token: string) {
    const [row] = await this.db
      .select()
      .from(invoiceShareTokens)
      .where(eq(invoiceShareTokens.token, token))
      .limit(1);

    return row ?? null;
  }

  async findSalesDocument(businessId: string, invoiceId: string) {
    const [row] = await this.db
      .select()
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.id, invoiceId),
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async findBusiness(businessId: string) {
    const [row] = await this.db
      .select({
        id: businesses.id,
        name: businesses.name,
        gstin: businesses.gstin,
        address: businesses.address,
        phone: businesses.phone,
        email: businesses.email,
        stateCode: businesses.stateCode,
      })
      .from(businesses)
      .where(
        and(eq(businesses.id, businessId), eq(businesses.isDeleted, false)),
      )
      .limit(1);

    return row ?? null;
  }

  async findParty(businessId: string, partyId: string) {
    const [row] = await this.db
      .select({
        id: parties.id,
        name: parties.name,
        mobile: parties.mobile,
        email: parties.email,
        gstin: parties.gstin,
        stateCode: parties.stateCode,
        unrecoveredAmount: parties.unrecoveredAmount,
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

  async listLinesWithItems(businessId: string, invoiceId: string) {
    return this.db
      .select({
        id: salesDocumentLines.id,
        itemId: salesDocumentLines.itemId,
        itemName: items.name,
        quantity: salesDocumentLines.quantity,
        unit: salesDocumentLines.unit,
        unitPrice: salesDocumentLines.unitPrice,
        discountAmount: salesDocumentLines.discountAmount,
        taxType: salesDocumentLines.taxType,
        taxRate: salesDocumentLines.taxRate,
        cgstAmount: salesDocumentLines.cgstAmount,
        sgstAmount: salesDocumentLines.sgstAmount,
        igstAmount: salesDocumentLines.igstAmount,
        lineTotal: salesDocumentLines.lineTotal,
        sortOrder: salesDocumentLines.sortOrder,
      })
      .from(salesDocumentLines)
      .innerJoin(items, eq(items.id, salesDocumentLines.itemId))
      .where(
        and(
          eq(salesDocumentLines.salesDocumentId, invoiceId),
          eq(salesDocumentLines.businessId, businessId),
          eq(salesDocumentLines.isDeleted, false),
        ),
      )
      .orderBy(salesDocumentLines.sortOrder);
  }

  async getPaidAmount(businessId: string, invoiceId: string): Promise<string> {
    const [row] = await this.db
      .select({
        total: sql<string>`coalesce(sum(${paymentAllocations.allocatedAmount}::numeric), 0)`,
      })
      .from(paymentAllocations)
      .where(
        and(
          eq(paymentAllocations.businessId, businessId),
          eq(paymentAllocations.salesDocumentId, invoiceId),
          eq(paymentAllocations.isDeleted, false),
        ),
      );

    return row?.total ?? '0';
  }
}
