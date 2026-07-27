import type { Database } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { normalizeMoney, parseMoney } from '../inventory/inventory.utils';
import { PaymentRepository } from '../accounting/payment.repository';
import type { PurchaseDocumentType } from './purchase-document.types';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];

const PAYMENT_MODES = new Set([
  'cash',
  'upi',
  'card',
  'cheque',
  'bank_transfer',
  'other',
]);

export type FinalizePurchasePaymentInput = {
  amount: string;
  paymentMode: string;
  shortPaymentHandling?: 'official_balance' | 'unrecovered' | null;
  shortfallAmount?: string | null;
  paymentDate?: string;
};

export async function recordPurchaseFinalizePayment(
  tx: DbTransaction,
  params: {
    businessId: string;
    documentId: string;
    partyId: string;
    documentTotal: string;
    documentDate: Date;
    documentType?: PurchaseDocumentType;
    userId?: string;
    payment: FinalizePurchasePaymentInput;
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

  if (params.payment.shortPaymentHandling === 'unrecovered') {
    throw new AppError(
      'VALIDATION_ERROR',
      'unrecovered short payments are not supported for purchase finalize',
      422,
    );
  }

  const documentTotal = parseMoney(params.documentTotal);
  if (paymentAmount > documentTotal) {
    throw new AppError(
      'VALIDATION_ERROR',
      'Payment amount exceeds document total',
      422,
    );
  }

  const isReturn = params.documentType === 'purchase_return';

  const paymentDate = params.payment.paymentDate
    ? new Date(params.payment.paymentDate)
    : params.documentDate;

  const repo = new PaymentRepository(tx as unknown as Database);

  const payment = await repo.create({
    businessId: params.businessId,
    partyId: params.partyId,
    direction: isReturn ? 'received' : 'paid',
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
    salesDocumentId: null,
    purchaseDocumentId: params.documentId,
    allocatedAmount: normalizeMoney(paymentAmount),
    createdBy: params.userId ?? null,
    updatedBy: params.userId ?? null,
  });

  await repo.createLedgerEntry({
    businessId: params.businessId,
    partyId: params.partyId,
    entryType: 'payment',
    debit: isReturn ? '0' : params.payment.amount,
    credit: isReturn ? params.payment.amount : '0',
    balanceAfter: params.payment.amount,
    referenceId: payment.id,
    referenceType: 'payments',
    entryDate: paymentDate.toISOString().slice(0, 10),
    description: isReturn ? 'Refund received' : 'Payment paid',
  });

  return {
    paidAmount: params.payment.amount,
    paymentMode: params.payment.paymentMode,
  };
}
