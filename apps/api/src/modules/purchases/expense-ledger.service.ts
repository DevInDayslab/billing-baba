import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { ledgerEntries } from '../../db/schema/accounting/tables';
import type { ExpenseRecord } from './expense.types';

type PostExpenseLedgerParams = {
  businessId: string;
  expense: ExpenseRecord;
  reverse?: boolean;
};

export async function postExpenseLedgerEntry(
  db: Database,
  params: PostExpenseLedgerParams,
): Promise<void> {
  const amount = params.expense.amount;
  const isReverse = params.reverse ?? false;

  await db.insert(ledgerEntries).values({
    businessId: params.businessId,
    partyId: params.expense.party_id,
    entryType: 'expense',
    debit: isReverse ? '0' : amount,
    credit: isReverse ? amount : '0',
    balanceAfter: amount,
    referenceId: params.expense.id,
    referenceType: 'expenses',
    entryDate: params.expense.expense_date,
    description: params.expense.description ?? 'Expense recorded',
  });
}

export async function reverseExpenseLedgerEntry(
  db: Database,
  businessId: string,
  expense: ExpenseRecord,
): Promise<void> {
  await postExpenseLedgerEntry(db, {
    businessId,
    expense,
    reverse: true,
  });
}

export async function deleteExpenseLedgerEntries(
  db: Database,
  businessId: string,
  expenseId: string,
): Promise<void> {
  await db
    .delete(ledgerEntries)
    .where(
      and(
        eq(ledgerEntries.referenceId, expenseId),
        eq(ledgerEntries.businessId, businessId),
        eq(ledgerEntries.referenceType, 'expenses'),
      ),
    );
}
