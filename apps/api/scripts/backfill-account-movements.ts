/**
 * Idempotent backfill for bank_account_id + account_movements.
 * Usage: bun scripts/backfill-account-movements.ts [--dry-run]
 */
import 'dotenv/config';
import { and, eq } from 'drizzle-orm';
import { getDb } from '../src/db/client';
import { payments } from '../src/db/schema/accounting/tables';
import { loanTransactions } from '../src/db/schema/loans/tables';
import { otherIncomes } from '../src/db/schema/other-income/tables';
import { expenses } from '../src/db/schema/purchases/tables';
import { taxDeposits } from '../src/db/schema/withholding/tables';
import { BankAccountService } from '../src/modules/bank-accounts/bank-account.service';
import { syncExpenseMovement } from '../src/modules/bank-accounts/expense-movement.helper';
import { syncLoanTransactionMovement } from '../src/modules/bank-accounts/loan-movement.helper';
import { syncOtherIncomeMovement } from '../src/modules/bank-accounts/other-income-movement.helper';
import { recordPaymentMovement } from '../src/modules/bank-accounts/payment-movement.helper';
import { LoanTransactionRepository } from '../src/modules/loans/loan-transaction.repository';
import { OtherIncomeRepository } from '../src/modules/other-income/other-income.repository';
import { ExpenseRepository } from '../src/modules/purchases/expense.repository';
import { recordTaxDepositMovement } from '../src/modules/withholding-tax/tax-deposit-movement.helper';

const dryRun = process.argv.includes('--dry-run');

async function main() {
  const db = getDb();
  if (!db) {
    console.error('Database not configured');
    process.exit(1);
  }

  const businessIds = await db
    .selectDistinct({ id: payments.businessId })
    .from(payments);

  const expenseBusinesses = await db
    .selectDistinct({ id: expenses.businessId })
    .from(expenses);
  const otherIncomeBusinesses = await db
    .selectDistinct({ id: otherIncomes.businessId })
    .from(otherIncomes);
  const loanBusinesses = await db
    .selectDistinct({ id: loanTransactions.businessId })
    .from(loanTransactions);

  const ids = new Set<string>();
  for (const row of businessIds) ids.add(row.id);
  for (const row of expenseBusinesses) ids.add(row.id);
  for (const row of otherIncomeBusinesses) ids.add(row.id);
  for (const row of loanBusinesses) ids.add(row.id);

  let movementCount = 0;

  for (const businessId of Array.from(ids)) {
    const bankService = new BankAccountService(db);
    if (!dryRun) {
      await bankService.ensureCashAccount(businessId);
      await bankService.ensureDefaultBank(businessId, 'Primary Bank');
    }

    const payRows = await db
      .select()
      .from(payments)
      .where(
        and(eq(payments.businessId, businessId), eq(payments.isDeleted, false)),
      );

    for (const pay of payRows) {
      const accountId = await bankService.resolveAccountId(
        businessId,
        (pay.paymentMode ?? 'cash') as 'cash',
        pay.bankAccountId,
      );
      if (!dryRun && pay.bankAccountId !== accountId) {
        await db
          .update(payments)
          .set({ bankAccountId: accountId })
          .where(eq(payments.id, pay.id));
      }
      if (!dryRun) {
        await recordPaymentMovement(db, {
          businessId,
          paymentId: pay.id,
          partyId: pay.partyId,
          direction: pay.direction,
          amount: pay.amount,
          paymentMode: pay.paymentMode ?? 'cash',
          paymentDate: pay.paymentDate,
          bankAccountId: accountId,
        });
      }
      movementCount += 1;
    }

    const expenseRepo = new ExpenseRepository(db);
    const expenseRows = await db
      .select({
        id: expenses.id,
        paymentMode: expenses.paymentMode,
        bankAccountId: expenses.bankAccountId,
      })
      .from(expenses)
      .where(
        and(eq(expenses.businessId, businessId), eq(expenses.isDeleted, false)),
      );

    for (const exp of expenseRows) {
      const accountId = await bankService.resolveAccountId(
        businessId,
        (exp.paymentMode ?? 'cash') as 'cash',
        exp.bankAccountId,
      );
      if (!dryRun && exp.bankAccountId !== accountId) {
        await db
          .update(expenses)
          .set({ bankAccountId: accountId })
          .where(eq(expenses.id, exp.id));
      }
      if (!dryRun) {
        const record = await expenseRepo.findById(businessId, exp.id);
        if (record) {
          await syncExpenseMovement(db, businessId, record);
        }
      }
      movementCount += 1;
    }

    const deposits = await db
      .select()
      .from(taxDeposits)
      .where(
        and(
          eq(taxDeposits.businessId, businessId),
          eq(taxDeposits.isDeleted, false),
        ),
      );

    for (const dep of deposits) {
      if (!dryRun) {
        await recordTaxDepositMovement(db, businessId, {
          id: dep.id,
          amount: dep.amount,
          depositDate: dep.depositDate,
          challanSerial: dep.challanSerial,
          bankAccountId: dep.bankAccountId,
        });
      }
      movementCount += 1;
    }

    const otherIncomeRepo = new OtherIncomeRepository(db);
    const otherIncomeRows = await db
      .select({ id: otherIncomes.id })
      .from(otherIncomes)
      .where(
        and(
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      );
    for (const row of otherIncomeRows) {
      if (!dryRun) {
        const income = await otherIncomeRepo.findById(businessId, row.id);
        if (income) {
          await syncOtherIncomeMovement(db, businessId, income);
        }
      }
      movementCount += 1;
    }

    const loanTxnRepo = new LoanTransactionRepository(db);
    const loanTxnRows = await db
      .select({ id: loanTransactions.id })
      .from(loanTransactions)
      .where(
        and(
          eq(loanTransactions.businessId, businessId),
          eq(loanTransactions.isDeleted, false),
        ),
      );
    for (const row of loanTxnRows) {
      if (!dryRun) {
        const txn = await loanTxnRepo.findById(businessId, row.id);
        if (txn) {
          await syncLoanTransactionMovement(db, businessId, txn);
        }
      }
      movementCount += 1;
    }
  }

  console.log(
    dryRun
      ? `[dry-run] Would process ~${movementCount} movement sources across ${ids.size} businesses`
      : `Backfill complete: ${movementCount} movement sources across ${ids.size} businesses`,
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
