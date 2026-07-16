import { and, asc, desc, eq, gte, inArray, lte, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { ledgerEntries, payments } from '../../db/schema/accounting/tables';
import { parties } from '../../db/schema/crm/tables';
import { expenses, purchaseDocuments } from '../../db/schema/purchases/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import { PURCHASE_BILL_TYPE, REVENUE_SALES_TYPES } from './constants';

export type PartyLedgerFilter =
  | 'all'
  | 'sales'
  | 'purchases'
  | 'payments'
  | 'returns';

export type PartyLedgerEntryRow = {
  id: string;
  date: string;
  createdAt: Date;
  entryType: string;
  description: string | null;
  debit: string;
  credit: string;
  referenceId: string | null;
  referenceType: string | null;
  referenceNumber: string | null;
  paymentDirection: 'received' | 'paid' | null;
  salesDocumentType: string | null;
  purchaseDocumentType: string | null;
};

export type PartyLedgerSummary = {
  openingBalance: number;
  outstanding: number;
  receiveAmount: number;
  payableAmount: number;
  totalSales: number;
  totalPurchases: number;
  totalPayments: number;
  lastTransactionDate: string | null;
};

export type PartyLedgerReport = {
  partyId: string;
  openingBalance: number;
  summary: PartyLedgerSummary;
  entries: PartyLedgerEntryRow[];
  runningBalances: Map<string, number>;
};

/**
 * Exclude ledger rows whose source document is draft, cancelled, or soft-deleted.
 * Must be applied on the main ledger_entries query (not inside correlated subqueries).
 */
export const validLedgerEntrySql = sql`(
  ${ledgerEntries.referenceId} IS NULL
  OR ${ledgerEntries.referenceType} IS NULL
  OR (
    ${ledgerEntries.referenceType} = 'sales_documents'
    AND EXISTS (
      SELECT 1 FROM ${salesDocuments}
      WHERE ${salesDocuments.id} = ${ledgerEntries.referenceId}
        AND ${salesDocuments.status} = 'finalized'
        AND ${salesDocuments.isDeleted} = false
    )
  )
  OR (
    ${ledgerEntries.referenceType} = 'purchase_documents'
    AND EXISTS (
      SELECT 1 FROM ${purchaseDocuments}
      WHERE ${purchaseDocuments.id} = ${ledgerEntries.referenceId}
        AND ${purchaseDocuments.status} = 'finalized'
        AND ${purchaseDocuments.isDeleted} = false
    )
  )
  OR (
    ${ledgerEntries.referenceType} = 'payments'
    AND EXISTS (
      SELECT 1 FROM ${payments}
      WHERE ${payments.id} = ${ledgerEntries.referenceId}
        AND ${payments.isDeleted} = false
    )
  )
  OR (
    ${ledgerEntries.referenceType} = 'expenses'
    AND EXISTS (
      SELECT 1 FROM ${expenses}
      WHERE ${expenses.id} = ${ledgerEntries.referenceId}
        AND ${expenses.isDeleted} = false
    )
  )
)`;

function filterCondition(filter: PartyLedgerFilter) {
  switch (filter) {
    case 'sales':
      return eq(ledgerEntries.entryType, 'sale');
    case 'purchases':
      return eq(ledgerEntries.entryType, 'purchase');
    case 'payments':
      return eq(ledgerEntries.entryType, 'payment');
    case 'returns':
      return eq(ledgerEntries.entryType, 'return');
    default:
      return undefined;
  }
}

export function resolveLedgerTypeLabel(
  entryType: string,
  salesDocumentType: string | null,
  purchaseDocumentType: string | null,
  paymentDirection: 'received' | 'paid' | null,
): string {
  if (entryType === 'sale') return 'Sale Invoice';
  if (entryType === 'purchase') return 'Purchase Bill';
  if (entryType === 'payment') {
    return paymentDirection === 'paid' ? 'Payment Out' : 'Payment In';
  }
  if (entryType === 'expense') return 'Expense';
  if (entryType === 'opening') return 'Opening Balance';
  if (entryType === 'return') {
    if (salesDocumentType === 'sales_return') return 'Sale Return';
    if (purchaseDocumentType === 'purchase_return') return 'Purchase Return';
    return 'Return';
  }
  return entryType;
}

export async function fetchPartyLedgerEntries(
  db: Database,
  params: {
    businessId: string;
    partyId: string;
    filter?: PartyLedgerFilter;
    from?: string;
    to?: string;
    order?: 'asc' | 'desc';
  },
): Promise<PartyLedgerEntryRow[]> {
  const filters = [
    eq(ledgerEntries.businessId, params.businessId),
    eq(ledgerEntries.partyId, params.partyId),
    validLedgerEntrySql,
  ];

  const typeFilter = filterCondition(params.filter ?? 'all');
  if (typeFilter) {
    filters.push(typeFilter);
  }

  if (params.from) {
    filters.push(gte(ledgerEntries.entryDate, params.from));
  }
  if (params.to) {
    filters.push(lte(ledgerEntries.entryDate, params.to));
  }

  const orderBy =
    params.order === 'asc'
      ? [asc(ledgerEntries.entryDate), asc(ledgerEntries.createdAt)]
      : [desc(ledgerEntries.entryDate), desc(ledgerEntries.createdAt)];

  const rows = await db
    .select({
      id: ledgerEntries.id,
      date: ledgerEntries.entryDate,
      createdAt: ledgerEntries.createdAt,
      entryType: ledgerEntries.entryType,
      description: ledgerEntries.description,
      debit: ledgerEntries.debit,
      credit: ledgerEntries.credit,
      referenceId: ledgerEntries.referenceId,
      referenceType: ledgerEntries.referenceType,
      referenceNumber: sql<string | null>`COALESCE(
        ${salesDocuments.documentNumber},
        ${purchaseDocuments.documentNumber},
        ${payments.referenceNumber},
        ${expenses.description}
      )`,
      paymentDirection: payments.direction,
      salesDocumentType: salesDocuments.documentType,
      purchaseDocumentType: purchaseDocuments.documentType,
    })
    .from(ledgerEntries)
    .leftJoin(
      salesDocuments,
      and(
        eq(ledgerEntries.referenceType, 'sales_documents'),
        eq(ledgerEntries.referenceId, salesDocuments.id),
      ),
    )
    .leftJoin(
      purchaseDocuments,
      and(
        eq(ledgerEntries.referenceType, 'purchase_documents'),
        eq(ledgerEntries.referenceId, purchaseDocuments.id),
      ),
    )
    .leftJoin(
      payments,
      and(
        eq(ledgerEntries.referenceType, 'payments'),
        eq(ledgerEntries.referenceId, payments.id),
      ),
    )
    .leftJoin(
      expenses,
      and(
        eq(ledgerEntries.referenceType, 'expenses'),
        eq(ledgerEntries.referenceId, expenses.id),
      ),
    )
    .where(and(...filters))
    .orderBy(...orderBy);

  return rows.map((row) => ({
    id: row.id,
    date: row.date,
    createdAt: row.createdAt,
    entryType: row.entryType,
    description: row.description,
    debit: row.debit ?? '0',
    credit: row.credit ?? '0',
    referenceId: row.referenceId,
    referenceType: row.referenceType,
    referenceNumber: row.referenceNumber,
    paymentDirection: row.paymentDirection,
    salesDocumentType: row.salesDocumentType,
    purchaseDocumentType: row.purchaseDocumentType,
  }));
}

export function computeRunningBalances(
  openingBalance: number,
  entries: PartyLedgerEntryRow[],
): Map<string, number> {
  const sorted = [...entries].sort(
    (a, b) =>
      a.date.localeCompare(b.date) ||
      a.createdAt.getTime() - b.createdAt.getTime(),
  );

  let running = openingBalance;
  const balances = new Map<string, number>();

  for (const entry of sorted) {
    running += Number(entry.debit) - Number(entry.credit);
    balances.set(entry.id, running);
  }

  return balances;
}

function computeOutstandingFromEntries(
  openingBalance: number,
  entries: PartyLedgerEntryRow[],
): number {
  return (
    openingBalance +
    entries.reduce(
      (sum, entry) => sum + Number(entry.debit) - Number(entry.credit),
      0,
    )
  );
}

export async function fetchPartyDocumentTotals(
  db: Database,
  businessId: string,
  partyId: string,
): Promise<{
  totalSales: number;
  totalPurchases: number;
  totalPayments: number;
}> {
  const [salesRow] = await db
    .select({
      total: sql<string>`COALESCE(SUM(${salesDocuments.totalAmount}::numeric), 0)`,
    })
    .from(salesDocuments)
    .where(
      and(
        eq(salesDocuments.businessId, businessId),
        eq(salesDocuments.partyId, partyId),
        eq(salesDocuments.isDeleted, false),
        eq(salesDocuments.status, 'finalized'),
        inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
      ),
    );

  const [purchaseRow] = await db
    .select({
      total: sql<string>`COALESCE(SUM(${purchaseDocuments.totalAmount}::numeric), 0)`,
    })
    .from(purchaseDocuments)
    .where(
      and(
        eq(purchaseDocuments.businessId, businessId),
        eq(purchaseDocuments.partyId, partyId),
        eq(purchaseDocuments.isDeleted, false),
        eq(purchaseDocuments.status, 'finalized'),
        eq(purchaseDocuments.documentType, PURCHASE_BILL_TYPE),
      ),
    );

  const [paymentRow] = await db
    .select({
      total: sql<string>`COALESCE(SUM(${payments.amount}::numeric), 0)`,
    })
    .from(payments)
    .where(
      and(
        eq(payments.businessId, businessId),
        eq(payments.partyId, partyId),
        eq(payments.isDeleted, false),
        eq(payments.direction, 'received'),
      ),
    );

  return {
    totalSales: Number(salesRow?.total ?? 0),
    totalPurchases: Number(purchaseRow?.total ?? 0),
    totalPayments: Number(paymentRow?.total ?? 0),
  };
}

export function buildPartyLedgerSummary(
  openingBalance: number,
  entries: PartyLedgerEntryRow[],
  documentTotals: {
    totalSales: number;
    totalPurchases: number;
    totalPayments: number;
  },
): PartyLedgerSummary {
  const outstanding = computeOutstandingFromEntries(openingBalance, entries);

  let lastTransactionDate: string | null = null;
  for (const entry of entries) {
    if (!lastTransactionDate || entry.date > lastTransactionDate) {
      lastTransactionDate = entry.date;
    }
  }

  return {
    openingBalance,
    outstanding,
    receiveAmount: Math.max(0, outstanding),
    payableAmount: Math.max(0, -outstanding),
    totalSales: documentTotals.totalSales,
    totalPurchases: documentTotals.totalPurchases,
    totalPayments: documentTotals.totalPayments,
    lastTransactionDate,
  };
}

/** Single accounting engine used by party ledger, party statement, and outstanding. */
export async function buildPartyLedgerReport(
  db: Database,
  businessId: string,
  partyId: string,
  options: {
    filter?: PartyLedgerFilter;
    from?: string;
    to?: string;
  } = {},
): Promise<PartyLedgerReport> {
  const openingBalance = await getPartyOpeningBalance(db, businessId, partyId);

  const allEntries = await fetchPartyLedgerEntries(db, {
    businessId,
    partyId,
    from: options.from,
    to: options.to,
    order: 'asc',
  });

  const documentTotals = await fetchPartyDocumentTotals(
    db,
    businessId,
    partyId,
  );

  const summary = buildPartyLedgerSummary(
    openingBalance,
    allEntries,
    documentTotals,
  );

  const runningBalances = computeRunningBalances(openingBalance, allEntries);

  let displayEntries = allEntries;
  if (options.filter && options.filter !== 'all') {
    displayEntries = await fetchPartyLedgerEntries(db, {
      businessId,
      partyId,
      filter: options.filter,
      from: options.from,
      to: options.to,
      order: 'desc',
    });
  } else {
    displayEntries = [...allEntries].sort(
      (a, b) =>
        b.date.localeCompare(a.date) ||
        b.createdAt.getTime() - a.createdAt.getTime(),
    );
  }

  return {
    partyId,
    openingBalance,
    summary,
    entries: displayEntries,
    runningBalances,
  };
}

export type AggregatedPartyBalance = {
  party_id: string;
  balance: string;
};

/** Aggregate ledger balances for all parties — avoids broken correlated subqueries. */
export async function aggregatePartyLedgerBalances(
  db: Database,
  businessId: string,
): Promise<AggregatedPartyBalance[]> {
  const ledgerTotals = await db
    .select({
      partyId: ledgerEntries.partyId,
      debitTotal: sql<string>`COALESCE(SUM(${ledgerEntries.debit}::numeric), 0)`,
      creditTotal: sql<string>`COALESCE(SUM(${ledgerEntries.credit}::numeric), 0)`,
    })
    .from(ledgerEntries)
    .where(and(eq(ledgerEntries.businessId, businessId), validLedgerEntrySql))
    .groupBy(ledgerEntries.partyId);

  const ledgerMap = new Map<string, { debit: number; credit: number }>();
  for (const row of ledgerTotals) {
    if (!row.partyId) continue;
    ledgerMap.set(row.partyId, {
      debit: Number(row.debitTotal ?? 0),
      credit: Number(row.creditTotal ?? 0),
    });
  }

  const partyRows = await db
    .select({
      id: parties.id,
      openingBalance: parties.openingBalance,
    })
    .from(parties)
    .where(
      and(eq(parties.businessId, businessId), eq(parties.isDeleted, false)),
    );

  return partyRows.map((party) => {
    const ledger = ledgerMap.get(party.id) ?? { debit: 0, credit: 0 };
    const opening = Number(party.openingBalance ?? 0);
    const balance = opening + ledger.debit - ledger.credit;
    return {
      party_id: party.id,
      balance: balance.toFixed(4),
    };
  });
}

export async function getPartyOpeningBalance(
  db: Database,
  businessId: string,
  partyId: string,
): Promise<number> {
  const [row] = await db
    .select({ openingBalance: parties.openingBalance })
    .from(parties)
    .where(
      and(
        eq(parties.businessId, businessId),
        eq(parties.id, partyId),
        eq(parties.isDeleted, false),
      ),
    )
    .limit(1);

  return Number(row?.openingBalance ?? 0);
}

/** @deprecated Use buildPartyLedgerSummary */
export function computePartyLedgerSummary(
  openingBalance: number,
  entries: PartyLedgerEntryRow[],
): PartyLedgerSummary {
  let totalSales = 0;
  let totalPurchases = 0;
  let totalPayments = 0;
  let lastTransactionDate: string | null = null;

  for (const entry of entries) {
    const debit = Number(entry.debit);
    const credit = Number(entry.credit);

    if (entry.entryType === 'sale') {
      totalSales += debit;
    } else if (entry.entryType === 'purchase') {
      totalPurchases += credit;
    } else if (
      entry.entryType === 'payment' &&
      entry.paymentDirection === 'received'
    ) {
      totalPayments += credit;
    }

    if (!lastTransactionDate || entry.date > lastTransactionDate) {
      lastTransactionDate = entry.date;
    }
  }

  const outstanding = computeOutstandingFromEntries(openingBalance, entries);

  return {
    openingBalance,
    outstanding,
    receiveAmount: Math.max(0, outstanding),
    payableAmount: Math.max(0, -outstanding),
    totalSales,
    totalPurchases,
    totalPayments,
    lastTransactionDate,
  };
}

export function logPartyLedgerDebug(
  partyName: string,
  report: PartyLedgerReport,
): void {
  if (process.env.PARTY_LEDGER_DEBUG !== 'true') return;

  console.log(`\n=== Party Ledger Debug: ${partyName} ===`);
  console.log(`Opening Balance: ${report.openingBalance.toFixed(2)}`);
  console.log('--------------------------------');

  const chronological = [...report.entries].sort(
    (a, b) =>
      a.date.localeCompare(b.date) ||
      a.createdAt.getTime() - b.createdAt.getTime(),
  );

  for (const entry of chronological) {
    const balance =
      report.runningBalances.get(entry.id) ?? report.openingBalance;
    const delta = Number(entry.debit) - Number(entry.credit);
    const sign = delta >= 0 ? '+' : '';
    console.log(
      `${entry.date}  ${resolveLedgerTypeLabel(entry.entryType, entry.salesDocumentType, entry.purchaseDocumentType, entry.paymentDirection)}  ${sign}${delta.toFixed(2)}  Running ${balance.toFixed(2)}`,
    );
    console.log('--------------------------------');
  }

  console.log(`Final Outstanding: ${report.summary.outstanding.toFixed(2)}`);
  console.log(
    `Total Sales (documents): ${report.summary.totalSales.toFixed(2)}`,
  );
  console.log(
    `Total Payments (receipts): ${report.summary.totalPayments.toFixed(2)}`,
  );
  console.log(
    `Total Purchases (documents): ${report.summary.totalPurchases.toFixed(2)}`,
  );
}
