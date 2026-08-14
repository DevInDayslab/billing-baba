import { randomUUID } from 'node:crypto';
import type { ApplyOutcome, RowMutationInput } from './sync-apply.types';
import type { RowEntityDef, SyncedRowBase } from './row-entities';

const FINALIZED_STATUSES = new Set(['finalized', 'cancelled', 'converted']);

function readPayloadString(
  payload: Record<string, unknown>,
  key: string,
): string | undefined {
  const value =
    payload[key] ??
    payload[key.replace(/_([a-z])/g, (_, c) => c.toUpperCase())];
  return typeof value === 'string' ? value : undefined;
}

function documentAlreadyFinalizedConflict(
  input: RowMutationInput,
  entityType: string,
): ApplyOutcome {
  return {
    status: 'conflict',
    result: {
      mutation_id: input.mutationId,
      code: 'DOCUMENT_ALREADY_FINALIZED',
      entity_type: entityType,
      entity_id: input.entityId,
      incoming_sync_version: input.baseSyncVersion,
      server_sync_version: input.baseSyncVersion,
      server_payload: null,
      server_updated_at: new Date().toISOString(),
      suggested_resolution: 'retry_with_server_version',
      conflict_id: randomUUID(),
    },
  };
}

function normalizeAllowedDocumentTypes(
  allowed: string | readonly string[],
): Set<string> {
  return new Set(Array.isArray(allowed) ? allowed : [allowed]);
}

export function guardDraftDocumentRow(
  allowedDocumentType: string | readonly string[],
): NonNullable<RowEntityDef['beforeApply']> {
  const allowedTypes = normalizeAllowedDocumentTypes(allowedDocumentType);

  return (input, existing) => {
    const existingRow = existing as Record<string, unknown> | null;
    const existingStatus =
      typeof existingRow?.status === 'string' ? existingRow.status : undefined;

    if (existing && FINALIZED_STATUSES.has(existingStatus ?? '')) {
      return documentAlreadyFinalizedConflict(input, input.entityType);
    }

    if (input.operation === 'delete') {
      return null;
    }

    const documentType = readPayloadString(input.payload, 'document_type');
    if (documentType && !allowedTypes.has(documentType)) {
      const allowedLabel = [...allowedTypes].join(', ');
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'VALIDATION_FAILED',
          message: `Only ${allowedLabel} documents are supported for sync`,
        },
      };
    }

    const status = readPayloadString(input.payload, 'status');
    if (status && status !== 'draft') {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'VALIDATION_FAILED',
          message: 'Only draft documents may be synced as rows',
        },
      };
    }

    return null;
  };
}
