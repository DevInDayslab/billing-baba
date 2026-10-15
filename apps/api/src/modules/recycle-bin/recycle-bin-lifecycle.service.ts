import { and, eq, isNotNull, lt } from 'drizzle-orm';
import { getDb } from '../../db/client';
import { payments } from '../../db/schema/accounting/tables';
import { loanTransactions } from '../../db/schema/loans/tables';
import { otherIncomes } from '../../db/schema/other-income/tables';
import { expenses } from '../../db/schema/purchases/tables';
import { AppError } from '../../shared/errors/app-error';
import { PaymentService } from '../accounting/payment.service';
import { ExpenseService } from '../purchases/expense.service';
import { OtherIncomeService } from '../other-income/other-income.service';
import { LoanTransactionService } from '../loans/loan-transaction.service';
import { SalesDocumentRepository } from '../sales/sales-document.repository';
import { SalesDocumentService } from '../sales/sales-document.service';
import { PurchaseDocumentRepository } from '../purchases/purchase-document.repository';
import { PurchaseDocumentService } from '../purchases/purchase-document.service';
import {
  daysRemaining,
  recycleBinRetentionCutoff,
  type RecycleBinEntityType,
} from './recycle-bin.constants';
import {
  applyPurchaseDocumentStockAndLedger,
  reversePurchaseDocumentStockAndLedger,
} from './domain/reapply-purchase-document-effects';
import {
  applySalesDocumentStockAndLedger,
  reverseSalesDocumentStockAndLedger,
} from './domain/reapply-sales-document-effects';

export type LifecycleContext = {
  businessId: string;
  accountId: string;
  userId?: string;
};

type EntityHandler = {
  delete: (ctx: LifecycleContext, entityId: string) => Promise<void>;
  restore: (ctx: LifecycleContext, entityId: string) => Promise<void>;
  purge: (ctx: LifecycleContext, entityId: string) => Promise<void>;
};

