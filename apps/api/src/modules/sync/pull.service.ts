import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { RowApplier } from './apply/row-applier';
import { syncEntityRegistry } from './apply/entity-registry.register';
import { decodeCursor, encodeCursor, watermarkCursor } from './cursor';
import type { PullQuery } from './sync.schema';

export type PullProcessResult = {
  changes: unknown[];
  next_cursor: string;
  has_more: boolean;
  server_time: string;
};

/**
 * Incremental pull for registered master-data row entities.
 */
export class PullService {
  constructor(private readonly applier?: RowApplier) {}

  private getApplier(): RowApplier {
    if (this.applier) return this.applier;
    const db = getDb();
    if (!db) {
      throw new AppError('SERVER_BUSY', 'Database is not configured', 429);
    }
    return new RowApplier(db, syncEntityRegistry);
  }

  async pull(
    businessId: string,
    query: PullQuery,
  ): Promise<PullProcessResult> {
    const cursor = decodeCursor(query.cursor);
    const cursorUpdatedAt = new Date(cursor.t);
    const entityTypes = query.entity_types
      ?.split(',')
      .map((value) => value.trim())
      .filter(Boolean);

    const registeredFilter = entityTypes?.filter((type) =>
      syncEntityRegistry.isRegistered(type),
    );

    const { changes, hasMore } = await this.getApplier().pullChanges({
      businessId,
      entityTypes: registeredFilter,
      cursorUpdatedAt,
      cursorId: cursor.i,
      limit: query.limit,
    });

    const serverTime = new Date();
    let nextCursor: string;
    if (changes.length === 0) {
      nextCursor = watermarkCursor(serverTime);
    } else {
      const last = changes[changes.length - 1]!;
      nextCursor = encodeCursor({
        t: last.updated_at,
        i: last.entity_id,
      });
    }

    return {
      changes,
      next_cursor: nextCursor,
      has_more: hasMore,
      server_time: serverTime.toISOString(),
    };
  }
}
