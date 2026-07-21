import { and, desc, eq, gt, isNull, or, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  businesses,
  invoiceShareTokens,
  items,
  loyaltyTransactions,
  parties,
  partyLoyaltyBalances,
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
          isNull(invoiceShareTokens.revokedAt),
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

  async revokeToken(tokenId: string): Promise<void> {
    await this.db
      .update(invoiceShareTokens)
      .set({ revokedAt: new Date() })
      .where(
        and(
          eq(invoiceShareTokens.id, tokenId),
          isNull(invoiceShareTokens.revokedAt),
        ),
      );
  }

  async revokeActiveTokensForInvoice(
    invoiceId: string,
    businessId: string,
  ): Promise<void> {
    await this.db
      .update(invoiceShareTokens)
      .set({ revokedAt: new Date() })
      .where(
        and(
          eq(invoiceShareTokens.invoiceId, invoiceId),
          eq(invoiceShareTokens.businessId, businessId),
          isNull(invoiceShareTokens.revokedAt),
        ),
      );
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
        upiId: businesses.upiId,
        logoMediaAssetId: businesses.logoMediaAssetId,
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

  async getLoyaltyForSale(
    businessId: string,
    invoiceId: string,
    partyId: string | null,
  ): Promise<{
    earned_points: string;
    redeemed_points: string;
    points_available: string | null;
  } | null> {
    const rows = await this.db
      .select({
        transactionType: loyaltyTransactions.transactionType,
        points: loyaltyTransactions.points,
      })
      .from(loyaltyTransactions)
      .where(
        and(
          eq(loyaltyTransactions.businessId, businessId),
          eq(loyaltyTransactions.referenceId, invoiceId),
          eq(loyaltyTransactions.referenceType, 'sales_documents'),
        ),
      );

    if (rows.length === 0) {
      return null;
    }

    let earned = 0;
    let redeemed = 0;
    for (const row of rows) {
      const pts = Number.parseFloat(row.points);
      if (row.transactionType === 'earn') earned += pts;
      if (row.transactionType === 'redeem') redeemed += pts;
    }

    let pointsAvailable: string | null = null;
    if (partyId) {
      const [balance] = await this.db
        .select({
          pointsAvailable: partyLoyaltyBalances.pointsAvailable,
        })
        .from(partyLoyaltyBalances)
        .where(
          and(
            eq(partyLoyaltyBalances.businessId, businessId),
            eq(partyLoyaltyBalances.partyId, partyId),
            eq(partyLoyaltyBalances.isDeleted, false),
          ),
        )
        .limit(1);
      pointsAvailable = balance?.pointsAvailable ?? null;
    }

    return {
      earned_points: earned.toFixed(4),
      redeemed_points: redeemed.toFixed(4),
      points_available: pointsAvailable,
    };
  }
}