export class RecycleBinLifecycleService {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly registry: Record<RecycleBinEntityType, EntityHandler>;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.db = db;
    this.registry = {
      sales_document: {
        delete: (ctx, id) => this.deleteSalesDocument(ctx, id),
        restore: (ctx, id) => this.restoreSalesDocument(ctx, id),
        purge: (ctx, id) => this.purgeSalesDocument(ctx, id),
      },
      purchase_document: {
        delete: (ctx, id) => this.deletePurchaseDocument(ctx, id),
        restore: (ctx, id) => this.restorePurchaseDocument(ctx, id),
        purge: (ctx, id) => this.purgePurchaseDocument(ctx, id),
      },
      payment: {
        delete: (ctx, id) => this.deletePayment(ctx, id),
        restore: (ctx, id) => this.restorePayment(ctx, id),
        purge: (ctx, id) => this.purgePayment(ctx, id),
      },
      expense: {
        delete: (ctx, id) => this.deleteExpense(ctx, id),
        restore: (ctx, id) => this.restoreExpense(ctx, id),
        purge: (ctx, id) => this.purgeExpense(ctx, id),
      },
      other_income: {
        delete: (ctx, id) => this.deleteOtherIncome(ctx, id),
        restore: (ctx, id) => this.restoreOtherIncome(ctx, id),
        purge: (ctx, id) => this.purgeOtherIncome(ctx, id),
      },
      loan_transaction: {
        delete: (ctx, id) => this.deleteLoanTransaction(ctx, id),
        restore: (ctx, id) => this.restoreLoanTransaction(ctx, id),
        purge: (ctx, id) => this.purgeLoanTransaction(ctx, id),
      },
    };
  }

  async deleteEntity(
    entityType: RecycleBinEntityType,
    ctx: LifecycleContext,
    entityId: string,
  ): Promise<void> {
    await this.registry[entityType].delete(ctx, entityId);
  }

  async restoreEntity(
    entityType: RecycleBinEntityType,
    ctx: LifecycleContext,
    entityId: string,
  ): Promise<void> {
    await this.assertWithinRetention(entityType, ctx.businessId, entityId);
    await this.registry[entityType].restore(ctx, entityId);
  }

  async purgeEntity(
    entityType: RecycleBinEntityType,
    ctx: LifecycleContext,
    entityId: string,
  ): Promise<void> {
    await this.registry[entityType].purge(ctx, entityId);
  }

  private async assertWithinRetention(
    entityType: RecycleBinEntityType,
    businessId: string,
    entityId: string,
  ): Promise<void> {
    const deletedAt = await this.readDeletedAt(entityType, businessId, entityId);
    if (!deletedAt) {
      throw new AppError('NOT_FOUND', 'Deleted item not found', 404);
    }
    if (daysRemaining(deletedAt) <= 0) {
      throw new AppError(
        'RETENTION_EXPIRED',
        'Item is past the recycle bin retention window',
        410,
      );
    }
  }

  private async readDeletedAt(
    entityType: RecycleBinEntityType,
    businessId: string,
    entityId: string,
  ): Promise<Date | null> {
    switch (entityType) {
      case 'sales_document': {
        const row = await new SalesDocumentRepository(this.db).findRowByIdIncludingDeleted(
          businessId,
          entityId,
        );
        return row?.deletedAt ?? null;
      }
      case 'purchase_document': {
        const row = await new PurchaseDocumentRepository(
          this.db,
        ).findRowByIdIncludingDeleted(businessId, entityId);
        return row?.deletedAt ?? null;
      }
      case 'payment': {
        const [row] = await this.db
          .select({ deletedAt: payments.deletedAt })
          .from(payments)
          .where(
            and(eq(payments.businessId, businessId), eq(payments.id, entityId)),
          )
          .limit(1);
        return row?.deletedAt ?? null;
      }
      case 'expense': {
        const [row] = await this.db
          .select({ deletedAt: expenses.deletedAt })
          .from(expenses)
          .where(
            and(eq(expenses.businessId, businessId), eq(expenses.id, entityId)),
          )
          .limit(1);
        return row?.deletedAt ?? null;
      }
      case 'other_income': {
        const [row] = await this.db
          .select({ deletedAt: otherIncomes.deletedAt })
          .from(otherIncomes)
          .where(
            and(
              eq(otherIncomes.businessId, businessId),
              eq(otherIncomes.id, entityId),
            ),
          )
          .limit(1);
        return row?.deletedAt ?? null;
      }
      case 'loan_transaction': {
        const [row] = await this.db
          .select({ deletedAt: loanTransactions.deletedAt })
          .from(loanTransactions)
          .where(
            and(
              eq(loanTransactions.businessId, businessId),
              eq(loanTransactions.id, entityId),
            ),
          )
          .limit(1);
        return row?.deletedAt ?? null;
      }
      default:
        return null;
    }
  }

  private async deleteSalesDocument(
    ctx: LifecycleContext,
    documentId: string,
  ): Promise<void> {
    const repo = new SalesDocumentRepository(this.db);
    const document = await repo.findRowById(ctx.businessId, documentId);
    if (!document) {
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
    }

    if (document.status === 'draft') {
      await new SalesDocumentService().deleteDocument(
        ctx.businessId,
        ctx.accountId,
        ctx.userId,
        documentId,
      );
      return;
    }

    if (document.status !== 'finalized') {
      throw new AppError(
        'DOCUMENT_NOT_EDITABLE',
        'Only draft or finalized documents can be deleted',
        409,
      );
    }

    await this.db.transaction(async (tx) => {
      const txRepo = new SalesDocumentRepository(tx as unknown as typeof this.db);
      await reverseSalesDocumentStockAndLedger(
        this.db,
        tx as never,
        txRepo,
        {
          businessId: ctx.businessId,
          documentId,
          userId: ctx.userId,
        },
      );
      const deleted = await txRepo.softDeleteToRecycle(
        ctx.businessId,
        documentId,
        ctx.userId ?? null,
      );
      if (!deleted) {
        throw new AppError('NOT_FOUND', 'Sales document not found', 404);
      }
    });
  }

  private async restoreSalesDocument(
    ctx: LifecycleContext,
    documentId: string,
  ): Promise<void> {
    await this.db.transaction(async (tx) => {
      const txRepo = new SalesDocumentRepository(tx as unknown as typeof this.db);
      const restored = await txRepo.restoreFromRecycle(
        ctx.businessId,
        documentId,
        ctx.userId ?? null,
      );
      if (!restored) {
        throw new AppError('NOT_FOUND', 'Deleted sales document not found', 404);
      }
      await applySalesDocumentStockAndLedger(
        this.db,
        tx as never,
        txRepo,
        {
          businessId: ctx.businessId,
          documentId,
          userId: ctx.userId,
        },
      );
    });
  }

  private async purgeSalesDocument(
    ctx: LifecycleContext,
    documentId: string,
  ): Promise<void> {
    const purged = await new SalesDocumentRepository(this.db).purgeFromRecycle(
      ctx.businessId,
      documentId,
    );
    if (!purged) {
      throw new AppError('NOT_FOUND', 'Deleted sales document not found', 404);
    }
  }

  private async deletePurchaseDocument(
    ctx: LifecycleContext,
    documentId: string,
  ): Promise<void> {
    const repo = new PurchaseDocumentRepository(this.db);
    const document = await repo.findRowById(ctx.businessId, documentId);
    if (!document) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }

    if (document.status === 'draft') {
      await new PurchaseDocumentService().deleteDocument(
        ctx.businessId,
        ctx.accountId,
        ctx.userId,
        documentId,
      );
      return;
    }

    if (document.status !== 'finalized') {
      throw new AppError(
        'DOCUMENT_NOT_EDITABLE',
        'Only draft or finalized documents can be deleted',
        409,
      );
    }

    await this.db.transaction(async (tx) => {
      const txRepo = new PurchaseDocumentRepository(
        tx as unknown as typeof this.db,
      );
      await reversePurchaseDocumentStockAndLedger(
        this.db,
        tx as never,
        txRepo,
        {
          businessId: ctx.businessId,
          documentId,
          userId: ctx.userId,
        },
      );
      const deleted = await txRepo.softDeleteToRecycle(
        ctx.businessId,
        documentId,
        ctx.userId ?? null,
      );
      if (!deleted) {
        throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
      }
    });
  }

  private async restorePurchaseDocument(
    ctx: LifecycleContext,
    documentId: string,
  ): Promise<void> {
    await this.db.transaction(async (tx) => {
      const txRepo = new PurchaseDocumentRepository(
        tx as unknown as typeof this.db,
      );
      const restored = await txRepo.restoreFromRecycle(
        ctx.businessId,
        documentId,
        ctx.userId ?? null,
      );
      if (!restored) {
        throw new AppError(
          'NOT_FOUND',
          'Deleted purchase document not found',
          404,
        );
      }
      await applyPurchaseDocumentStockAndLedger(
        this.db,
        tx as never,
        txRepo,
        {
          businessId: ctx.businessId,
          documentId,
          userId: ctx.userId,
        },
      );
    });
  }

  private async purgePurchaseDocument(
    ctx: LifecycleContext,
    documentId: string,
  ): Promise<void> {
    const purged = await new PurchaseDocumentRepository(this.db).purgeFromRecycle(
      ctx.businessId,
      documentId,
    );
    if (!purged) {
      throw new AppError('NOT_FOUND', 'Deleted purchase document not found', 404);
    }
  }

  private async deletePayment(
    ctx: LifecycleContext,
    paymentId: string,
  ): Promise<void> {
    await new PaymentService().deletePayment(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      paymentId,
    );
  }

  private async restorePayment(
    ctx: LifecycleContext,
    paymentId: string,
  ): Promise<void> {
    await new PaymentService().restorePayment(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      paymentId,
    );
  }

  private async purgePayment(
    ctx: LifecycleContext,
    paymentId: string,
  ): Promise<void> {
    await new PaymentService().purgePayment(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      paymentId,
    );
  }

  private async deleteExpense(
    ctx: LifecycleContext,
    expenseId: string,
  ): Promise<void> {
    await new ExpenseService().deleteExpense(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      expenseId,
    );
  }

  private async restoreExpense(
    ctx: LifecycleContext,
    expenseId: string,
  ): Promise<void> {
    await new ExpenseService().restoreExpense(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      expenseId,
    );
  }

  private async purgeExpense(
    ctx: LifecycleContext,
    expenseId: string,
  ): Promise<void> {
    await new ExpenseService().purgeExpense(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      expenseId,
    );
  }

  private async deleteOtherIncome(
    ctx: LifecycleContext,
    otherIncomeId: string,
  ): Promise<void> {
    await new OtherIncomeService().deleteOtherIncome(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      otherIncomeId,
    );
  }

  private async restoreOtherIncome(
    ctx: LifecycleContext,
    otherIncomeId: string,
  ): Promise<void> {
    await new OtherIncomeService().restoreOtherIncome(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      otherIncomeId,
    );
  }

  private async purgeOtherIncome(
    ctx: LifecycleContext,
    otherIncomeId: string,
  ): Promise<void> {
    await new OtherIncomeService().purgeOtherIncome(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      otherIncomeId,
    );
  }

  private async deleteLoanTransaction(
    ctx: LifecycleContext,
    transactionId: string,
  ): Promise<void> {
    await new LoanTransactionService().deleteLoanTransaction(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      transactionId,
    );
  }

  private async restoreLoanTransaction(
    ctx: LifecycleContext,
    transactionId: string,
  ): Promise<void> {
    await new LoanTransactionService().restoreLoanTransaction(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      transactionId,
    );
  }

  private async purgeLoanTransaction(
    ctx: LifecycleContext,
    transactionId: string,
  ): Promise<void> {
    await new LoanTransactionService().purgeLoanTransaction(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      transactionId,
    );
  }

  /** Purge all items past retention (optional maintenance). */
  async purgeExpired(businessId: string): Promise<number> {
    const cutoff = recycleBinRetentionCutoff();
    let count = 0;

    const expenseIds = await this.db
      .select({ id: expenses.id })
      .from(expenses)
      .where(
        and(
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, true),
          isNotNull(expenses.deletedAt),
          lt(expenses.deletedAt, cutoff),
        ),
      );
    for (const row of expenseIds) {
      await this.db
        .delete(expenses)
        .where(
          and(eq(expenses.businessId, businessId), eq(expenses.id, row.id)),
        );
      count += 1;
    }

    return count;
  }
}
