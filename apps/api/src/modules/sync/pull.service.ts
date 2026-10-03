import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import type { BusinessAccessContext } from '../../shared/permissions/collaboration-permission.types';
import { canPermission } from '../../shared/permissions/role-permission-registry';
import { listViewableEntityTypes } from '../../shared/permissions/sync-entity-permissions';
import { canSyncPullEntity } from '../../shared/permissions/sync-permission.guard';
import { RowApplier } from './apply/row-applier';
import { isRegisteredRowEntity } from './apply/row-entities';
import { decodeCursor, encodeCursor, watermarkCursor } from './cursor';
import type { PullQuery } from './sync.schema';

export type PullProcessResult = {
  changes: unknown[];
  next_cursor: string;
  has_more: boolean;
  server_time: string;
};

/** Incremental pull for registered master-data row entities. */
export class PullService {
  constructor(private readonly applier?: RowApplier) {}

  private getApplier(): RowApplier {
    if (this.applier) return this.applier;
    const db = getDb();
    if (!db) {
      throw new AppError('SERVER_BUSY', 'Database is not configured', 429);
    }
    return new RowApplier(db);
  }

  async pull(
    businessId: string,
    query: PullQuery,
    access?: BusinessAccessContext,
  ): Promise<PullProcessResult> {
    const cursor = decodeCursor(query.cursor);
    const cursorUpdatedAt = new Date(cursor.t);
    const entityTypes = query.entity_types
      ?.split(',')
      .map((value) => value.trim())
      .filter(Boolean);

    let registeredFilter = entityTypes?.filter((type) =>
      isRegisteredRowEntity(type),
    );

    if (access) {
      const allowedTypes = listViewableEntityTypes((module) =>
        canPermission(access, module, 'view'),
      );
      if (allowedTypes) {
        registeredFilter = registeredFilter
          ? registeredFilter.filter((type) => allowedTypes.includes(type))
          : allowedTypes;
      }
    }

    const { changes, hasMore } = await this.getApplier().pullChanges({
      businessId,
      entityTypes: registeredFilter,
      cursorUpdatedAt,
      cursorId: cursor.i,
      limit: query.limit,
    });

    const filteredChanges =
      access == null
        ? changes
        : changes.filter((change) =>
            canSyncPullEntity(access, change.entity_type),
          );

    const serverTime = new Date();
    let nextCursor: string;
    if (filteredChanges.length === 0) {
      nextCursor = watermarkCursor(serverTime);
    } else {
      const last = filteredChanges[filteredChanges.length - 1]!;
      nextCursor = encodeCursor({
        t: last.updated_at,
        i: last.entity_id,
      });
    }

    return {
      changes: filteredChanges,
      next_cursor: nextCursor,
      has_more: hasMore,
      server_time: serverTime.toISOString(),
    };
  }
}
