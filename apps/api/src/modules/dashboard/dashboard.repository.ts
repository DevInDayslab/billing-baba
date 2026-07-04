import { and, desc, eq, gte, inArray, lt, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  ledgerEntries,
  paymentAllocations,
  payments,
} from '../../db/schema/accounting/tables';
import { parties } from '../../db/schema/crm/tables';
import {
  expenses,
  purchaseDocuments,
} from '../../db/schema/purchases/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import {
  PURCHASE_BILL_TYPE,
  REVENUE_SALES_TYPES,
} from '../../shared/reporting/constants';
import {
  countLowAndNegativeStock,
  getTotalStockValue,
  listStockItemAggregates,
} from '../../shared/reporting/inventory-summary';
import { OutstandingRepository } from '../accounting/outstanding.repository';
import type { ResolvedDashboardPeriod } from './dashboard-period';
import type {
  DashboardCharts,
  DashboardFinanceSummary,
  DashboardInventorySummary,
  DashboardOverview,
  DashboardPurchaseSummary,
  DashboardRecentTransaction,
  DashboardSalesSummary,
} from './dashboard.types';

export class DashboardRepository {
  private readonly outstandingRepository: OutstandingRepository;

  constructor(private readonly db: Database) {
    this.outstandingRepository = new OutstandingRepository(db);
  }

  async getOverview(businessId: string): Promise<DashboardOverview> {
    return this.outstandingRepository.getOutstandingSummary(businessId);
  }

  async getSalesSummary(
    businessId: string,
    range: ResolvedDashboardPeriod,
  ): Promise<DashboardSalesSummary> {
    const salesFilters = and(
      eq(salesDocuments.businessId, businessId),
      eq(salesDocuments.isDeleted, false),
      eq(salesDocuments.status, 'finalized'),
      inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
      gte(salesDocuments.documentDate, range.from),
      lt(salesDocuments.documentDate, range.to),
    );

    const [totals] = await this.db
      .select({
        totalAmount: sql<string>`COALESCE(SUM(${salesDocuments.totalAmount}::numeric), 0)`,
        invoiceCount: sql<number>`COUNT(*)::int`,
      })
      .from(salesDocuments)
      .where(salesFilters);

    const [received] = await this.db
      .select({
        amount: sql<string>`COALESCE(SUM(${paymentAllocations.allocatedAmount}::numeric), 0)`,
      })
      .from(paymentAllocations)
      .innerJoin(
        salesDocuments,
        eq(paymentAllocations.salesDocumentId, salesDocuments.id),
      )
      .where(
        and(
          eq(paymentAllocations.businessId, businessId),
          eq(paymentAllocations.isDeleted, false),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      );

    const totalAmount = totals?.totalAmount ?? '0';
    const receivedAmount = received?.amount ?? '0';
    const balanceAmount = String(
      Math.max(
        0,
        Number(totalAmount) - Number(receivedAmount),
      ),
    );

    return {
      total_amount: totalAmount,
      invoice_count: Number(totals?.invoiceCount ?? 0),
      received_amount: receivedAmount,
      balance_amount: balanceAmount,
    };
  }

  async getPurchaseSummary(
    businessId: string,
    range: ResolvedDashboardPeriod,
  ): Promise<DashboardPurchaseSummary> {
    const [row] = await this.db
      .select({
        totalAmount: sql<string>`COALESCE(SUM(${purchaseDocuments.totalAmount}::numeric), 0)`,
        billCount: sql<number>`COUNT(*)::int`,
      })
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
          eq(purchaseDocuments.status, 'finalized'),
          eq(purchaseDocuments.documentType, PURCHASE_BILL_TYPE),
          gte(purchaseDocuments.documentDate, range.from),
          lt(purchaseDocuments.documentDate, range.to),
        ),
      );

