import { and, asc, eq, gt, or } from 'drizzle-orm';
import { randomUUID } from 'node:crypto';
import type { Database } from '../../../db/client';
import { salesDocuments } from '../../../db/schema/sales/tables';
import { purchaseDocuments } from '../../../db/schema/purchases/tables';
import type { ApplyOutcome, RowMutationInput } from './sync-apply.types';
import type { RowEntityDef, SyncedRowBase } from './row-entities';
import { getRowEntity, listRowEntities } from './row-entities';

export type {
  AcceptedRowResult,
  ApplyOutcome,
  ConflictRowResult,
  FailedRowResult,
  RowMutationInput,
} from './sync-apply.types';

export type PullChange = {
  entity_type: string;
  entity_id: string;
  sync_version: number;
  updated_at: string;
  is_deleted: boolean;
  deleted_at: string | null;
  device_id: string | null;
  payload: Record<string, unknown> | null;
};

/**
 * Applies row mutations with optimistic concurrency on sync_version.
 * Soft-deletes only — never hard-deletes.
 */
export class RowApplier {
  constructor(private readonly db: Database) {}

  async apply(input: RowMutationInput): Promise<ApplyOutcome> {
    const definition = getRowEntity(input.entityType);
    if (!definition) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'NOT_IMPLEMENTED',
          message: `Row entity_type '${input.entityType}' is not registered`,
        },
      };
    }

    const existing = await this.findRow(
      definition,
      input.businessId,
      input.entityId,
    );
    if (input.entityType === 'sales_document_lines') {
      const lineGuard = await this.guardSalesLineParentDraft(input, existing);
      if (lineGuard) return lineGuard;
    }
    if (input.entityType === 'purchase_document_lines') {
      const lineGuard = await this.guardPurchaseLineParentDraft(
        input,
        existing,
      );
      if (lineGuard) return lineGuard;
    }
    if (definition.beforeApply) {
      const guardOutcome = await definition.beforeApply(input, existing);
      if (guardOutcome) return guardOutcome;
    }

    switch (input.operation) {
      case 'create':
        return this.applyCreate(definition, input, existing);
      case 'update':
        return this.applyUpdate(definition, input, existing);
      case 'delete':
        return this.applyDelete(definition, input, existing);
    }
  }

  async pullChanges(input: {
    businessId: string;
    entityTypes?: string[];
    cursorUpdatedAt: Date;
    cursorId: string;
    limit: number;
  }): Promise<{ changes: PullChange[]; hasMore: boolean }> {
    const definitions = listRowEntities().filter((def) => {
      if (!input.entityTypes || input.entityTypes.length === 0) return true;
      return input.entityTypes.includes(def.entityType);
    });

    const perEntityLimit = input.limit + 1;
    const collected: PullChange[] = [];

    for (const definition of definitions) {
      const rows = await this.listSince(
        definition,
        input.businessId,
        input.cursorUpdatedAt,
        input.cursorId,
        perEntityLimit,
      );
      for (const row of rows) {
        collected.push(this.toPullChange(definition, row));
      }
    }

    collected.sort((a, b) => {
      const t = a.updated_at.localeCompare(b.updated_at);
      if (t !== 0) return t;
      return a.entity_id.localeCompare(b.entity_id);
    });

    const hasMore = collected.length > input.limit;
    return {
      changes: collected.slice(0, input.limit),
      hasMore,
    };
  }

  private async applyCreate(
    definition: RowEntityDef,
    input: RowMutationInput,
    existing: SyncedRowBase | null,
  ): Promise<ApplyOutcome> {
    if (existing && !existing.isDeleted) {
      return this.conflict(input, existing, definition);
    }
    if (existing?.isDeleted) {
      // Revive only when base matches the tombstone version.
      if (input.baseSyncVersion !== existing.syncVersion) {
        return this.conflict(input, existing, definition);
      }
      return this.writeUpdate(definition, input, existing, {
        softDelete: false,
      });
    }

    if (input.baseSyncVersion !== 0) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'VALIDATION_FAILED',
          message: 'create requires base_sync_version 0',
        },
      };
    }

    const domain = definition.fromPayload(input.payload);
    const now = new Date();
    const syncVersion = 1;

    try {
      await this.db.insert(definition.table).values({
        ...domain,
        id: input.entityId,
        businessId: input.businessId,
        syncVersion,
        deviceId: input.deviceId,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        deletedAt: null,
      } as never);
    } catch (error) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'VALIDATION_FAILED',
          message: error instanceof Error ? error.message : 'Insert failed',
        },
      };
    }

    return {
      status: 'accepted',
      result: {
        mutation_id: input.mutationId,
        kind: 'row',
        entity_type: input.entityType,
        entity_id: input.entityId,
        sync_version: syncVersion,
        server_updated_at: now.toISOString(),
      },
    };
  }

  private async applyUpdate(
    definition: RowEntityDef,
    input: RowMutationInput,
    existing: SyncedRowBase | null,
  ): Promise<ApplyOutcome> {
    if (!existing) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'NOT_FOUND',
          message: 'Row not found',
        },
      };
    }
    if (input.baseSyncVersion !== existing.syncVersion) {
      return this.conflict(input, existing, definition);
    }
    return this.writeUpdate(definition, input, existing, { softDelete: false });
  }

  private async applyDelete(
    definition: RowEntityDef,
    input: RowMutationInput,
    existing: SyncedRowBase | null,
  ): Promise<ApplyOutcome> {
    if (!existing) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'NOT_FOUND',
          message: 'Row not found',
        },
      };
    }
    if (existing.isDeleted) {
      // Idempotent soft-delete when version matches.
      if (input.baseSyncVersion !== existing.syncVersion) {
        return this.conflict(input, existing, definition);
      }
      return {
        status: 'accepted',
        result: {
          mutation_id: input.mutationId,
          kind: 'row',
          entity_type: input.entityType,
          entity_id: input.entityId,
          sync_version: existing.syncVersion,
          server_updated_at: existing.updatedAt.toISOString(),
        },
      };
    }
    if (input.baseSyncVersion !== existing.syncVersion) {
      return this.conflict(input, existing, definition);
    }
    return this.writeUpdate(definition, input, existing, { softDelete: true });
  }

  private async writeUpdate(
    definition: RowEntityDef,
    input: RowMutationInput,
    existing: SyncedRowBase,
    options: { softDelete: boolean },
  ): Promise<ApplyOutcome> {
    const domain = options.softDelete
      ? {}
      : definition.fromPayload(input.payload);
    const now = new Date();
    const syncVersion = existing.syncVersion + 1;

    const patch = {
      ...domain,
      syncVersion,
      deviceId: input.deviceId,
      updatedAt: now,
      ...(options.softDelete
        ? { isDeleted: true, deletedAt: now }
        : { isDeleted: false, deletedAt: null }),
    };

    await this.db
      .update(definition.table)
      .set(patch as never)
      .where(
        and(
          eq(definition.businessId, input.businessId),
          eq(definition.id, input.entityId),
        ),
      );

    return {
      status: 'accepted',
      result: {
        mutation_id: input.mutationId,
        kind: 'row',
        entity_type: input.entityType,
        entity_id: input.entityId,
        sync_version: syncVersion,
        server_updated_at: now.toISOString(),
      },
    };
  }

  private conflict(
    input: RowMutationInput,
    existing: SyncedRowBase,
    definition: RowEntityDef,
  ): ApplyOutcome {
    const row = existing as unknown as Record<string, unknown>;
    return {
      status: 'conflict',
      result: {
        mutation_id: input.mutationId,
        code: 'CONFLICT',
        entity_type: input.entityType,
        entity_id: input.entityId,
        incoming_sync_version: input.baseSyncVersion,
        server_sync_version: existing.syncVersion,
        server_payload: existing.isDeleted ? null : definition.toPayload(row),
        server_updated_at: existing.updatedAt.toISOString(),
        suggested_resolution: 'retry_with_server_version',
        conflict_id: randomUUID(),
      },
    };
  }

  private async findRow(
    definition: RowEntityDef,
    businessId: string,
    entityId: string,
  ): Promise<SyncedRowBase | null> {
    const rows = await this.db
      .select()
      .from(definition.table)
      .where(
        and(eq(definition.businessId, businessId), eq(definition.id, entityId)),
      )
      .limit(1);

    const row = rows[0] as SyncedRowBase | undefined;
    return row ?? null;
  }

  private async listSince(
    definition: RowEntityDef,
    businessId: string,
    cursorUpdatedAt: Date,
    cursorId: string,
    limit: number,
  ): Promise<Array<SyncedRowBase & Record<string, unknown>>> {
    const rows = await this.db
      .select()
      .from(definition.table)
      .where(
        and(
          eq(definition.businessId, businessId),
          or(
            gt(definition.updatedAt, cursorUpdatedAt),
            and(
              eq(definition.updatedAt, cursorUpdatedAt),
              gt(definition.id, cursorId),
            ),
          ),
        ),
      )
      .orderBy(asc(definition.updatedAt), asc(definition.id))
      .limit(limit);

    return rows as Array<SyncedRowBase & Record<string, unknown>>;
  }

  private async guardSalesLineParentDraft(
    input: RowMutationInput,
    existing: SyncedRowBase | null,
  ): Promise<ApplyOutcome | null> {
    const payloadParentId = input.payload.sales_document_id;
    const existingParentId =
      existing && 'salesDocumentId' in existing
        ? (existing as { salesDocumentId?: string }).salesDocumentId
        : undefined;
    const parentId =
      typeof payloadParentId === 'string' ? payloadParentId : existingParentId;

    if (!parentId) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'VALIDATION_FAILED',
          message: 'sales_document_id is required for line mutations',
        },
      };
    }

    const [parent] = await this.db
      .select({
        status: salesDocuments.status,
        documentType: salesDocuments.documentType,
      })
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.id, parentId),
          eq(salesDocuments.businessId, input.businessId),
          eq(salesDocuments.isDeleted, false),
        ),
      )
      .limit(1);

    if (!parent) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'NOT_FOUND',
          message: 'Parent sales document not found',
        },
      };
    }

    if (
      parent.documentType !== 'tax_invoice' &&
      parent.documentType !== 'sales_return'
    ) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'VALIDATION_FAILED',
          message: 'Only tax_invoice and sales_return line sync is supported',
        },
      };
    }

    if (parent.status !== 'draft') {
      return {
        status: 'conflict',
        result: {
          mutation_id: input.mutationId,
          code: 'DOCUMENT_ALREADY_FINALIZED',
          entity_type: input.entityType,
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

    return null;
  }

  private async guardPurchaseLineParentDraft(
    input: RowMutationInput,
    existing: SyncedRowBase | null,
  ): Promise<ApplyOutcome | null> {
    const payloadParentId = input.payload.purchase_document_id;
    const existingParentId =
      existing && 'purchaseDocumentId' in existing
        ? (existing as { purchaseDocumentId?: string }).purchaseDocumentId
        : undefined;
    const parentId =
      typeof payloadParentId === 'string' ? payloadParentId : existingParentId;

    if (!parentId) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'VALIDATION_FAILED',
          message: 'purchase_document_id is required for line mutations',
        },
      };
    }

    const [parent] = await this.db
      .select({
        status: purchaseDocuments.status,
        documentType: purchaseDocuments.documentType,
      })
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.id, parentId),
          eq(purchaseDocuments.businessId, input.businessId),
          eq(purchaseDocuments.isDeleted, false),
        ),
      )
      .limit(1);

    if (!parent) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'NOT_FOUND',
          message: 'Parent purchase document not found',
        },
      };
    }

    if (
      parent.documentType !== 'purchase_bill' &&
      parent.documentType !== 'purchase_return'
    ) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'VALIDATION_FAILED',
          message:
            'Only purchase_bill and purchase_return line sync is supported',
        },
      };
    }

    if (parent.status !== 'draft') {
      return {
        status: 'conflict',
        result: {
          mutation_id: input.mutationId,
          code: 'DOCUMENT_ALREADY_FINALIZED',
          entity_type: input.entityType,
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

    return null;
  }

  private toPullChange(
    definition: RowEntityDef,
    row: SyncedRowBase & Record<string, unknown>,
  ): PullChange {
    return {
      entity_type: definition.entityType,
      entity_id: row.id,
      sync_version: row.syncVersion,
      updated_at: row.updatedAt.toISOString(),
      is_deleted: row.isDeleted,
      deleted_at: row.deletedAt?.toISOString() ?? null,
      device_id: row.deviceId,
      payload: row.isDeleted ? null : definition.toPayload(row),
    };
  }
}
