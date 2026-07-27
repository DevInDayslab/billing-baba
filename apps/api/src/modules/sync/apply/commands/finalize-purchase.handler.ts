import { eq } from 'drizzle-orm';
import { randomUUID } from 'node:crypto';
import type { Database } from '../../../../db/client';
import { purchaseDocuments } from '../../../../db/schema/purchases/tables';
import { AppError } from '../../../../shared/errors/app-error';
import { PurchaseDocumentRepository } from '../../../purchases/purchase-document.repository';
import { finalizePurchaseDocument } from '../../../purchases/purchase-finalize.service';
import type {
  CommandApplyOutcome,
  CommandHandler,
  CommandMutationInput,
} from './command.types';

function isLocalDocumentNumber(value: string | null | undefined): boolean {
  return value != null && value.startsWith('LOCAL-');
}

export const finalizePurchaseHandler: CommandHandler = async (db, input) => {
  const documentId = input.payload.document_id;
  if (typeof documentId !== 'string' || documentId.length === 0) {
    return validationError(input, 'document_id is required');
  }

  const localDocumentNumber = input.payload.local_document_number;
  const godownId =
    typeof input.payload.godown_id === 'string'
      ? input.payload.godown_id
      : undefined;

  const repository = new PurchaseDocumentRepository(db);
  const document = await repository.findRowById(input.businessId, documentId);

  if (!document) {
    return notFoundError(input, 'Purchase document not found');
  }

  if (document.documentType !== 'purchase_bill') {
    return validationError(
      input,
      'finalize_purchase only supports purchase_bill documents in Phase 2',
    );
  }

  if (document.status !== 'draft') {
    return documentAlreadyFinalized(input);
  }

  const localNumber =
    typeof localDocumentNumber === 'string' ? localDocumentNumber : null;

  if (
    isLocalDocumentNumber(document.documentNumber) ||
    isLocalDocumentNumber(localNumber)
  ) {
    await db
      .update(purchaseDocuments)
      .set({ documentNumber: null })
      .where(eq(purchaseDocuments.id, documentId));
  }

  try {
    const finalized = await finalizePurchaseDocument(db, repository, {
      businessId: input.businessId,
      documentId,
      userId: input.userId,
      godownId,
    });

    const serverDocumentNumber = finalized.documentNumber;
    const result: Record<string, unknown> = {
      document_id: documentId,
      status: 'finalized',
    };

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
    if (
      error.code === 'DOCUMENT_NOT_EDITABLE' ||
      error.statusCode === 409
    ) {
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
