import { randomUUID } from 'node:crypto';
import { eq } from 'drizzle-orm';
import type { Database } from '../../../../db/client';
import { salesDocuments } from '../../../../db/schema/sales/tables';
import { AppError } from '../../../../shared/errors/app-error';
import {
  ensureWalkInParty,
  walkInPartyIdForBusiness,
} from '../../../../shared/parties/walk-in-party';
import { SalesDocumentRepository } from '../../../sales/sales-document.repository';
import {
  finalizeSalePaymentBodySchema,
  finalizeSalePaymentLineSchema,
} from '../../../sales/sales-document.schema';
import { finalizeSalesDocument } from '../../../sales/sales-finalize.service';
import type { FinalizeSalePaymentInput } from '../../../sales/sales-finalize-payment.service';
import type {
  CommandApplyOutcome,
  CommandHandler,
  CommandMutationInput,
} from './command.types';

function isLocalDocumentNumber(value: string | null | undefined): boolean {
  return value != null && value.startsWith('LOCAL-');
}

function parseFinalizePayment(
  payload: Record<string, unknown>,
): FinalizeSalePaymentInput | undefined {
  const paymentBlock = payload.payment;
  if (!paymentBlock || typeof paymentBlock !== 'object') {
    return undefined;
  }

  const parsed = finalizeSalePaymentBodySchema.safeParse(paymentBlock);
  if (!parsed.success) {
    throw new AppError(
      'VALIDATION_ERROR',
      parsed.error.issues[0]?.message ?? 'Invalid payment payload',
      422,
    );
  }

  return {
    amount: parsed.data.amount,
    paymentMode: parsed.data.payment_mode,
    bankAccountId: parsed.data.bank_account_id ?? null,
    shortPaymentHandling: parsed.data.short_payment_handling ?? null,
    shortfallAmount: parsed.data.shortfall_amount ?? null,
    paymentDate: parsed.data.payment_date,
  };
}

function parseFinalizePayments(
  payload: Record<string, unknown>,
): FinalizeSalePaymentInput[] | undefined {
  const block = payload.payments;
  if (!Array.isArray(block) || block.length === 0) {
    return undefined;
  }
  const lines: FinalizeSalePaymentInput[] = [];
  for (const entry of block) {
    const parsed = finalizeSalePaymentLineSchema.safeParse(entry);
    if (!parsed.success) {
      throw new AppError(
        'VALIDATION_ERROR',
        parsed.error.issues[0]?.message ?? 'Invalid payments payload',
        422,
      );
    }
    lines.push({
      amount: parsed.data.amount,
      paymentMode: parsed.data.payment_mode,
      bankAccountId: parsed.data.bank_account_id ?? null,
      paymentDate: parsed.data.payment_date,
    });
  }
  return lines;
}

export const finalizeSaleHandler: CommandHandler = async (db, input) => {
  const documentId = input.payload.document_id;
  if (typeof documentId !== 'string' || documentId.length === 0) {
    return validationError(input, 'document_id is required');
  }

  const localDocumentNumber = input.payload.local_document_number;
  const godownId =
    typeof input.payload.godown_id === 'string'
      ? input.payload.godown_id
      : undefined;

  let payment: FinalizeSalePaymentInput | undefined;
  let payments: FinalizeSalePaymentInput[] | undefined;
  try {
    payment = parseFinalizePayment(input.payload);
    payments = parseFinalizePayments(input.payload);
  } catch (error) {
    if (error instanceof AppError) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: error.code,
          message: error.message,
        },
      };
    }
    throw error;
  }

  const repository = new SalesDocumentRepository(db);
  const document = await repository.findRowById(input.businessId, documentId);

  if (!document) {
    return notFoundError(input, 'Sales document not found');
  }

  if (
    document.documentType !== 'tax_invoice' &&
    document.documentType !== 'pos'
  ) {
    return validationError(
      input,
      'finalize_sale only supports tax_invoice and pos documents',
    );
  }

  if (document.status !== 'draft') {
    return documentAlreadyFinalized(input);
  }

  await ensureWalkInParty(
    db,
    input.businessId,
    walkInPartyIdForBusiness(input.businessId),
  );
  if (document.partyId) {
    await ensureWalkInParty(db, input.businessId, document.partyId);
  }

  const localNumber =
    typeof localDocumentNumber === 'string' ? localDocumentNumber : null;

  if (
    isLocalDocumentNumber(document.documentNumber) ||
    isLocalDocumentNumber(localNumber)
  ) {
    await db
      .update(salesDocuments)
      .set({ documentNumber: null })
      .where(eq(salesDocuments.id, documentId));
  }

  try {
    const finalized = await finalizeSalesDocument(db, repository, {
      businessId: input.businessId,
      documentId,
      userId: input.userId,
      godownId,
      payment: payments?.length ? undefined : payment,
      payments,
    });

    const serverDocumentNumber = finalized.documentNumber;
    const result: Record<string, unknown> = {
      document_id: documentId,
      status: 'finalized',
      paid_amount: finalized.paidAmount,
    };

    if (finalized.paymentMode) {
      result.payment_mode = finalized.paymentMode;
    }

    if (localNumber && serverDocumentNumber) {
      result.document_number_remap = {
        local_document_number: localNumber,
        server_document_number: serverDocumentNumber,
      };
    } else if (serverDocumentNumber) {
      result.document_number = serverDocumentNumber;
    }

    const updated = await repository.findRowById(input.businessId, documentId);
    const syncVersion = updated?.syncVersion ?? document.syncVersion + 1;

    return {
      status: 'accepted',
      result: {
        mutation_id: input.mutationId,
        kind: 'command',
        command: input.command,
        command_id: input.commandId,
        sync_version: syncVersion,
        server_updated_at: new Date().toISOString(),
        result,
      },
    };
  } catch (error) {
    return mapFinalizeError(input, error);
  }
};

function validationError(
  input: CommandMutationInput,
  message: string,
): CommandApplyOutcome {
  return {
    status: 'error',
    result: {
      mutation_id: input.mutationId,
      code: 'VALIDATION_FAILED',
      message,
    },
  };
}

function notFoundError(
  input: CommandMutationInput,
  message: string,
): CommandApplyOutcome {
  return {
    status: 'error',
    result: {
      mutation_id: input.mutationId,
      code: 'NOT_FOUND',
      message,
    },
  };
}

function documentAlreadyFinalized(
  input: CommandMutationInput,
): CommandApplyOutcome {
  return {
    status: 'conflict',
    result: {
      mutation_id: input.mutationId,
      command: input.command,
      command_id: input.commandId,
      code: 'DOCUMENT_ALREADY_FINALIZED',
      message: 'Document is already finalized and cannot be modified',
      conflict_id: randomUUID(),
    },
  };
}

function mapFinalizeError(
  input: CommandMutationInput,
  error: unknown,
): CommandApplyOutcome {
  if (error instanceof AppError) {
    if (error.code === 'DOCUMENT_NOT_EDITABLE' || error.statusCode === 409) {
      return documentAlreadyFinalized(input);
    }
    return {
      status: 'error',
      result: {
        mutation_id: input.mutationId,
        code: error.code,
        message: error.message,
        details: error.errors ?? undefined,
      },
    };
  }

  return {
    status: 'error',
    result: {
      mutation_id: input.mutationId,
      code: 'INTERNAL_ERROR',
      message: error instanceof Error ? error.message : 'Finalize failed',
    },
  };
}
