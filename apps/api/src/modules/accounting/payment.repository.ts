import { and, asc, count, desc, eq, gte, lte, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  ledgerEntries,
  paymentAllocations,
  payments,
} from '../../db/schema/accounting/tables';
import { parties } from '../../db/schema/crm/tables';
import { purchaseDocuments } from '../../db/schema/purchases/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import type {
  AllocationInsertValues,
  PaymentAllocationRecord,
  PaymentInsertValues,
  PaymentRecord,
} from './payment.types';

export class PaymentRepository {
  constructor(private readonly db: Database) {}

  async list(params: {
    businessId: string;
    page: number;
    limit: number;
    partyId?: string;
    direction?: 'received' | 'paid';
    from?: Date;
    to?: Date;
    sort: 'payment_date' | 'created_at';
    order: 'asc' | 'desc';
  }): Promise<{ rows: PaymentRecord[]; total: number }> {
    const filters = [
      eq(payments.businessId, params.businessId),
      eq(payments.isDeleted, false),
    ];

    if (params.partyId) {
      filters.push(eq(payments.partyId, params.partyId));
    }
    if (params.direction) {
      filters.push(eq(payments.direction, params.direction));
    }
    if (params.from) {
      filters.push(gte(payments.paymentDate, params.from));
    }
    if (params.to) {
      filters.push(lte(payments.paymentDate, params.to));
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(payments)
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at' ? payments.createdAt : payments.paymentDate;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select()
      .from(payments)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return { rows: rows.map(toPaymentRecord), total };
  }

  async findById(
    businessId: string,
    paymentId: string,
    includeAllocations = false,
  ): Promise<PaymentRecord | null> {
    const [row] = await this.db
      .select()
      .from(payments)
      .where(
        and(
          eq(payments.id, paymentId),
          eq(payments.businessId, businessId),
          eq(payments.isDeleted, false),
        ),
      )
      .limit(1);

    if (!row) {
      return null;
    }

    const record = toPaymentRecord(row);
    if (includeAllocations) {
      record.allocations = await this.listAllocations(businessId, paymentId);
    }

    return record;
  }

  async create(values: PaymentInsertValues): Promise<PaymentRecord> {
    const [row] = await this.db
      .insert(payments)
      .values({
        businessId: values.businessId,
        partyId: values.partyId,
        direction: values.direction,
        amount: values.amount,
        paymentMode: values.paymentMode as PaymentInsertValues['paymentMode'],
        paymentDate: values.paymentDate ?? new Date(),
        referenceNumber: values.referenceNumber ?? null,
        notes: values.notes ?? null,
        shortPaymentHandling: values.shortPaymentHandling as
          | 'official_balance'
          | 'unrecovered'
          | null
          | undefined,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create payment');
    }

    return toPaymentRecord(row);
  }

  async updateNotes(
    businessId: string,
    paymentId: string,
    values: {
      notes?: string | null;
      referenceNumber?: string | null;
      updatedBy?: string | null;
    },
  ): Promise<PaymentRecord | null> {
    const [row] = await this.db
      .update(payments)
      .set({
        ...(values.notes !== undefined ? { notes: values.notes } : {}),
        ...(values.referenceNumber !== undefined
          ? { referenceNumber: values.referenceNumber }
          : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${payments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(payments.id, paymentId),
          eq(payments.businessId, businessId),
          eq(payments.isDeleted, false),
        ),
      )
      .returning();

    return row ? toPaymentRecord(row) : null;
  }

  async softDelete(
    businessId: string,
    paymentId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(payments)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${payments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(payments.id, paymentId),
          eq(payments.businessId, businessId),
          eq(payments.isDeleted, false),
        ),
      )
      .returning({ id: payments.id });

    return Boolean(row);
  }

  async listAllocations(
    businessId: string,
    paymentId: string,
  ): Promise<PaymentAllocationRecord[]> {
    const rows = await this.db
      .select()
      .from(paymentAllocations)
      .where(
        and(
          eq(paymentAllocations.paymentId, paymentId),
          eq(paymentAllocations.businessId, businessId),
          eq(paymentAllocations.isDeleted, false),
        ),
      );

    return rows.map(toAllocationRecord);
  }

  async createAllocation(
    values: AllocationInsertValues,
  ): Promise<PaymentAllocationRecord> {
    const [row] = await this.db
      .insert(paymentAllocations)
      .values({
        businessId: values.businessId,
        paymentId: values.paymentId,
        salesDocumentId: values.salesDocumentId ?? null,
        purchaseDocumentId: values.purchaseDocumentId ?? null,
        allocatedAmount: values.allocatedAmount,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create allocation');
    }

    return toAllocationRecord(row);
  }

  async softDeleteAllocation(
    businessId: string,
    allocationId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(paymentAllocations)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${paymentAllocations.syncVersion} + 1`,
      })
      .where(
        and(
          eq(paymentAllocations.id, allocationId),
          eq(paymentAllocations.businessId, businessId),
          eq(paymentAllocations.isDeleted, false),
        ),
      )
      .returning({ id: paymentAllocations.id });

    return Boolean(row);
  }

  async sumAllocatedToPayment(
    businessId: string,
    paymentId: string,
  ): Promise<number> {
    const [row] = await this.db
      .select({
        total: sql<string>`coalesce(sum(${paymentAllocations.allocatedAmount}::numeric), 0)`,
      })
      .from(paymentAllocations)
      .where(
        and(
          eq(paymentAllocations.paymentId, paymentId),
          eq(paymentAllocations.businessId, businessId),
          eq(paymentAllocations.isDeleted, false),
        ),
      );

    return Number(row?.total ?? 0);
  }

  async sumAllocatedToSalesDocument(
    businessId: string,
    salesDocumentId: string,
  ): Promise<number> {
    const [row] = await this.db
      .select({
        total: sql<string>`coalesce(sum(${paymentAllocations.allocatedAmount}::numeric), 0)`,
      })
      .from(paymentAllocations)
      .where(
        and(
          eq(paymentAllocations.salesDocumentId, salesDocumentId),
          eq(paymentAllocations.businessId, businessId),
          eq(paymentAllocations.isDeleted, false),
        ),
      );

    return Number(row?.total ?? 0);
  }

  async findSalesDocumentForAllocation(
    businessId: string,
    salesDocumentId: string,
  ): Promise<{
    id: string;
    partyId: string | null;
    status: string;
    totalAmount: string;
  } | null> {
    const [row] = await this.db
      .select({
        id: salesDocuments.id,
        partyId: salesDocuments.partyId,
        status: salesDocuments.status,
        totalAmount: salesDocuments.totalAmount,
      })
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.id, salesDocumentId),
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async findPurchaseDocumentForAllocation(
    businessId: string,
    purchaseDocumentId: string,
  ): Promise<{
    id: string;
    partyId: string | null;
    status: string;
    totalAmount: string;
  } | null> {
    const [row] = await this.db
      .select({
        id: purchaseDocuments.id,
        partyId: purchaseDocuments.partyId,
        status: purchaseDocuments.status,
        totalAmount: purchaseDocuments.totalAmount,
      })
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.id, purchaseDocumentId),
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async findParty(businessId: string, partyId: string) {
    const [row] = await this.db
      .select({
        id: parties.id,
        unrecoveredAmount: parties.unrecoveredAmount,
      })
      .from(parties)
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async updatePartyUnrecovered(
    businessId: string,
    partyId: string,
    amount: string,
  ): Promise<void> {
    await this.db
      .update(parties)
      .set({
        unrecoveredAmount: amount,
        updatedAt: new Date(),
        syncVersion: sql`${parties.syncVersion} + 1`,
      })
      .where(
        and(eq(parties.id, partyId), eq(parties.businessId, businessId)),
      );
  }

  async createLedgerEntry(values: {
    businessId: string;
    partyId: string;
    entryType: 'payment';
    debit: string;
    credit: string;
    balanceAfter: string;
    referenceId: string;
    referenceType: string;
    entryDate: string;
    description?: string;
  }): Promise<void> {
    await this.db.insert(ledgerEntries).values({
      businessId: values.businessId,
      partyId: values.partyId,
      entryType: values.entryType,
      debit: values.debit,
      credit: values.credit,
      balanceAfter: values.balanceAfter,
      referenceId: values.referenceId,
      referenceType: values.referenceType,
      entryDate: values.entryDate,
      description: values.description ?? null,
    });
  }

  async hasBusinessMembership(
    businessId: string,
    accountId: string,
  ): Promise<boolean> {
    const { users } = await import('../../db/schema/identity/tables');
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
}

function toPaymentRecord(row: typeof payments.$inferSelect): PaymentRecord {
  return {
    id: row.id,
    party_id: row.partyId,
    direction: row.direction,
    amount: row.amount,
    payment_mode: row.paymentMode,
    payment_date: row.paymentDate.toISOString(),
    reference_number: row.referenceNumber,
    notes: row.notes,
    short_payment_handling: row.shortPaymentHandling,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}

function toAllocationRecord(
  row: typeof paymentAllocations.$inferSelect,
): PaymentAllocationRecord {
  return {
    id: row.id,
    payment_id: row.paymentId,
    sales_document_id: row.salesDocumentId,
    purchase_document_id: row.purchaseDocumentId,
    allocated_amount: row.allocatedAmount,
  };
}
