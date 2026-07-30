import type { Database } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { normalizeMoney, parseMoney } from '../inventory/inventory.utils';
import { PaymentRepository } from '../accounting/payment.repository';
import { HiddenLedgerService } from '../hidden-ledger/hidden-ledger.service';
import type { SalesDocumentType } from './sales-document.types';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];

const PAYMENT_MODES = new Set([
  'cash',
  'upi',
  'card',
  'cheque',
  'bank_transfer',
  'other',
]);

export type FinalizeSalePaymentInput = {
  amount: string;
  paymentMode: string;
  shortPaymentHandling?: 'official_balance' | 'unrecovered' | null;
  shortfallAmount?: string | null;
  paymentDate?: string;
};

export async function recordSaleFinalizePayment(
  tx: DbTransaction,
  params: {
    businessId: string;
    documentId: string;
    partyId: string;
    documentTotal: string;
    documentDate: Date;
    documentType?: SalesDocumentType;
    userId?: string;
    payment: FinalizeSalePaymentInput;
  },
): Promise<{ paidAmount: string; paymentMode: string }> {
  const paymentAmount = parseMoney(params.payment.amount);
  if (paymentAmount <= 0) {
    throw new AppError(
      'VALIDATION_ERROR',
      'Payment amount must be greater than zero',
      422,
    );
  }

  if (!PAYMENT_MODES.has(params.payment.paymentMode)) {
    throw new AppError('VALIDATION_ERROR', 'Invalid payment mode', 422);
  }

  const documentTotal = parseMoney(params.documentTotal);
  if (paymentAmount > documentTotal) {
    throw new AppError(
      'VALIDATION_ERROR',
      'Payment amount exceeds document total',
      422,
    );
  }

  const isReturn = params.documentType === 'sales_return';
  const isHiddenLedgerRoute =
    !isReturn && params.payment.shortPaymentHandling === 'unrecovered';
  const shortfallAmount = isHiddenLedgerRoute
    ? parseMoney(params.payment.shortfallAmount ?? '0')
    : 0;

  if (isHiddenLedgerRoute && shortfallAmount <= 0) {
    throw new AppError(
      'VALIDATION_ERROR',
      'shortfall_amount is required when short_payment_handling is unrecovered',
      422,
    );
  }

  if (isReturn && params.payment.shortPaymentHandling === 'unrecovered') {
    throw new AppError(
      'VALIDATION_ERROR',
      'unrecovered short payments are not supported for sales return finalize',
      422,
    );
  }

  const allocatedAmount = isHiddenLedgerRoute
    ? documentTotal
    : paymentAmount;

  const paymentDate = params.payment.paymentDate
    ? new Date(params.payment.paymentDate)
    : params.documentDate;

  const repo = new PaymentRepository(tx as unknown as Database);

  const payment = await repo.create({
    businessId: params.businessId,
    partyId: params.partyId,
    direction: isReturn ? 'paid' : 'received',
    amount: params.payment.amount,
    discountAmount: '0',
    paymentMode: params.payment.paymentMode as
      | 'cash'
      | 'upi'
      | 'card'
      | 'cheque'
      | 'bank_transfer'
      | 'other',
    paymentDate,
    referenceNumber: null,
    notes: null,
    shortPaymentHandling: params.payment.shortPaymentHandling ?? null,
    source: 'document_finalize',
    createdBy: params.userId ?? null,
    updatedBy: params.userId ?? null,
  });

  await repo.createAllocation({
    businessId: params.businessId,
    paymentId: payment.id,
    salesDocumentId: params.documentId,
    purchaseDocumentId: null,
    allocatedAmount: normalizeMoney(allocatedAmount),
    createdBy: params.userId ?? null,
    updatedBy: params.userId ?? null,
  });

  await repo.createLedgerEntry({
    businessId: params.businessId,
    partyId: params.partyId,
    entryType: 'payment',
    debit: isReturn ? params.payment.amount : '0',
    credit: isReturn ? '0' : params.payment.amount,
    balanceAfter: params.payment.amount,
    referenceId: payment.id,
    referenceType: 'payments',
    entryDate: paymentDate.toISOString().slice(0, 10),
    description: isReturn ? 'Refund paid' : 'Payment received',
  });

  if (isHiddenLedgerRoute && shortfallAmount > 0) {
    const alreadyAllocated = await repo.sumAllocatedToSalesDocument(
      params.businessId,
      params.documentId,
    );
    const expectedShortfall = documentTotal - alreadyAllocated - paymentAmount;

    if (Math.abs(expectedShortfall - shortfallAmount) > 0.0001) {
      throw new AppError(
        'VALIDATION_ERROR',
        'shortfall_amount does not match invoice shortfall',
        422,
      );
    }

    const hiddenLedgerService = new HiddenLedgerService();
    const entry = await hiddenLedgerService.recordShortPaymentEntry({
      businessId: params.businessId,
      partyId: params.partyId,
      salesDocumentId: params.documentId,
      shortfallAmount: normalizeMoney(shortfallAmount),
      userId: params.userId ?? null,
      db: tx as unknown as Database,
    });

    await repo.createLedgerEntry({
      businessId: params.businessId,
      partyId: params.partyId,
      entryType: 'payment',
      debit: '0',
      credit: normalizeMoney(shortfallAmount),
      balanceAfter: normalizeMoney(shortfallAmount),
      referenceId: entry.id,
      referenceType: 'hidden_ledger_entries',
      entryDate: paymentDate.toISOString().slice(0, 10),
      description: 'Hidden ledger shortfall settlement',
    });
  }

  return {
    paidAmount: params.payment.amount,
    paymentMode: params.payment.paymentMode,
  };
}
