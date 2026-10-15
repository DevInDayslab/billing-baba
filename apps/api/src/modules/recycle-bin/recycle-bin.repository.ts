import { and, desc, eq, gte, isNotNull } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { payments } from '../../db/schema/accounting/tables';
import { users } from '../../db/schema';
import { parties } from '../../db/schema/crm/tables';
import { loanTransactions } from '../../db/schema/loans/tables';
import { otherIncomes } from '../../db/schema/other-income/tables';
import { expenses, purchaseDocuments } from '../../db/schema/purchases/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import {
  daysRemaining,
  recycleBinRetentionCutoff,
  type RecycleBinEntityType,
} from './recycle-bin.constants';
import type { RecycleBinItemRecord } from './recycle-bin.types';

export class RecycleBinRepository {
  constructor(private readonly db: Database) {}

  async hasBusinessMembership(
    businessId: string,
    accountId: string,
  ): Promise<boolean> {
    const [membership] = await this.db
      .select({ id: users.id })
      .from(users)
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.accountId, accountId),
          eq(users.isActive, true),
          eq(users.isDeleted, false),
        ),
      )
      .limit(1);

    return Boolean(membership);
  }

  async list(
    businessId: string,
    params: {
      page: number;
      limit: number;
      entityType?: RecycleBinEntityType;
    },
  ): Promise<{ rows: RecycleBinItemRecord[]; total: number }> {
    const cutoff = recycleBinRetentionCutoff();
    const collected: RecycleBinItemRecord[] = [];

    const types: RecycleBinEntityType[] = params.entityType
      ? [params.entityType]
      : [
          'sales_document',
          'purchase_document',
          'payment',
          'expense',
          'other_income',
          'loan_transaction',
        ];

    for (const entityType of types) {
      collected.push(...(await this.listForType(businessId, entityType, cutoff)));
    }

    collected.sort(
      (a, b) =>
        new Date(b.deleted_at).getTime() - new Date(a.deleted_at).getTime(),
    );

    const total = collected.length;
    const offset = (params.page - 1) * params.limit;

    return {
      rows: collected.slice(offset, offset + params.limit),
      total,
    };
  }

  private async listForType(
    businessId: string,
    entityType: RecycleBinEntityType,
    cutoff: Date,
  ): Promise<RecycleBinItemRecord[]> {
    switch (entityType) {
      case 'sales_document':
        return this.listSalesDocuments(businessId, cutoff);
      case 'purchase_document':
        return this.listPurchaseDocuments(businessId, cutoff);
      case 'payment':
        return this.listPayments(businessId, cutoff);
      case 'expense':
        return this.listExpenses(businessId, cutoff);
      case 'other_income':
        return this.listOtherIncomes(businessId, cutoff);
      case 'loan_transaction':
        return this.listLoanTransactions(businessId, cutoff);
      default:
        return [];
    }
  }

  private async listSalesDocuments(
    businessId: string,
    cutoff: Date,
  ): Promise<RecycleBinItemRecord[]> {
    const rows = await this.db
      .select({
        id: salesDocuments.id,
        documentType: salesDocuments.documentType,
        documentNumber: salesDocuments.documentNumber,
        totalAmount: salesDocuments.totalAmount,
        documentDate: salesDocuments.documentDate,
        deletedAt: salesDocuments.deletedAt,
        partyName: parties.name,
      })
      .from(salesDocuments)
      .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, true),
          isNotNull(salesDocuments.deletedAt),
          gte(salesDocuments.deletedAt, cutoff),
        ),
      )
      .orderBy(desc(salesDocuments.deletedAt));

    return rows
      .filter((row) => row.deletedAt)
      .map((row) => ({
        entity_type: 'sales_document' as const,
        entity_id: row.id,
        label: row.documentNumber ?? row.documentType,
        party_name: row.partyName,
        amount: row.totalAmount,
        transaction_date: row.documentDate.toISOString().slice(0, 10),
        deleted_at: row.deletedAt!.toISOString(),
        days_remaining: daysRemaining(row.deletedAt!),
      }));
  }

  private async listPurchaseDocuments(
    businessId: string,
    cutoff: Date,
  ): Promise<RecycleBinItemRecord[]> {
    const rows = await this.db
      .select({
        id: purchaseDocuments.id,
        documentType: purchaseDocuments.documentType,
        documentNumber: purchaseDocuments.documentNumber,
        totalAmount: purchaseDocuments.totalAmount,
        documentDate: purchaseDocuments.documentDate,
        deletedAt: purchaseDocuments.deletedAt,
        partyName: parties.name,
      })
      .from(purchaseDocuments)
      .leftJoin(parties, eq(purchaseDocuments.partyId, parties.id))
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, true),
          isNotNull(purchaseDocuments.deletedAt),
          gte(purchaseDocuments.deletedAt, cutoff),
        ),
      )
      .orderBy(desc(purchaseDocuments.deletedAt));

    return rows
      .filter((row) => row.deletedAt)
      .map((row) => ({
        entity_type: 'purchase_document' as const,
        entity_id: row.id,
        label: row.documentNumber ?? row.documentType,
        party_name: row.partyName,
        amount: row.totalAmount,
        transaction_date: row.documentDate.toISOString().slice(0, 10),
        deleted_at: row.deletedAt!.toISOString(),
        days_remaining: daysRemaining(row.deletedAt!),
      }));
  }

  private async listPayments(
    businessId: string,
    cutoff: Date,
  ): Promise<RecycleBinItemRecord[]> {
    const rows = await this.db
      .select({
        id: payments.id,
        amount: payments.amount,
        paymentDate: payments.paymentDate,
        deletedAt: payments.deletedAt,
        referenceNumber: payments.referenceNumber,
        direction: payments.direction,
        partyName: parties.name,
      })
      .from(payments)
      .leftJoin(parties, eq(payments.partyId, parties.id))
      .where(
        and(
          eq(payments.businessId, businessId),
          eq(payments.isDeleted, true),
          isNotNull(payments.deletedAt),
          gte(payments.deletedAt, cutoff),
        ),
      )
      .orderBy(desc(payments.deletedAt));

    return rows
      .filter((row) => row.deletedAt)
      .map((row) => ({
        entity_type: 'payment' as const,
        entity_id: row.id,
        label:
          row.referenceNumber ??
          (row.direction === 'received' ? 'Payment In' : 'Payment Out'),
        party_name: row.partyName,
        amount: row.amount,
        transaction_date: row.paymentDate.toISOString().slice(0, 10),
        deleted_at: row.deletedAt!.toISOString(),
        days_remaining: daysRemaining(row.deletedAt!),
      }));
  }

  private async listExpenses(
    businessId: string,
    cutoff: Date,
  ): Promise<RecycleBinItemRecord[]> {
    const rows = await this.db
      .select({
        id: expenses.id,
        amount: expenses.amount,
        expenseDate: expenses.expenseDate,
        deletedAt: expenses.deletedAt,
        description: expenses.description,
        partyName: parties.name,
      })
      .from(expenses)
      .leftJoin(parties, eq(expenses.partyId, parties.id))
      .where(
        and(
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, true),
          isNotNull(expenses.deletedAt),
          gte(expenses.deletedAt, cutoff),
        ),
      )
      .orderBy(desc(expenses.deletedAt));

    return rows
      .filter((row) => row.deletedAt)
      .map((row) => ({
        entity_type: 'expense' as const,
        entity_id: row.id,
        label: row.description ?? 'Expense',
        party_name: row.partyName,
        amount: row.amount,
        transaction_date: row.expenseDate,
        deleted_at: row.deletedAt!.toISOString(),
        days_remaining: daysRemaining(row.deletedAt!),
      }));
  }

  private async listOtherIncomes(
    businessId: string,
    cutoff: Date,
  ): Promise<RecycleBinItemRecord[]> {
    const rows = await this.db
      .select({
        id: otherIncomes.id,
        amount: otherIncomes.amount,
        incomeDate: otherIncomes.incomeDate,
        deletedAt: otherIncomes.deletedAt,
        description: otherIncomes.description,
      })
      .from(otherIncomes)
      .where(
        and(
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, true),
          isNotNull(otherIncomes.deletedAt),
          gte(otherIncomes.deletedAt, cutoff),
        ),
      )
      .orderBy(desc(otherIncomes.deletedAt));

    return rows
      .filter((row) => row.deletedAt)
      .map((row) => ({
        entity_type: 'other_income' as const,
        entity_id: row.id,
        label: row.description ?? 'Other Income',
        party_name: null,
        amount: row.amount,
        transaction_date: row.incomeDate,
        deleted_at: row.deletedAt!.toISOString(),
        days_remaining: daysRemaining(row.deletedAt!),
      }));
  }

  private async listLoanTransactions(
    businessId: string,
    cutoff: Date,
  ): Promise<RecycleBinItemRecord[]> {
    const rows = await this.db
      .select({
        id: loanTransactions.id,
        principalAmount: loanTransactions.principalAmount,
        transactionDate: loanTransactions.transactionDate,
        deletedAt: loanTransactions.deletedAt,
        transactionType: loanTransactions.transactionType,
        description: loanTransactions.description,
      })
      .from(loanTransactions)
      .where(
        and(
          eq(loanTransactions.businessId, businessId),
          eq(loanTransactions.isDeleted, true),
          isNotNull(loanTransactions.deletedAt),
          gte(loanTransactions.deletedAt, cutoff),
        ),
      )
      .orderBy(desc(loanTransactions.deletedAt));

    return rows
      .filter((row) => row.deletedAt)
      .map((row) => ({
        entity_type: 'loan_transaction' as const,
        entity_id: row.id,
        label: row.description ?? row.transactionType,
        party_name: null,
        amount: row.principalAmount,
        transaction_date: String(row.transactionDate).slice(0, 10),
        deleted_at: row.deletedAt!.toISOString(),
        days_remaining: daysRemaining(row.deletedAt!),
      }));
  }
}
