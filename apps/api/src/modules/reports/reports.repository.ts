import {
  and,
  asc,
  count,
  desc,
  eq,
  gte,
  ilike,
  inArray,
  lt,
  lte,
  or,
  sql,
} from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  ledgerEntries,
  paymentAllocations,
  payments,
} from '../../db/schema/accounting/tables';
import { parties } from '../../db/schema/crm/tables';
import { items } from '../../db/schema/inventory/tables';
import {
  expenses,
  purchaseDocumentLines,
  purchaseDocuments,
} from '../../db/schema/purchases/tables';
import {
  salesDocumentLines,
  salesDocuments,
} from '../../db/schema/sales/tables';
import { OutstandingRepository } from '../accounting/outstanding.repository';
import { DashboardRepository } from '../dashboard/dashboard.repository';
import {
  PURCHASE_BILL_TYPE,
  PURCHASE_RETURN_TYPE,
  REVENUE_SALES_TYPES,
  SALES_RETURN_TYPE,
} from '../../shared/reporting/constants';
import {
  listStockItemAggregates,
  getTotalStockValue,
} from '../../shared/reporting/inventory-summary';
import {
  resolveReportPeriod,
  type ResolvedReportPeriod,
} from '../../shared/reporting/report-period';
import type {
  AllTransactionsPayload,
  DayBookPayload,
  Gstr3bPayload,
  GstrReportPayload,
  LowStockPayload,
  PartyOutstandingPayload,
  PartyStatementPayload,
  ProfitLossPayload,
  PurchaseReportPayload,
  ReportPeriodMeta,
  SaleReportPayload,
  StockSummaryPayload,
} from './reports.types';
import type {
  PartyStatementQuery,
  ReportBaseQuery,
  ReportDateQuery,
} from './reports.schema';

function toPeriodMeta(range: ResolvedReportPeriod): ReportPeriodMeta {
  return {
    period: range.key,
    from: range.from.toISOString(),
    to: range.to.toISOString(),
  };
}

function resolveRange(query: ReportBaseQuery): ResolvedReportPeriod {
  return resolveReportPeriod({
    period: query.period,
    from: query.from,
    to: query.to,
  });
}

function resolveSingleDate(query: ReportDateQuery): Date {
  if (query.date) {
    return new Date(query.date);
  }
  const range = resolveRange(query);
  return range.from;
}

export class ReportsRepository {
  private readonly dashboardRepository: DashboardRepository;
  private readonly outstandingRepository: OutstandingRepository;

  constructor(private readonly db: Database) {
    this.dashboardRepository = new DashboardRepository(db);
    this.outstandingRepository = new OutstandingRepository(db);
  }

