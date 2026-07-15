import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { normalizeMoney, parseMoney } from '../inventory/inventory.utils';
import { PaymentRepository } from './payment.repository';
import type {
  CreateAllocationBody,
  CreatePaymentBody,
  ListPaymentsQuery,
  UpdatePaymentBody,
} from './payment.schema';
import type { PaymentRecord } from './payment.types';

export class PaymentService {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: PaymentRepository;

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
    this.repository = new PaymentRepository(db);
  }

  private async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const hasAccess = await this.repository.hasBusinessMembership(
      businessId,
      accountId,
    );
    if (!hasAccess) {
      throw new AppError(
        'FORBIDDEN',
        'You do not have access to this business',
        403,
      );
    }
  }

  async listPayments(
    businessId: string,
    accountId: string,
    query: ListPaymentsQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      partyId: query.party_id,
      direction: query.direction,
      from: query.from ? new Date(query.from) : undefined,
      to: query.to ? new Date(query.to) : undefined,
      sort: query.sort,
      order: query.order,
    });

    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async getPayment(
    businessId: string,
    accountId: string,
    paymentId: string,
  ): Promise<PaymentRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const payment = await this.repository.findById(businessId, paymentId, true);
    if (!payment) {
      throw new AppError('NOT_FOUND', 'Payment not found', 404);
    }

    return payment;
  }

  async createPayment(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreatePaymentBody,
  ): Promise<PaymentRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const party = await this.repository.findParty(businessId, input.party_id);
    if (!party) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    const allocations = input.allocations ?? [];
    const paymentAmount = parseMoney(input.amount);

    for (const allocation of allocations) {
      const hasSales = Boolean(allocation.sales_document_id);
      const hasPurchase = Boolean(allocation.purchase_document_id);
      if (hasSales === hasPurchase) {
        throw new AppError(
          'VALIDATION_ERROR',
          'Each allocation must reference exactly one document',
          422,
        );
      }
    }

    return this.db.transaction(async (tx) => {
      const repo = new PaymentRepository(tx as unknown as typeof this.db);

      let pendingPaymentTotal = 0;
      for (const allocation of allocations) {
        await this.assertAllocationTarget(
          repo,
          businessId,
          { party_id: input.party_id, amount: input.amount },
          allocation,
          { pendingPaymentTotal },
        );
        pendingPaymentTotal += parseMoney(allocation.allocated_amount);
      }

      const payment = await repo.create({
        businessId,
        partyId: input.party_id,
        direction: input.direction,
        amount: input.amount,
        paymentMode: input.payment_mode,
        paymentDate: input.payment_date
          ? new Date(input.payment_date)
          : undefined,
        referenceNumber: input.reference_number ?? null,
        notes: input.notes ?? null,
        shortPaymentHandling: input.short_payment_handling ?? null,
        source: input.source ?? 'manual',
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      });

      for (const allocation of allocations) {
        await repo.createAllocation({
          businessId,
          paymentId: payment.id,
          salesDocumentId: allocation.sales_document_id ?? null,
          purchaseDocumentId: allocation.purchase_document_id ?? null,
          allocatedAmount: allocation.allocated_amount,
          createdBy: userId ?? null,
          updatedBy: userId ?? null,
        });
      }

      const credit = input.direction === 'received' ? input.amount : '0';
      const debit = input.direction === 'paid' ? input.amount : '0';

      await repo.createLedgerEntry({
        businessId,
        partyId: input.party_id,
        entryType: 'payment',
        debit,
        credit,
        balanceAfter: input.amount,
        referenceId: payment.id,
        referenceType: 'payments',
        entryDate: (input.payment_date ?? new Date().toISOString()).slice(
          0,
          10,
        ),
        description: `Payment ${input.direction}`,
      });

      if (
        input.short_payment_handling === 'unrecovered' &&
        pendingPaymentTotal < paymentAmount
      ) {
        const shortfall = paymentAmount - pendingPaymentTotal;
        const current = parseMoney(party.unrecoveredAmount);
        await repo.updatePartyUnrecovered(
          businessId,
          input.party_id,
          normalizeMoney(current + shortfall),
        );
      }

      const full = await repo.findById(businessId, payment.id, true);
      return full!;
    });
  }

  async updatePayment(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    paymentId: string,
    input: UpdatePaymentBody,
  ): Promise<PaymentRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const updated = await this.repository.updateNotes(businessId, paymentId, {
      notes: input.notes,
      referenceNumber: input.reference_number,
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Payment not found', 404);
    }

    return updated;
  }

  async deletePayment(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    paymentId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const deleted = await this.repository.softDelete(
      businessId,
      paymentId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Payment not found', 404);
    }
  }

  async listAllocations(
    businessId: string,
    accountId: string,
    paymentId: string,
  ) {
    await this.assertBusinessAccess(businessId, accountId);

    const payment = await this.repository.findById(businessId, paymentId);
    if (!payment) {
      throw new AppError('NOT_FOUND', 'Payment not found', 404);
    }

    return this.repository.listAllocations(businessId, paymentId);
  }

  async addAllocation(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    paymentId: string,
    input: CreateAllocationBody,
  ) {
    await this.assertBusinessAccess(businessId, accountId);

    const payment = await this.repository.findById(businessId, paymentId);
    if (!payment) {
      throw new AppError('NOT_FOUND', 'Payment not found', 404);
    }

    const hasSales = Boolean(input.sales_document_id);
    const hasPurchase = Boolean(input.purchase_document_id);
    if (hasSales === hasPurchase) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Allocation must reference exactly one document',
        422,
      );
    }

    return this.db.transaction(async (tx) => {
      const repo = new PaymentRepository(tx as unknown as typeof this.db);

      await this.assertAllocationTarget(
        repo,
        businessId,
        { party_id: payment.party_id, amount: payment.amount, id: paymentId },
        input,
      );

      return repo.createAllocation({
        businessId,
        paymentId,
        salesDocumentId: input.sales_document_id ?? null,
        purchaseDocumentId: input.purchase_document_id ?? null,
        allocatedAmount: input.allocated_amount,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      });
    });
  }

  async deleteAllocation(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    paymentId: string,
    allocationId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const payment = await this.repository.findById(businessId, paymentId);
    if (!payment) {
      throw new AppError('NOT_FOUND', 'Payment not found', 404);
    }

    const deleted = await this.repository.softDeleteAllocation(
      businessId,
      allocationId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Allocation not found', 404);
    }
  }

  private async assertAllocationTarget(
    repo: PaymentRepository,
    businessId: string,
    payment: { party_id: string; amount: string; id?: string },
    allocation: CreateAllocationBody,
    options?: { pendingPaymentTotal?: number },
  ): Promise<void> {
    const allocationAmount = parseMoney(allocation.allocated_amount);
    const paymentAmount = parseMoney(payment.amount);

    let existingPaymentAllocated = options?.pendingPaymentTotal ?? 0;
    if (payment.id) {
      existingPaymentAllocated += await repo.sumAllocatedToPayment(
        businessId,
        payment.id,
      );
    }

    if (existingPaymentAllocated + allocationAmount > paymentAmount) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Allocated amount exceeds payment amount',
        422,
      );
    }

    if (allocation.sales_document_id) {
      const document = await repo.findSalesDocumentForAllocation(
        businessId,
        allocation.sales_document_id,
      );
      if (!document) {
        throw new AppError('NOT_FOUND', 'Sales document not found', 404);
      }
      if (document.status !== 'finalized') {
        throw new AppError(
          'VALIDATION_ERROR',
          'Allocations require a finalized sales document',
          422,
        );
      }
      if (document.partyId !== payment.party_id) {
        throw new AppError(
          'VALIDATION_ERROR',
          'Sales document party does not match payment party',
          422,
        );
      }

      const alreadyAllocated = await repo.sumAllocatedToSalesDocument(
        businessId,
        allocation.sales_document_id,
      );
      const documentTotal = parseMoney(document.totalAmount);
      if (alreadyAllocated + allocationAmount > documentTotal) {
        throw new AppError(
          'VALIDATION_ERROR',
          'Allocated amount exceeds document remaining balance',
          422,
        );
      }
      return;
    }

    if (allocation.purchase_document_id) {
      const document = await repo.findPurchaseDocumentForAllocation(
        businessId,
        allocation.purchase_document_id,
      );
      if (!document) {
        throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
      }
      if (document.status !== 'finalized') {
        throw new AppError(
          'VALIDATION_ERROR',
          'Allocations require a finalized purchase document',
          422,
        );
      }
      if (document.partyId !== payment.party_id) {
        throw new AppError(
          'VALIDATION_ERROR',
          'Purchase document party does not match payment party',
          422,
        );
      }

      const alreadyAllocated = await repo.sumAllocatedToPurchaseDocument(
        businessId,
        allocation.purchase_document_id,
      );
      const documentTotal = parseMoney(document.totalAmount);
      if (alreadyAllocated + allocationAmount > documentTotal) {
        throw new AppError(
          'VALIDATION_ERROR',
          'Allocated amount exceeds document remaining balance',
          422,
        );
      }
    }
  }
}