    return {
      total_amount: row?.totalAmount ?? '0',
      bill_count: Number(row?.billCount ?? 0),
    };
  }

  async getFinanceSummary(
    businessId: string,
    range: ResolvedDashboardPeriod,
  ): Promise<DashboardFinanceSummary> {
    const [cashIn] = await this.db
      .select({
        amount: sql<string>`COALESCE(SUM(${payments.amount}::numeric), 0)`,
      })
      .from(payments)
      .where(
        and(
          eq(payments.businessId, businessId),
          eq(payments.isDeleted, false),
          eq(payments.direction, 'received'),
          gte(payments.paymentDate, range.from),
          lt(payments.paymentDate, range.to),
        ),
      );

    const [cashOut] = await this.db
      .select({
        amount: sql<string>`COALESCE(SUM(${payments.amount}::numeric), 0)`,
      })
      .from(payments)
      .where(
        and(
          eq(payments.businessId, businessId),
          eq(payments.isDeleted, false),
          eq(payments.direction, 'paid'),
          gte(payments.paymentDate, range.from),
          lt(payments.paymentDate, range.to),
        ),
      );

    const [expenseTotal] = await this.db
      .select({
        amount: sql<string>`COALESCE(SUM(${expenses.amount}::numeric), 0)`,
      })
      .from(expenses)
      .where(
        and(
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, false),
          gte(expenses.expenseDate, range.from.toISOString().slice(0, 10)),
          lt(expenses.expenseDate, range.to.toISOString().slice(0, 10)),
        ),
      );

    return {
      cash_in: cashIn?.amount ?? '0',
      cash_out: cashOut?.amount ?? '0',
      expenses: expenseTotal?.amount ?? '0',
    };
  }

  async getInventorySummary(
    businessId: string,
  ): Promise<DashboardInventorySummary> {
    const [totalStockValue, counts, lowStockResult] = await Promise.all([
      getTotalStockValue(this.db, businessId),
      countLowAndNegativeStock(this.db, businessId),
      listStockItemAggregates(this.db, businessId, {
        lowStockOnly: true,
        page: 1,
        limit: 5,
      }),
    ]);

    return {
      total_stock_value: totalStockValue,
      low_stock_count: counts.lowStockCount,
      negative_stock_count: counts.negativeStockCount,
      low_stock_items: lowStockResult.rows.map((row) => ({
        item_id: row.itemId,
        item_name: row.itemName,
        quantity: row.totalQty,
        reorder_level: row.reorderLevel ?? '0',
      })),
    };
  }

  async getSalesTrend(
    businessId: string,
    range: ResolvedDashboardPeriod,
  ): Promise<DashboardCharts['sales_trend']> {
    const rows = await this.db
      .select({
        bucket: sql<string>`date_trunc('day', ${salesDocuments.documentDate})::date`,
        amount: sql<string>`COALESCE(SUM(${salesDocuments.totalAmount}::numeric), 0)`,
      })
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      )
      .groupBy(sql`date_trunc('day', ${salesDocuments.documentDate})`)
      .orderBy(sql`date_trunc('day', ${salesDocuments.documentDate})`);

    return {
      granularity: 'day',
      points: rows.map((row) => ({
        date: String(row.bucket),
        amount: row.amount ?? '0',
      })),
    };
  }

  async getPurchasesTrend(
    businessId: string,
    range: ResolvedDashboardPeriod,
  ): Promise<DashboardCharts['purchases_trend']> {
    const rows = await this.db
      .select({
        bucket: sql<string>`date_trunc('day', ${purchaseDocuments.documentDate})::date`,
        amount: sql<string>`COALESCE(SUM(${purchaseDocuments.totalAmount}::numeric), 0)`,
      })
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
          eq(purchaseDocuments.status, 'finalized'),
          eq(purchaseDocuments.documentType, PURCHASE_BILL_TYPE),
          gte(purchaseDocuments.documentDate, range.from),
          lt(purchaseDocuments.documentDate, range.to),
        ),
      )
      .groupBy(sql`date_trunc('day', ${purchaseDocuments.documentDate})`)
      .orderBy(sql`date_trunc('day', ${purchaseDocuments.documentDate})`);

    return {
      granularity: 'day',
      points: rows.map((row) => ({
        date: String(row.bucket),
        amount: row.amount ?? '0',
      })),
    };
  }

  async getRecentTransactions(
    businessId: string,
    limit = 10,
  ): Promise<DashboardRecentTransaction[]> {
    const salesRows = await this.db
      .select({
        id: salesDocuments.id,
        type: sql<'sale'>`'sale'`,
        referenceNumber: salesDocuments.documentNumber,
        partyName: parties.name,
        amount: salesDocuments.totalAmount,
        date: salesDocuments.documentDate,
      })
      .from(salesDocuments)
      .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
        ),
      )
      .orderBy(desc(salesDocuments.documentDate))
      .limit(limit);

    const purchaseRows = await this.db
      .select({
        id: purchaseDocuments.id,
        type: sql<'purchase'>`'purchase'`,
        referenceNumber: purchaseDocuments.documentNumber,
        partyName: parties.name,
        amount: purchaseDocuments.totalAmount,
        date: purchaseDocuments.documentDate,
      })
      .from(purchaseDocuments)
      .innerJoin(parties, eq(purchaseDocuments.partyId, parties.id))
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
          eq(purchaseDocuments.status, 'finalized'),
          eq(purchaseDocuments.documentType, PURCHASE_BILL_TYPE),
        ),
      )
      .orderBy(desc(purchaseDocuments.documentDate))
      .limit(limit);

    const paymentRows = await this.db
      .select({
        id: payments.id,
        type: sql<'payment'>`'payment'`,
        referenceNumber: payments.referenceNumber,
        partyName: parties.name,
        amount: payments.amount,
        date: payments.paymentDate,
      })
      .from(payments)
      .innerJoin(parties, eq(payments.partyId, parties.id))
      .where(
        and(eq(payments.businessId, businessId), eq(payments.isDeleted, false)),
      )
      .orderBy(desc(payments.paymentDate))
      .limit(limit);

    const expenseRows = await this.db
      .select({
        id: expenses.id,
        type: sql<'expense'>`'expense'`,
        referenceNumber: expenses.description,
        partyName: parties.name,
        amount: expenses.amount,
        date: expenses.expenseDate,
      })
      .from(expenses)
      .leftJoin(parties, eq(expenses.partyId, parties.id))
      .where(
        and(eq(expenses.businessId, businessId), eq(expenses.isDeleted, false)),
      )
      .orderBy(desc(expenses.expenseDate))
      .limit(limit);

    const merged: DashboardRecentTransaction[] = [
      ...salesRows.map((row) => ({
        id: row.id,
        type: row.type,
        reference_number: row.referenceNumber,
        party_name: row.partyName,
        amount: row.amount,
        date: row.date.toISOString(),
      })),
      ...purchaseRows.map((row) => ({
        id: row.id,
        type: row.type,
        reference_number: row.referenceNumber,
        party_name: row.partyName,
        amount: row.amount,
        date: row.date.toISOString(),
      })),
      ...paymentRows.map((row) => ({
        id: row.id,
        type: row.type,
        reference_number: row.referenceNumber,
        party_name: row.partyName,
        amount: row.amount,
        date: row.date.toISOString(),
      })),
      ...expenseRows.map((row) => ({
        id: row.id,
        type: row.type,
        reference_number: row.referenceNumber,
        party_name: row.partyName,
        amount: row.amount,
        date: new Date(row.date).toISOString(),
      })),
    ];

    merged.sort(
      (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime(),
    );

    return merged.slice(0, limit);
  }
}