  async getSaleReport(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<{ payload: SaleReportPayload; total: number }> {
    const range = resolveRange(query);
    const summary = await this.dashboardRepository.getSalesSummary(
      businessId,
      range,
    );

    const filters = [
      eq(salesDocuments.businessId, businessId),
      eq(salesDocuments.isDeleted, false),
      eq(salesDocuments.status, 'finalized'),
      inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
      gte(salesDocuments.documentDate, range.from),
      lt(salesDocuments.documentDate, range.to),
    ];

    if (query.party_id) {
      filters.push(eq(salesDocuments.partyId, query.party_id));
    }
    if (query.q) {
      filters.push(ilike(salesDocuments.documentNumber, `%${query.q}%`));
    }

    const whereClause = and(...filters);
    const [countRow] = await this.db
      .select({ total: count() })
      .from(salesDocuments)
      .where(whereClause);
    const total = Number(countRow?.total ?? 0);
    const offset = (query.page - 1) * query.limit;

    const allocatedSubquery = this.db
      .select({
        salesDocumentId: paymentAllocations.salesDocumentId,
        allocated: sql<string>`COALESCE(SUM(${paymentAllocations.allocatedAmount}::numeric), 0)`.as(
          'allocated',
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
      .as('alloc');

    const rows = await this.db
      .select({
        id: salesDocuments.id,
        documentNumber: salesDocuments.documentNumber,
        documentDate: salesDocuments.documentDate,
        partyId: salesDocuments.partyId,
        partyName: parties.name,
        documentType: salesDocuments.documentType,
        status: salesDocuments.status,
        totalAmount: salesDocuments.totalAmount,
        allocated: sql<string>`COALESCE(${allocatedSubquery.allocated}, 0)`,
      })
      .from(salesDocuments)
      .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
      .leftJoin(
        allocatedSubquery,
        eq(allocatedSubquery.salesDocumentId, salesDocuments.id),
      )
      .where(whereClause)
      .orderBy(desc(salesDocuments.documentDate))
      .limit(query.limit)
      .offset(offset);

    return {
      total,
      payload: {
        period: toPeriodMeta(range),
        summary: {
          total_amount: summary.total_amount,
          received_amount: summary.received_amount,
          balance_amount: summary.balance_amount,
          count: summary.invoice_count,
        },
        rows: rows.map((row) => {
          const totalAmount = Number(row.totalAmount ?? 0);
          const allocated = Number(row.allocated ?? 0);
          const balance = Math.max(0, totalAmount - allocated);
          return {
            id: row.id,
            document_number: row.documentNumber ?? '',
            document_date: row.documentDate.toISOString(),
            party_id: row.partyId,
            party_name: row.partyName,
            document_type: row.documentType,
            payment_mode: null,
            status: balance <= 0 ? 'paid' : allocated > 0 ? 'partial' : 'unpaid',
            total_amount: row.totalAmount ?? '0',
            balance_amount: String(balance),
          };
        }),
      },
    };
  }

  async getPurchaseReport(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<{ payload: PurchaseReportPayload; total: number }> {
    const range = resolveRange(query);
    const summary = await this.dashboardRepository.getPurchaseSummary(
      businessId,
      range,
    );

    const filters = [
      eq(purchaseDocuments.businessId, businessId),
      eq(purchaseDocuments.isDeleted, false),
      eq(purchaseDocuments.status, 'finalized'),
      eq(purchaseDocuments.documentType, PURCHASE_BILL_TYPE),
      gte(purchaseDocuments.documentDate, range.from),
      lt(purchaseDocuments.documentDate, range.to),
    ];

    if (query.party_id) {
      filters.push(eq(purchaseDocuments.partyId, query.party_id));
    }
    if (query.q) {
      filters.push(ilike(purchaseDocuments.documentNumber, `%${query.q}%`));
    }

    const whereClause = and(...filters);
    const [countRow] = await this.db
      .select({ total: count() })
      .from(purchaseDocuments)
      .where(whereClause);
    const total = Number(countRow?.total ?? 0);
    const offset = (query.page - 1) * query.limit;

    const allocatedSubquery = this.db
      .select({
        purchaseDocumentId: paymentAllocations.purchaseDocumentId,
        allocated: sql<string>`COALESCE(SUM(${paymentAllocations.allocatedAmount}::numeric), 0)`.as(
          'allocated',
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
      .as('alloc');

    const rows = await this.db
      .select({
        id: purchaseDocuments.id,
        documentNumber: purchaseDocuments.documentNumber,
        documentDate: purchaseDocuments.documentDate,
        partyId: purchaseDocuments.partyId,
        partyName: parties.name,
        status: purchaseDocuments.status,
        totalAmount: purchaseDocuments.totalAmount,
        allocated: sql<string>`COALESCE(${allocatedSubquery.allocated}, 0)`,
      })
      .from(purchaseDocuments)
      .innerJoin(parties, eq(purchaseDocuments.partyId, parties.id))
      .leftJoin(
        allocatedSubquery,
        eq(allocatedSubquery.purchaseDocumentId, purchaseDocuments.id),
      )
      .where(whereClause)
      .orderBy(desc(purchaseDocuments.documentDate))
      .limit(query.limit)
      .offset(offset);

    const paidTotal = rows.reduce(
      (sum, row) => sum + Number(row.allocated ?? 0),
      0,
    );
    const balanceTotal = rows.reduce((sum, row) => {
      const totalAmount = Number(row.totalAmount ?? 0);
      const allocated = Number(row.allocated ?? 0);
      return sum + Math.max(0, totalAmount - allocated);
    }, 0);

    return {
      total,
      payload: {
        period: toPeriodMeta(range),
        summary: {
          total_amount: summary.total_amount,
          paid_amount: String(paidTotal),
          balance_amount: String(balanceTotal),
          count: summary.bill_count,
        },
        rows: rows.map((row) => {
          const totalAmount = Number(row.totalAmount ?? 0);
          const allocated = Number(row.allocated ?? 0);
          const balance = Math.max(0, totalAmount - allocated);
          return {
            id: row.id,
            document_number: row.documentNumber ?? '',
            document_date: row.documentDate.toISOString(),
            party_id: row.partyId,
            party_name: row.partyName ?? '',
            payment_mode: null,
            status: balance <= 0 ? 'paid' : allocated > 0 ? 'partial' : 'unpaid',
            total_amount: row.totalAmount ?? '0',
            balance_amount: String(balance),
          };
        }),
      },
    };
  }

  async getStockSummary(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<{ payload: StockSummaryPayload; total: number }> {
    const [totalStockValue, result] = await Promise.all([
      getTotalStockValue(this.db, businessId, query.godown_id),
      listStockItemAggregates(this.db, businessId, {
        godownId: query.godown_id,
        itemId: query.item_id,
        q: query.q,
        inStockOnly: false,
        page: query.page,
        limit: query.limit,
      }),
    ]);

    const itemIds = result.rows.map((row) => row.itemId);
    const salePrices =
      itemIds.length === 0
        ? []
        : await this.db
            .select({
              itemId: items.id,
              salePrice: items.salePrice,
            })
            .from(items)
            .where(
              and(
                eq(items.businessId, businessId),
                inArray(items.id, itemIds),
              ),
            );

    const salePriceMap = new Map(
      salePrices.map((row) => [row.itemId, row.salePrice]),
    );

    return {
      total: result.total,
      payload: {
        total_stock_value: totalStockValue,
        rows: result.rows.map((row) => ({
          item_id: row.itemId,
          item_name: row.itemName,
          category_id: row.categoryId,
          stock_qty: row.totalQty,
          average_cost: row.averageCost,
          stock_value: row.stockValue,
          sale_price: salePriceMap.get(row.itemId) ?? null,
        })),
      },
    };
  }

  async getLowStock(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<{ payload: LowStockPayload; total: number }> {
    const result = await listStockItemAggregates(this.db, businessId, {
      godownId: query.godown_id,
      q: query.q,
      lowStockOnly: true,
      page: query.page,
      limit: query.limit,
    });

    return {
      total: result.total,
      payload: {
        low_stock_count: result.total,
        rows: result.rows.map((row) => {
          const current = Number(row.totalQty);
          const minStock = Number(row.reorderLevel ?? 0);
          return {
            item_id: row.itemId,
            item_name: row.itemName,
            current_stock: row.totalQty,
            min_stock: row.reorderLevel ?? '0',
            shortage: String(Math.max(0, minStock - current)),
          };
        }),
      },
    };
  }

  async getPartyOutstanding(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<{ payload: PartyOutstandingPayload; total: number }> {
    const summary =
      await this.outstandingRepository.getOutstandingSummary(businessId);
    const balances =
      await this.outstandingRepository.listPartyBalances(businessId);

    const partyRows = await this.db
      .select({
        id: parties.id,
        name: parties.name,
        phone: parties.mobile,
        email: parties.email,
      })
      .from(parties)
      .where(
        and(eq(parties.businessId, businessId), eq(parties.isDeleted, false)),
      );

    const balanceMap = new Map(
      balances.map((row) => [row.party_id, Number(row.balance)]),
    );

    let rows = partyRows
      .map((party) => {
        const balance = balanceMap.get(party.id) ?? 0;
        return {
          party_id: party.id,
          party_name: party.name,
          phone: party.phone,
          email: party.email,
          balance: String(Math.abs(balance)),
          balance_type:
            balance > 0
              ? ('receivable' as const)
              : balance < 0
                ? ('payable' as const)
                : ('settled' as const),
        };
      })
      .filter((row) => row.balance_type !== 'settled');

    if (query.q) {
      const needle = query.q.toLowerCase();
      rows = rows.filter(
        (row) =>
          row.party_name.toLowerCase().includes(needle) ||
          (row.phone?.toLowerCase().includes(needle) ?? false),
      );
    }

    const total = rows.length;
    const offset = (query.page - 1) * query.limit;
    rows = rows.slice(offset, offset + query.limit);

    return {
      total,
      payload: {
        summary: {
          total_receivable: summary.total_receivable,
          receivable_party_count: summary.receivable_party_count,
          total_payable: summary.total_payable,
          payable_party_count: summary.payable_party_count,
        },
        rows,
      },
    };
  }

  async getPartyStatement(
    businessId: string,
    query: PartyStatementQuery,
  ): Promise<PartyStatementPayload> {
    const range = resolveRange(query);

    const entries = await this.db
      .select({
        id: ledgerEntries.id,
        date: ledgerEntries.entryDate,
        type: ledgerEntries.entryType,
        description: ledgerEntries.description,
        debit: ledgerEntries.debit,
        credit: ledgerEntries.credit,
        balance: ledgerEntries.balanceAfter,
        referenceType: ledgerEntries.referenceType,
      })
      .from(ledgerEntries)
      .where(
        and(
          eq(ledgerEntries.businessId, businessId),
          eq(ledgerEntries.partyId, query.party_id),
          gte(ledgerEntries.entryDate, range.from.toISOString().slice(0, 10)),
          lte(ledgerEntries.entryDate, range.to.toISOString().slice(0, 10)),
        ),
      )
      .orderBy(asc(ledgerEntries.entryDate), asc(ledgerEntries.createdAt));

    let totalSale = 0;
    let totalPurchase = 0;
    let totalMoneyIn = 0;
    let totalMoneyOut = 0;

    const mapped = entries.map((entry) => {
      const debit = Number(entry.debit ?? 0);
      const credit = Number(entry.credit ?? 0);
      const type = entry.type;

      if (type === 'sale') {
        totalSale += debit;
      } else if (type === 'purchase') {
        totalPurchase += debit;
      } else if (type === 'payment') {
        if (credit > 0) {
          totalMoneyIn += credit;
        } else {
          totalMoneyOut += debit;
        }
      } else if (type === 'expense') {
        totalMoneyOut += debit;
      }

      return {
        id: entry.id,
        date: entry.date,
        type,
        ref_no: entry.referenceType ?? '-',
        description: entry.description,
        debit: entry.debit ?? '0',
        credit: entry.credit ?? '0',
        balance: entry.balance ?? '0',
      };
    });

    const balances = await this.outstandingRepository.listPartyBalances(
      businessId,
    );
    const partyBalance = Number(
      balances.find((row) => row.party_id === query.party_id)?.balance ?? 0,
    );

    return {
      period: toPeriodMeta(range),
      party_id: query.party_id,
      summary: {
        total_sale: String(totalSale),
        total_purchase: String(totalPurchase),
        total_money_in: String(totalMoneyIn),
        total_money_out: String(totalMoneyOut),
        total_receivable: String(Math.max(0, partyBalance)),
      },
      entries: mapped,
    };
  }

  async getDayBook(
    businessId: string,
    query: ReportDateQuery,
  ): Promise<DayBookPayload> {
    const date = resolveSingleDate(query);
    const dayStart = new Date(date);
    dayStart.setUTCHours(0, 0, 0, 0);
    const dayEnd = new Date(dayStart);
    dayEnd.setUTCDate(dayEnd.getUTCDate() + 1);
    const dateKey = dayStart.toISOString().slice(0, 10);

    const [ledgerRows, paymentRows, expenseRows] = await Promise.all([
      this.db
        .select({
          id: ledgerEntries.id,
          date: ledgerEntries.entryDate,
          type: ledgerEntries.entryType,
          description: ledgerEntries.description,
          debit: ledgerEntries.debit,
          credit: ledgerEntries.credit,
          partyName: parties.name,
        })
        .from(ledgerEntries)
        .leftJoin(parties, eq(ledgerEntries.partyId, parties.id))
        .where(
          and(
            eq(ledgerEntries.businessId, businessId),
            eq(ledgerEntries.entryDate, dateKey),
          ),
        ),
      this.db
        .select({
          id: payments.id,
          date: payments.paymentDate,
          direction: payments.direction,
          amount: payments.amount,
          referenceNumber: payments.referenceNumber,
          partyName: parties.name,
          paymentMode: payments.paymentMode,
        })
        .from(payments)
        .innerJoin(parties, eq(payments.partyId, parties.id))
        .where(
          and(
            eq(payments.businessId, businessId),
            eq(payments.isDeleted, false),
            gte(payments.paymentDate, dayStart),
            lt(payments.paymentDate, dayEnd),
          ),
        ),
      this.db
        .select({
          id: expenses.id,
          date: expenses.expenseDate,
          amount: expenses.amount,
          description: expenses.description,
          partyName: parties.name,
        })
        .from(expenses)
        .leftJoin(parties, eq(expenses.partyId, parties.id))
        .where(
          and(
            eq(expenses.businessId, businessId),
            eq(expenses.isDeleted, false),
            eq(expenses.expenseDate, dateKey),
          ),
        ),
    ]);

    const rows = [
      ...ledgerRows.map((row) => {
        const moneyIn = Number(row.credit ?? 0);
        const moneyOut = Number(row.debit ?? 0);
        return {
          id: row.id,
          date: new Date(row.date).toISOString(),
          ref_no: row.type,
          party_id: null,
          party_name: row.partyName,
          category: 'Ledger',
          type: row.type,
          total: String(moneyIn || moneyOut),
          received: String(moneyIn),
          balance: '0',
          money_in: String(moneyIn),
          money_out: String(moneyOut),
          status: 'finalized',
          payment_type: null,
        };
      }),
      ...paymentRows.map((row) => {
        const isIn = row.direction === 'received';
        const amount = Number(row.amount ?? 0);
        return {
          id: row.id,
          date: row.date.toISOString(),
          ref_no: row.referenceNumber ?? row.id,
          party_id: null,
          party_name: row.partyName,
          category: 'Payment',
          type: isIn ? 'Payment In' : 'Payment Out',
          total: row.amount ?? '0',
          received: isIn ? row.amount ?? '0' : '0',
          balance: '0',
          money_in: isIn ? row.amount ?? '0' : '0',
          money_out: isIn ? '0' : row.amount ?? '0',
          status: 'paid',
          payment_type: row.paymentMode,
        };
      }),
      ...expenseRows.map((row) => ({
        id: row.id,
        date: new Date(row.date).toISOString(),
        ref_no: row.description ?? row.id,
        party_id: null,
        party_name: row.partyName,
        category: 'Expense',
        type: 'Expense',
        total: row.amount ?? '0',
        received: '0',
        balance: '0',
        money_in: '0',
        money_out: row.amount ?? '0',
        status: 'paid',
        payment_type: null,
      })),
    ].sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    const totalMoneyIn = rows.reduce(
      (sum, row) => sum + Number(row.money_in),
      0,
    );
    const totalMoneyOut = rows.reduce(
      (sum, row) => sum + Number(row.money_out),
      0,
    );

    return {
      date: dayStart.toISOString(),
      total_money_in: String(totalMoneyIn),
      total_money_out: String(totalMoneyOut),
      net_total: String(totalMoneyIn - totalMoneyOut),
      rows,
    };
  }

  async getAllTransactions(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<{ payload: AllTransactionsPayload; total: number }> {
    const range = resolveRange(query);
    const dayBookStyle = await this.buildTransactionUnion(
      businessId,
      range.from,
      range.to,
      query.party_id,
      query.q,
    );

    const total = dayBookStyle.length;
    const offset = (query.page - 1) * query.limit;
    const rows = dayBookStyle.slice(offset, offset + query.limit);

    return {
      total,
      payload: {
        period: toPeriodMeta(range),
        rows,
      },
    };
  }

  private async buildTransactionUnion(
    businessId: string,
    from: Date,
    to: Date,
    partyId?: string,
    q?: string,
  ) {
    const salesFilters = [
      eq(salesDocuments.businessId, businessId),
      eq(salesDocuments.isDeleted, false),
      eq(salesDocuments.status, 'finalized'),
      gte(salesDocuments.documentDate, from),
      lt(salesDocuments.documentDate, to),
    ];
    if (partyId) {
      salesFilters.push(eq(salesDocuments.partyId, partyId));
    }
    if (q) {
      salesFilters.push(
        or(
          ilike(salesDocuments.documentNumber, `%${q}%`),
          ilike(parties.name, `%${q}%`),
        )!,
      );
    }

    const salesRows = await this.db
      .select({
        id: salesDocuments.id,
        date: salesDocuments.documentDate,
        refNo: salesDocuments.documentNumber,
        partyId: salesDocuments.partyId,
        partyName: parties.name,
        total: salesDocuments.totalAmount,
      })
      .from(salesDocuments)
      .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
      .where(and(...salesFilters));

    const purchaseFilters = [
      eq(purchaseDocuments.businessId, businessId),
      eq(purchaseDocuments.isDeleted, false),
      eq(purchaseDocuments.status, 'finalized'),
      gte(purchaseDocuments.documentDate, from),
      lt(purchaseDocuments.documentDate, to),
    ];
    if (partyId) {
      purchaseFilters.push(eq(purchaseDocuments.partyId, partyId));
    }

    const purchaseRows = await this.db
      .select({
        id: purchaseDocuments.id,
        date: purchaseDocuments.documentDate,
        refNo: purchaseDocuments.documentNumber,
        partyId: purchaseDocuments.partyId,
        partyName: parties.name,
        total: purchaseDocuments.totalAmount,
      })
      .from(purchaseDocuments)
      .innerJoin(parties, eq(purchaseDocuments.partyId, parties.id))
      .where(and(...purchaseFilters));

    const paymentFilters = [
      eq(payments.businessId, businessId),
      eq(payments.isDeleted, false),
      gte(payments.paymentDate, from),
      lt(payments.paymentDate, to),
    ];
    if (partyId) {
      paymentFilters.push(eq(payments.partyId, partyId));
    }

    const paymentRows = await this.db
      .select({
        id: payments.id,
        date: payments.paymentDate,
        refNo: payments.referenceNumber,
        partyId: payments.partyId,
        partyName: parties.name,
        total: payments.amount,
        direction: payments.direction,
        paymentMode: payments.paymentMode,
      })
      .from(payments)
      .innerJoin(parties, eq(payments.partyId, parties.id))
      .where(and(...paymentFilters));

    const rows = [
      ...salesRows.map((row) => ({
        id: row.id,
        date: row.date.toISOString(),
        ref_no: row.refNo ?? row.id,
        party_id: row.partyId,
        party_name: row.partyName,
        category: 'Sales',
        type: 'Sale',
        total: row.total ?? '0',
        received: '0',
        balance: row.total ?? '0',
        money_in: '0',
        money_out: '0',
        status: 'finalized',
        payment_type: null,
      })),
      ...purchaseRows.map((row) => ({
        id: row.id,
        date: row.date.toISOString(),
        ref_no: row.refNo ?? row.id,
        party_id: row.partyId,
        party_name: row.partyName,
        category: 'Purchase',
        type: 'Purchase',
        total: row.total ?? '0',
        received: '0',
        balance: row.total ?? '0',
        money_in: '0',
        money_out: row.total ?? '0',
        status: 'finalized',
        payment_type: null,
      })),
      ...paymentRows.map((row) => {
        const isIn = row.direction === 'received';
        return {
          id: row.id,
          date: row.date.toISOString(),
          ref_no: row.refNo ?? row.id,
          party_id: row.partyId,
          party_name: row.partyName,
          category: 'Payment',
          type: isIn ? 'Payment In' : 'Payment Out',
          total: row.total ?? '0',
          received: isIn ? row.total ?? '0' : '0',
          balance: '0',
          money_in: isIn ? row.total ?? '0' : '0',
          money_out: isIn ? '0' : row.total ?? '0',
          status: 'paid',
          payment_type: row.paymentMode,
        };
      }),
    ];

    return rows.sort(
      (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime(),
    );
  }

  async getProfitLoss(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<ProfitLossPayload> {
    const range = resolveRange(query);

    const [salesTotal, salesReturnTotal, purchaseTotal, purchaseReturnTotal, expenseTotal] =
      await Promise.all([
        this.sumSales(businessId, range, REVENUE_SALES_TYPES),
        this.sumSales(businessId, range, [SALES_RETURN_TYPE] as const),
        this.sumPurchases(businessId, range, PURCHASE_BILL_TYPE),
        this.sumPurchases(businessId, range, PURCHASE_RETURN_TYPE),
        this.sumExpenses(businessId, range),
      ]);

    const grossProfit =
      salesTotal - salesReturnTotal - (purchaseTotal - purchaseReturnTotal);
    const netProfit = grossProfit - expenseTotal;

    return {
      period: toPeriodMeta(range),
      net_profit: String(netProfit),
      items: [
        { particular: 'Sales', amount: '0', is_header: true, indent: 0 },
        { particular: 'Sale', amount: String(salesTotal), is_header: false, indent: 1 },
        {
          particular: 'Sale Return',
          amount: String(-salesReturnTotal),
          is_header: false,
          indent: 1,
        },
        { particular: 'Purchases', amount: '0', is_header: true, indent: 0 },
        {
          particular: 'Purchase',
          amount: String(-purchaseTotal),
          is_header: false,
          indent: 1,
        },
        {
          particular: 'Purchase Return',
          amount: String(purchaseReturnTotal),
          is_header: false,
          indent: 1,
        },
        {
          particular: 'Gross Profit',
          amount: String(grossProfit),
          is_header: true,
          indent: 0,
        },
        {
          particular: 'Indirect Expenses',
          amount: '0',
          is_header: true,
          indent: 0,
        },
        {
          particular: 'Expenses',
          amount: String(-expenseTotal),
          is_header: false,
          indent: 1,
        },
        {
          particular: 'Net Profit',
          amount: String(netProfit),
          is_header: true,
          indent: 0,
        },
      ],
    };
  }

  private async sumSales(
    businessId: string,
    range: ResolvedReportPeriod,
    documentTypes: typeof REVENUE_SALES_TYPES | readonly [typeof SALES_RETURN_TYPE],
  ): Promise<number> {
    const [row] = await this.db
      .select({
        total: sql<string>`COALESCE(SUM(${salesDocuments.totalAmount}::numeric), 0)`,
      })
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          inArray(salesDocuments.documentType, [...documentTypes]),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      );
    return Number(row?.total ?? 0);
  }

  private async sumPurchases(
    businessId: string,
    range: ResolvedReportPeriod,
    documentType: typeof PURCHASE_BILL_TYPE | typeof PURCHASE_RETURN_TYPE,
  ): Promise<number> {
    const [row] = await this.db
      .select({
        total: sql<string>`COALESCE(SUM(${purchaseDocuments.totalAmount}::numeric), 0)`,
      })
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
          eq(purchaseDocuments.status, 'finalized'),
          eq(purchaseDocuments.documentType, documentType),
          gte(purchaseDocuments.documentDate, range.from),
          lt(purchaseDocuments.documentDate, range.to),
        ),
      );
    return Number(row?.total ?? 0);
  }

  private async sumExpenses(
    businessId: string,
    range: ResolvedReportPeriod,
  ): Promise<number> {
    const [row] = await this.db
      .select({
        total: sql<string>`COALESCE(SUM(${expenses.amount}::numeric), 0)`,
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
    return Number(row?.total ?? 0);
  }

  async getGstr1(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<GstrReportPayload> {
    return this.getGstrReport(businessId, query, 'sale');
  }

  async getGstr2(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<GstrReportPayload> {
    return this.getGstrReport(businessId, query, 'purchase');
  }

  private async getGstrReport(
    businessId: string,
    query: ReportBaseQuery,
    mode: 'sale' | 'purchase',
  ): Promise<GstrReportPayload> {
    const range = resolveRange(query);

    if (mode === 'sale') {
      const rows = await this.db
        .select({
          gstin: parties.gstin,
          partyName: parties.name,
          invoiceNo: salesDocuments.documentNumber,
          date: salesDocuments.documentDate,
          totalAmount: salesDocuments.totalAmount,
          taxAmount: salesDocuments.taxAmount,
          subtotal: salesDocuments.subtotal,
          igst: sql<string>`COALESCE(SUM(${salesDocumentLines.igstAmount}::numeric), 0)`,
          cgst: sql<string>`COALESCE(SUM(${salesDocumentLines.cgstAmount}::numeric), 0)`,
          sgst: sql<string>`COALESCE(SUM(${salesDocumentLines.sgstAmount}::numeric), 0)`,
          taxRate: sql<string>`MAX(${salesDocumentLines.taxRate})`,
        })
        .from(salesDocuments)
        .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
        .leftJoin(
          salesDocumentLines,
          and(
            eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
            eq(salesDocumentLines.isDeleted, false),
          ),
        )
        .where(
          and(
            eq(salesDocuments.businessId, businessId),
            eq(salesDocuments.isDeleted, false),
            eq(salesDocuments.status, 'finalized'),
            inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
            eq(salesDocuments.isGstFormal, true),
            gte(salesDocuments.documentDate, range.from),
            lt(salesDocuments.documentDate, range.to),
          ),
        )
        .groupBy(
          parties.gstin,
          parties.name,
          salesDocuments.documentNumber,
          salesDocuments.documentDate,
          salesDocuments.totalAmount,
          salesDocuments.taxAmount,
          salesDocuments.subtotal,
        )
        .orderBy(desc(salesDocuments.documentDate));

      return {
        period: toPeriodMeta(range),
        rows: rows.map((row) => ({
          gstin: row.gstin,
          party_name: row.partyName,
          invoice_no: row.invoiceNo ?? '',
          date: row.date.toISOString(),
          value: row.totalAmount ?? '0',
          tax_rate: row.taxRate ?? '0',
          taxable_value: row.subtotal ?? '0',
          integrated_tax: row.igst ?? '0',
          central_tax: row.cgst ?? '0',
          state_tax: row.sgst ?? '0',
          cess: '0',
        })),
      };
    }

    const rows = await this.db
      .select({
        gstin: parties.gstin,
        partyName: parties.name,
        invoiceNo: purchaseDocuments.documentNumber,
        date: purchaseDocuments.documentDate,
        totalAmount: purchaseDocuments.totalAmount,
        subtotal: purchaseDocuments.subtotal,
        igst: sql<string>`COALESCE(SUM(${purchaseDocumentLines.igstAmount}::numeric), 0)`,
        cgst: sql<string>`COALESCE(SUM(${purchaseDocumentLines.cgstAmount}::numeric), 0)`,
        sgst: sql<string>`COALESCE(SUM(${purchaseDocumentLines.sgstAmount}::numeric), 0)`,
        taxRate: sql<string>`MAX(${purchaseDocumentLines.taxRate})`,
      })
      .from(purchaseDocuments)
      .innerJoin(parties, eq(purchaseDocuments.partyId, parties.id))
      .leftJoin(
        purchaseDocumentLines,
        and(
          eq(purchaseDocumentLines.purchaseDocumentId, purchaseDocuments.id),
          eq(purchaseDocumentLines.isDeleted, false),
        ),
      )
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
      .groupBy(
        parties.gstin,
        parties.name,
        purchaseDocuments.documentNumber,
        purchaseDocuments.documentDate,
        purchaseDocuments.totalAmount,
        purchaseDocuments.subtotal,
      )
      .orderBy(desc(purchaseDocuments.documentDate));

    return {
      period: toPeriodMeta(range),
      rows: rows.map((row) => ({
        gstin: row.gstin,
        party_name: row.partyName,
        invoice_no: row.invoiceNo ?? '',
        date: row.date.toISOString(),
        value: row.totalAmount ?? '0',
        tax_rate: row.taxRate ?? '0',
        taxable_value: row.subtotal ?? '0',
        integrated_tax: row.igst ?? '0',
        central_tax: row.cgst ?? '0',
        state_tax: row.sgst ?? '0',
        cess: '0',
      })),
    };
  }

  async getGstr3b(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<Gstr3bPayload> {
    const range = resolveRange(query);
    const [outward, inward] = await Promise.all([
      this.db
        .select({
          taxable: sql<string>`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric - ${salesDocumentLines.igstAmount}::numeric - ${salesDocumentLines.cgstAmount}::numeric - ${salesDocumentLines.sgstAmount}::numeric), 0)`,
          igst: sql<string>`COALESCE(SUM(${salesDocumentLines.igstAmount}::numeric), 0)`,
          cgst: sql<string>`COALESCE(SUM(${salesDocumentLines.cgstAmount}::numeric), 0)`,
          sgst: sql<string>`COALESCE(SUM(${salesDocumentLines.sgstAmount}::numeric), 0)`,
        })
        .from(salesDocumentLines)
        .innerJoin(
          salesDocuments,
          eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
        )
        .where(
          and(
            eq(salesDocuments.businessId, businessId),
            eq(salesDocuments.isDeleted, false),
            eq(salesDocuments.status, 'finalized'),
            inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
            gte(salesDocuments.documentDate, range.from),
            lt(salesDocuments.documentDate, range.to),
            eq(salesDocumentLines.isDeleted, false),
          ),
        ),
      this.db
        .select({
          taxable: sql<string>`COALESCE(SUM(${purchaseDocumentLines.lineTotal}::numeric - ${purchaseDocumentLines.igstAmount}::numeric - ${purchaseDocumentLines.cgstAmount}::numeric - ${purchaseDocumentLines.sgstAmount}::numeric), 0)`,
          igst: sql<string>`COALESCE(SUM(${purchaseDocumentLines.igstAmount}::numeric), 0)`,
          cgst: sql<string>`COALESCE(SUM(${purchaseDocumentLines.cgstAmount}::numeric), 0)`,
          sgst: sql<string>`COALESCE(SUM(${purchaseDocumentLines.sgstAmount}::numeric), 0)`,
        })
        .from(purchaseDocumentLines)
        .innerJoin(
          purchaseDocuments,
          eq(purchaseDocumentLines.purchaseDocumentId, purchaseDocuments.id),
        )
        .where(
          and(
            eq(purchaseDocuments.businessId, businessId),
            eq(purchaseDocuments.isDeleted, false),
            eq(purchaseDocuments.status, 'finalized'),
            eq(purchaseDocuments.documentType, PURCHASE_BILL_TYPE),
            gte(purchaseDocuments.documentDate, range.from),
            lt(purchaseDocuments.documentDate, range.to),
            eq(purchaseDocumentLines.isDeleted, false),
          ),
        ),
    ]);

    return {
      period: toPeriodMeta(range),
      rows: [
        {
          nature: '(a) Outward taxable supplies',
          taxable_value: outward[0]?.taxable ?? '0',
          integrated_tax: outward[0]?.igst ?? '0',
          central_tax: outward[0]?.cgst ?? '0',
          state_tax: outward[0]?.sgst ?? '0',
          cess: '0',
        },
        {
          nature: '(d) Inward supplies (liable to reverse charge)',
          taxable_value: inward[0]?.taxable ?? '0',
          integrated_tax: inward[0]?.igst ?? '0',
          central_tax: inward[0]?.cgst ?? '0',
          state_tax: inward[0]?.sgst ?? '0',
          cess: '0',
        },
      ],
    };
  }
}
