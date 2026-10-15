import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { expenses } from '../../db/schema/purchases/tables';
import { ExpenseRepository } from '../purchases/expense.repository';
import type { ExpenseRecord } from '../purchases/expense.types';
import {
  postExpenseLedgerEntry,
  reverseExpenseLedgerEntry,
} from '../purchases/expense-ledger.service';
import { syncExpenseMovement, voidExpenseMovement } from './expense-movement.helper';
import type { RowMutationInput } from '../sync/apply/sync-apply.types';

export async function afterExpenseRowMutation(
  db: Database,
  input: RowMutationInput,
  operation: 'create' | 'update' | 'delete',
): Promise<void> {
  const repo = new ExpenseRepository(db);

  if (operation === 'delete') {
    const [row] = await db
      .select()
      .from(expenses)
      .where(
        and(
          eq(expenses.businessId, input.businessId),
          eq(expenses.id, input.entityId),
        ),
      )
      .limit(1);
    if (row) {
      const expense: ExpenseRecord = {
        id: row.id,
        category_id: row.categoryId,
        category_name: '',
        expense_item_id: row.expenseItemId,
        party_id: row.partyId,
        party_name: null,
        amount: row.amount,
        tax_amount: row.taxAmount,
        tax_rate: row.taxRate,
        description: row.description,
        notes: row.notes,
        reference_number: row.referenceNumber,
        attachments: row.attachments ?? [],
        expense_date: row.expenseDate,
        payment_mode: row.paymentMode,
        bank_account_id: row.bankAccountId,
        source_reference_id: row.sourceReferenceId,
        source_reference_type: row.sourceReferenceType,
        loyalty_points: row.loyaltyPoints,
        due_date: row.dueDate,
        balance_due: row.balanceDue,
        created_at: row.createdAt.toISOString(),
        updated_at: row.updatedAt.toISOString(),
      };
      await reverseExpenseLedgerEntry(db, input.businessId, expense);
    }
    await voidExpenseMovement(db, input.businessId, input.entityId);
    return;
  }

  const expense = await repo.findById(input.businessId, input.entityId);
  if (!expense) return;
  await syncExpenseMovement(db, input.businessId, expense);
}

export async function afterExpenseRowRevive(
  db: Database,
  input: RowMutationInput,
): Promise<void> {
  const repo = new ExpenseRepository(db);
  const expense = await repo.findById(input.businessId, input.entityId);
  if (!expense) return;
  await postExpenseLedgerEntry(db, { businessId: input.businessId, expense });
  await syncExpenseMovement(db, input.businessId, expense);
}
