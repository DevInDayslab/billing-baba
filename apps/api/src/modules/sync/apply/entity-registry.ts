import type { SQL } from 'drizzle-orm';
import type { PgColumn, PgTable } from 'drizzle-orm/pg-core';
import type { Database } from '../../../db/client';
import type { SupportedRowEntityType } from '../sync.types';
import { rowToWirePayload, wirePayloadToDomainValues } from './row-serializers';

export type SyncedRowBase = {
  id: string;
  businessId: string;
  syncVersion: number;
  updatedAt: Date;
  deletedAt: Date | null;
  isDeleted: boolean;
  deviceId: string | null;
  createdAt: Date;
};

export type EntityDefinition = {
  entityType: SupportedRowEntityType;
  table: PgTable;
  id: PgColumn;
  businessId: PgColumn;
  syncVersion: PgColumn;
  updatedAt: PgColumn;
  deletedAt: PgColumn;
  isDeleted: PgColumn;
  deviceId: PgColumn;
  createdAt: PgColumn;
  /** Domain columns (camelCase) accepted from client payload. */
  allowedColumns: readonly string[];
  toPayload: (row: Record<string, unknown>) => Record<string, unknown>;
  fromPayload: (payload: Record<string, unknown>) => Record<string, unknown>;
};

export class EntityRegistry {
  private readonly byType = new Map<string, EntityDefinition>();

  register(definition: EntityDefinition): void {
    this.byType.set(definition.entityType, definition);
  }

  get(entityType: string): EntityDefinition | undefined {
    return this.byType.get(entityType);
  }

  isRegistered(entityType: string): boolean {
    return this.byType.has(entityType);
  }

  list(): EntityDefinition[] {
    return [...this.byType.values()];
  }

  listTypes(): string[] {
    return [...this.byType.keys()];
  }
}

export function defineSyncedEntity(input: {
  entityType: SupportedRowEntityType;
  table: PgTable & {
    id: PgColumn;
    businessId: PgColumn;
    syncVersion: PgColumn;
    updatedAt: PgColumn;
    deletedAt: PgColumn;
    isDeleted: PgColumn;
    deviceId: PgColumn;
    createdAt: PgColumn;
  };
  allowedColumns: readonly string[];
}): EntityDefinition {
  const { table, allowedColumns, entityType } = input;
  return {
    entityType,
    table,
    id: table.id,
    businessId: table.businessId,
    syncVersion: table.syncVersion,
    updatedAt: table.updatedAt,
    deletedAt: table.deletedAt,
    isDeleted: table.isDeleted,
    deviceId: table.deviceId,
    createdAt: table.createdAt,
    allowedColumns,
    toPayload: (row) => rowToWirePayload(row),
    fromPayload: (payload) =>
      wirePayloadToDomainValues(payload, allowedColumns),
  };
}

/** Helper type for drizzle where builders that need SQL fragments. */
export type WhereBuilder = (args: {
  businessId: string;
  entityId?: string;
  cursorUpdatedAt?: Date;
  cursorId?: string;
}) => SQL | undefined;

export type Db = Database;
