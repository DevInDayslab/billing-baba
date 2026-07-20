import { and, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { expenseCategories } from '../../db/schema/purchases/tables';
import { normalizeMoney } from '../inventory/inventory.utils';
import {
  EXPENSE_SOURCE_TYPES,
  SYSTEM_EXPENSE_CATEGORIES,
  SYSTEM_EXPENSE_CATEGORY_NAMES,
} from './expense-category.constants';
import { postExpenseLedgerEntry, reverseExpenseLedgerEntry } from './expense-ledger.service';
import { ExpenseRepository } from './expense.repository';
import type { ExpenseRecord } from './expense.types';

type DbExecutor = Pick<Database, 'insert' | 'select' | 'update' | 'transaction'>;

export async function ensureSystemExpenseCategories(
  db: DbExecutor,
  businessId: string,
  userId?: string | null,
): Promise<void> {
  const existing = await db
    .select({ name: expenseCategories.name })
    .from(expenseCategories)
    .where(
      and(
        eq(expenseCategories.businessId, businessId),
        eq(expenseCategories.isDeleted, false),
      ),
    );

  const existingNames = new Set(
    existing.map((row) => row.name.trim().toLowerCase()),
  );

  const missing = SYSTEM_EXPENSE_CATEGORIES.filter(
    (category) => !existingNames.has(category.name.trim().toLowerCase()),
  );

  if (missing.length === 0) {
    return;
  }

  await db.insert(expenseCategories).values(
    missing.map((category) => ({
      businessId,
      name: category.name,
      categoryType: category.categoryType,
      isSystem: true,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    })),
  );
}

async function findSystemCategoryId(
  db: DbExecutor,
  businessId: string,
  categoryName: string,
): Promise<string> {
  const [row] = await db
    .select({ id: expenseCategories.id })
    .from(expenseCategories)
    .where(
      and(
        eq(expenseCategories.businessId, businessId),
        eq(expenseCategories.isDeleted, false),
        sql`lower(${expenseCategories.name}) = ${categoryName.trim().toLowerCase()}`,
      ),
    )
    .limit(1);

  if (!row) {
    throw new Error(`Missing system expense category: ${categoryName}`);
  }

  return row.id;
}

async function upsertLinkedExpense(
  db: Database,
  params: {
    businessId: string;
    userId?: string | null;
    categoryName: string;
    sourceReferenceId: string;
    sourceReferenceType: string;
    partyId: string;
    amount: string;
    expenseDate: string;
    referenceNumber?: string | null;
    description?: string | null;
    paymentMode?: string | null;
    loyaltyPoints?: string | null;
    dueDate?: string | null;
    balanceDue?: string | null;
  },
): Promise<ExpenseRecord | null> {
  if (Number(params.amount) <= 0) {
    await removeLinkedExpense(db, {
      businessId: params.businessId,
      userId: params.userId,
      sourceReferenceId: params.sourceReferenceId,
      sourceReferenceType: params.sourceReferenceType,
    });
    return null;
  }

  await ensureSystemExpenseCategories(db, params.businessId, params.userId);
  const categoryId = await findSystemCategoryId(
    db,
    params.businessId,
    params.categoryName,
  );

  const repo = new ExpenseRepository(db);
  const existing = await repo.findBySourceReference(
    params.businessId,
    params.sourceReferenceId,
    params.sourceReferenceType,
  );

  if (existing) {
    await reverseExpenseLedgerEntry(db, params.businessId, existing);
    const updated = await repo.update(params.businessId, existing.id, {
      categoryId,
      partyId: params.partyId,
      amount: params.amount,
      description: params.description ?? null,
      referenceNumber: params.referenceNumber ?? null,
      expenseDate: params.expenseDate,
      paymentMode: params.paymentMode ?? null,
      loyaltyPoints: params.loyaltyPoints ?? null,
      dueDate: params.dueDate ?? null,
      balanceDue: params.balanceDue ?? '0',
      updatedBy: params.userId ?? null,
    });
    if (!updated) {
      return null;
    }
    await postExpenseLedgerEntry(db, {
      businessId: params.businessId,
      expense: updated,
    });
    return updated;
  }

  const created = await repo.create({
    businessId: params.businessId,
    categoryId,
    partyId: params.partyId,
    amount: params.amount,
    description: params.description ?? null,
    referenceNumber: params.referenceNumber ?? null,
    expenseDate: params.expenseDate,
    paymentMode: params.paymentMode ?? null,
    sourceReferenceId: params.sourceReferenceId,
    sourceReferenceType: params.sourceReferenceType,
    loyaltyPoints: params.loyaltyPoints ?? null,
    dueDate: params.dueDate ?? null,
    balanceDue: params.balanceDue ?? '0',
    createdBy: params.userId ?? null,
    updatedBy: params.userId ?? null,
  });

  await postExpenseLedgerEntry(db, {
    businessId: params.businessId,
    expense: created,
  });

  return created;
}

export async function syncLoyaltyRedeemedExpense(
  db: Database,
  params: {
    businessId: string;
    userId?: string | null;
    documentId: string;
    documentNumber: string | null;
    partyId: string;
    expenseDate: string;
    loyaltyPointsRedeemed: string;
    loyaltyValueRedeemed: string;
  },
): Promise<ExpenseRecord | null> {
  return upsertLinkedExpense(db, {
    businessId: params.businessId,
    userId: params.userId,
    categoryName: SYSTEM_EXPENSE_CATEGORY_NAMES.loyaltyRedeemed,
    sourceReferenceId: params.documentId,
    sourceReferenceType: EXPENSE_SOURCE_TYPES.saleLoyaltyRedemption,
    partyId: params.partyId,
    amount: normalizeMoney(Number(params.loyaltyValueRedeemed)),
    expenseDate: params.expenseDate,
    referenceNumber: params.documentNumber,
    description: 'Loyalty points redeemed on sale',
    loyaltyPoints: normalizeMoney(Number(params.loyaltyPointsRedeemed)),
    paymentMode: 'cash',
    balanceDue: '0',
  });
}

export async function syncPaymentInDiscountExpense(
  db: Database,
  params: {
    businessId: string;
    userId?: string | null;
    paymentId: string;
    partyId: string;
    expenseDate: string;
    referenceNumber?: string | null;
    paymentMode: string;
    discountAmount: string;
    balanceDue: string;
    dueDate?: string | null;
  },
): Promise<ExpenseRecord | null> {
  return upsertLinkedExpense(db, {
    businessId: params.businessId,
    userId: params.userId,
    categoryName: SYSTEM_EXPENSE_CATEGORY_NAMES.paymentInDiscount,
    sourceReferenceId: params.paymentId,
    sourceReferenceType: EXPENSE_SOURCE_TYPES.paymentInDiscount,
    partyId: params.partyId,
    amount: normalizeMoney(Number(params.discountAmount)),
    expenseDate: params.expenseDate,
    referenceNumber: params.referenceNumber,
    description: 'Payment-in discount',
    paymentMode: params.paymentMode,
    balanceDue: normalizeMoney(Number(params.balanceDue)),
    dueDate: params.dueDate ?? null,
  });
}

async function removeLinkedExpense(
  db: Database,
  params: {
    businessId: string;
    userId?: string | null;
    sourceReferenceId: string;
    sourceReferenceType: string;
  },
): Promise<void> {
  const repo = new ExpenseRepository(db);
  const existing = await repo.findBySourceReference(
    params.businessId,
    params.sourceReferenceId,
    params.sourceReferenceType,
  );
  if (!existing) return;

  await reverseExpenseLedgerEntry(db, params.businessId, existing);
  await repo.softDelete(
    params.businessId,
    existing.id,
    params.userId ?? null,
  );
}

export async function deleteLinkedExpense(
  db: Database,
  params: {
    businessId: string;
    userId?: string | null;
    sourceReferenceId: string;
    sourceReferenceType: string;
  },
): Promise<void> {
  await removeLinkedExpense(db, params);
}
