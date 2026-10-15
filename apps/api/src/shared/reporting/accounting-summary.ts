import { and, eq, gte, inArray, lt, lte, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { ledgerEntries, payments } from '../../db/schema/accounting/tables';
import { parties } from '../../db/schema/crm/tables';
import {
  incomeCategories,
  otherIncomes,
} from '../../db/schema/other-income/tables';
import { loanAccounts, loanTransactions } from '../../db/schema/loans/tables';
import { expenses, purchaseDocuments } from '../../db/schema/purchases/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import { OutstandingRepository } from '../../modules/accounting/outstanding.repository';
import {
  PURCHASE_BILL_TYPE,
  PURCHASE_RETURN_TYPE,
  REVENUE_SALES_TYPES,
  SALES_RETURN_TYPE,
} from './constants';
import { getTotalStockValue } from './inventory-summary';
import type { ResolvedReportPeriod } from './report-period';

function toDateKey(date: Date): string {
  return date.toISOString().slice(0, 10);
}

export type OutstandingAsOf = {
  receivable: number;
  payable: number;
};

export async function getOutstandingAsOf(
  db: Database,
  businessId: string,
  asOf: Date,
): Promise<OutstandingAsOf> {
  const asOfKey = toDateKey(asOf);

  const [row] = await db
    .select({
      receivable: sql<string>`COALESCE(SUM(
        CASE WHEN (
          ${parties.openingBalance}::numeric
          + COALESCE((
            SELECT SUM(${ledgerEntries.debit}::numeric)
            FROM ${ledgerEntries}
            WHERE ${ledgerEntries.businessId} = ${businessId}
              AND ${ledgerEntries.partyId} = ${parties.id}
              AND ${ledgerEntries.entryDate} <= ${asOfKey}
          ), 0)
          - COALESCE((
            SELECT SUM(${ledgerEntries.credit}::numeric)
            FROM ${ledgerEntries}
            WHERE ${ledgerEntries.businessId} = ${businessId}
              AND ${ledgerEntries.partyId} = ${parties.id}
              AND ${ledgerEntries.entryDate} <= ${asOfKey}
          ), 0)
        ) > 0 THEN (
          ${parties.openingBalance}::numeric
          + COALESCE((
            SELECT SUM(${ledgerEntries.debit}::numeric)
            FROM ${ledgerEntries}
            WHERE ${ledgerEntries.businessId} = ${businessId}
              AND ${ledgerEntries.partyId} = ${parties.id}
              AND ${ledgerEntries.entryDate} <= ${asOfKey}
          ), 0)
          - COALESCE((
            SELECT SUM(${ledgerEntries.credit}::numeric)
            FROM ${ledgerEntries}
            WHERE ${ledgerEntries.businessId} = ${businessId}
              AND ${ledgerEntries.partyId} = ${parties.id}
              AND ${ledgerEntries.entryDate} <= ${asOfKey}
          ), 0)
        ) ELSE 0 END
      ), 0)`,
      payable: sql<string>`COALESCE(SUM(
        CASE WHEN (
          ${parties.openingBalance}::numeric
          + COALESCE((
            SELECT SUM(${ledgerEntries.debit}::numeric)
            FROM ${ledgerEntries}
            WHERE ${ledgerEntries.businessId} = ${businessId}
              AND ${ledgerEntries.partyId} = ${parties.id}
              AND ${ledgerEntries.entryDate} <= ${asOfKey}
          ), 0)
          - COALESCE((
            SELECT SUM(${ledgerEntries.credit}::numeric)
            FROM ${ledgerEntries}
            WHERE ${ledgerEntries.businessId} = ${businessId}
              AND ${ledgerEntries.partyId} = ${parties.id}
              AND ${ledgerEntries.entryDate} <= ${asOfKey}
          ), 0)
        ) < 0 THEN ABS(
          ${parties.openingBalance}::numeric
          + COALESCE((
            SELECT SUM(${ledgerEntries.debit}::numeric)
            FROM ${ledgerEntries}
            WHERE ${ledgerEntries.businessId} = ${businessId}
              AND ${ledgerEntries.partyId} = ${parties.id}
              AND ${ledgerEntries.entryDate} <= ${asOfKey}
          ), 0)
          - COALESCE((
            SELECT SUM(${ledgerEntries.credit}::numeric)
            FROM ${ledgerEntries}
            WHERE ${ledgerEntries.businessId} = ${businessId}
              AND ${ledgerEntries.partyId} = ${parties.id}
              AND ${ledgerEntries.entryDate} <= ${asOfKey}
          ), 0)
        ) ELSE 0 END
      ), 0)`,
    })
    .from(parties)
    .where(
      and(eq(parties.businessId, businessId), eq(parties.isDeleted, false)),
    );

  return {
    receivable: Number(row?.receivable ?? 0),
    payable: Number(row?.payable ?? 0),
  };
}

export async function getCashBalanceAsOf(
  db: Database,
  businessId: string,
  asOf: Date,
): Promise<number> {
  const [received] = await db
    .select({
      amount: sql<string>`COALESCE(SUM(${payments.amount}::numeric), 0)`,
    })
    .from(payments)
    .where(
      and(
        eq(payments.businessId, businessId),
        eq(payments.isDeleted, false),
        eq(payments.direction, 'received'),
        lte(payments.paymentDate, asOf),
      ),
    );

  const [paid] = await db
    .select({
      amount: sql<string>`COALESCE(SUM(${payments.amount}::numeric), 0)`,
    })
    .from(payments)
    .where(
      and(
        eq(payments.businessId, businessId),
        eq(payments.isDeleted, false),
        eq(payments.direction, 'paid'),
        lte(payments.paymentDate, asOf),
      ),
    );

  return Number(received?.amount ?? 0) - Number(paid?.amount ?? 0);
}

export async function getCashMovement(
  db: Database,
  businessId: string,
  range: ResolvedReportPeriod,
): Promise<{ received: number; paid: number }> {
  const [received] = await db
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

  const [paid] = await db
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

  return {
    received: Number(received?.amount ?? 0),
    paid: Number(paid?.amount ?? 0),
  };
}

export async function sumPartyOpeningBalances(
  db: Database,
  businessId: string,
): Promise<number> {
  const [row] = await db
    .select({
      total: sql<string>`COALESCE(SUM(${parties.openingBalance}::numeric), 0)`,
    })
    .from(parties)
    .where(
      and(eq(parties.businessId, businessId), eq(parties.isDeleted, false)),
    );
  return Number(row?.total ?? 0);
}

export async function sumSalesAmount(
  db: Database,
  businessId: string,
  range: ResolvedReportPeriod,
  documentTypes:
    | typeof REVENUE_SALES_TYPES
    | readonly [typeof SALES_RETURN_TYPE] = REVENUE_SALES_TYPES,
): Promise<number> {
  const [row] = await db
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

export async function sumPurchasesAmount(
  db: Database,
  businessId: string,
  range: ResolvedReportPeriod,
  documentType: typeof PURCHASE_BILL_TYPE | typeof PURCHASE_RETURN_TYPE,
): Promise<number> {
  const [row] = await db
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

export async function sumOtherIncomeAmount(
  db: Database,
  businessId: string,
  range: ResolvedReportPeriod,
  categoryType?: 'direct' | 'indirect',
): Promise<number> {
  const filters = [
    eq(otherIncomes.businessId, businessId),
    eq(otherIncomes.isDeleted, false),
    gte(otherIncomes.incomeDate, toDateKey(range.from)),
    lt(otherIncomes.incomeDate, toDateKey(range.to)),
  ];
  const [row] = await db
    .select({
      total: sql<string>`COALESCE(SUM(${otherIncomes.amount}::numeric), 0)`,
    })
    .from(otherIncomes)
    .innerJoin(
      incomeCategories,
      eq(otherIncomes.categoryId, incomeCategories.id),
    )
    .where(
      and(
        ...filters,
        categoryType
          ? eq(incomeCategories.categoryType, categoryType)
          : undefined,
      ),
    );
  return Number(row?.total ?? 0);
}

export async function sumLoanFinancingExpense(
  db: Database,
  businessId: string,
  range: ResolvedReportPeriod,
): Promise<number> {
  const [row] = await db
    .select({
      total: sql<string>`COALESCE(SUM(
        (${loanTransactions.interestAmount}::numeric) +
        (${loanTransactions.chargesAmount}::numeric)
      ), 0)`,
    })
    .from(loanTransactions)
    .where(
      and(
        eq(loanTransactions.businessId, businessId),
        eq(loanTransactions.isDeleted, false),
        gte(loanTransactions.transactionDate, toDateKey(range.from)),
        lt(loanTransactions.transactionDate, toDateKey(range.to)),
      ),
    );
  return Number(row?.total ?? 0);
}

export async function getLoansOutstandingAsOf(
  db: Database,
  businessId: string,
  asOf: Date,
): Promise<number> {
  const asOfKey = toDateKey(asOf);
  const accounts = await db
    .select({
      id: loanAccounts.id,
      opening: loanAccounts.openingOutstanding,
      asOf: loanAccounts.openingBalanceAsOf,
    })
    .from(loanAccounts)
    .where(
      and(eq(loanAccounts.businessId, businessId), eq(loanAccounts.isDeleted, false)),
    );

  let total = 0;
  for (const account of accounts) {
    let balance = Number(account.opening ?? 0);
    const txns = await db
      .select({
        date: loanTransactions.transactionDate,
        type: loanTransactions.transactionType,
        principal: loanTransactions.principalAmount,
      })
      .from(loanTransactions)
      .where(
        and(
          eq(loanTransactions.businessId, businessId),
          eq(loanTransactions.loanAccountId, account.id),
          eq(loanTransactions.isDeleted, false),
          gte(loanTransactions.transactionDate, account.asOf),
          lte(loanTransactions.transactionDate, asOfKey),
        ),
      );
    for (const txn of txns) {
      const principal = Number(txn.principal ?? 0);
      if (txn.type === 'increase') balance += principal;
      if (txn.type === 'repayment') balance -= principal;
    }
    total += Math.max(0, balance);
  }
  return total;
}

export async function sumExpensesAmount(
  db: Database,
  businessId: string,
  range: ResolvedReportPeriod,
): Promise<number> {
  const [row] = await db
    .select({
      total: sql<string>`COALESCE(SUM(${expenses.amount}::numeric), 0)`,
    })
    .from(expenses)
    .where(
      and(
        eq(expenses.businessId, businessId),
        eq(expenses.isDeleted, false),
        gte(expenses.expenseDate, toDateKey(range.from)),
        lt(expenses.expenseDate, toDateKey(range.to)),
      ),
    );
  return Number(row?.total ?? 0);
}

export async function calculateNetProfit(
  db: Database,
  businessId: string,
  range: ResolvedReportPeriod,
): Promise<number> {
  const [
    salesTotal,
    salesReturnTotal,
    purchaseTotal,
    purchaseReturnTotal,
    expenseTotal,
    otherIncomeDirect,
    otherIncomeIndirect,
    loanFinancing,
  ] = await Promise.all([
    sumSalesAmount(db, businessId, range, REVENUE_SALES_TYPES),
    sumSalesAmount(db, businessId, range, [SALES_RETURN_TYPE]),
    sumPurchasesAmount(db, businessId, range, PURCHASE_BILL_TYPE),
    sumPurchasesAmount(db, businessId, range, PURCHASE_RETURN_TYPE),
    sumExpensesAmount(db, businessId, range),
    sumOtherIncomeAmount(db, businessId, range, 'direct'),
    sumOtherIncomeAmount(db, businessId, range, 'indirect'),
    sumLoanFinancingExpense(db, businessId, range),
  ]);

  const grossProfit =
    salesTotal - salesReturnTotal - (purchaseTotal - purchaseReturnTotal);
  const otherIncome = otherIncomeDirect + otherIncomeIndirect;
  return grossProfit - expenseTotal - loanFinancing + otherIncome;
}

export async function getDashboardOutstanding(
  db: Database,
  businessId: string,
) {
  const repo = new OutstandingRepository(db);
  return repo.getOutstandingSummary(businessId);
}

export async function getStockValue(db: Database, businessId: string) {
  return Number(await getTotalStockValue(db, businessId));
}
