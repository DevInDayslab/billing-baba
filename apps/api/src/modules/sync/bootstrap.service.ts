import { randomUUID } from 'node:crypto';
import { watermarkCursor } from './cursor';
import {
  SYNC_BOOTSTRAP_TTL_MS,
  SYNC_PROTOCOL_VERSION,
  SYNC_SCHEMA_VERSION_FALLBACK,
} from './sync.constants';
import { syncBootstrapExpired, syncValidationFailed } from './sync.errors';
import type { BootstrapBody } from './sync.schema';

type BootstrapSession = {
  businessId: string;
  deviceId: string;
  schemaVersion: number;
  chunkCount: number;
  expiresAt: Date;
  createdAt: Date;
};

/** In-memory bootstrap jobs — replace with durable store in a later phase. */
const bootstrapSessions = new Map<string, BootstrapSession>();

export class BootstrapService {
  start(
    businessId: string,
    body: BootstrapBody,
  ): {
    bootstrap_id: string;
    business_id: string;
    schema_version: number;
    chunk_count: number;
    compression: string[];
    expires_at: string;
    estimated_rows: number;
  } {
    const bootstrapId = randomUUID();
    const now = new Date();
    const expiresAt = new Date(now.getTime() + SYNC_BOOTSTRAP_TTL_MS);

    bootstrapSessions.set(bootstrapId, {
      businessId,
      deviceId: body.device_id,
      schemaVersion: body.schema_version,
      chunkCount: 1,
      expiresAt,
      createdAt: now,
    });

    return {
      bootstrap_id: bootstrapId,
      business_id: businessId,
      schema_version: body.schema_version,
      chunk_count: 1,
      compression: ['gzip'],
      expires_at: expiresAt.toISOString(),
      estimated_rows: 0,
    };
  }

  getChunk(
    businessId: string,
    bootstrapId: string,
    chunkIndex: number,
    page: number,
  ) {
    const session = bootstrapSessions.get(bootstrapId);
    if (!session) {
      throw syncBootstrapExpired('Unknown bootstrap_id');
    }
    if (session.businessId !== businessId) {
      throw syncValidationFailed('Bootstrap does not belong to this business');
    }
    if (session.expiresAt.getTime() < Date.now()) {
      bootstrapSessions.delete(bootstrapId);
      throw syncBootstrapExpired();
    }
    if (chunkIndex < 0 || chunkIndex >= session.chunkCount) {
      throw syncValidationFailed('chunk_index out of range', {
        chunk_index: [`Must be between 0 and ${session.chunkCount - 1}`],
      });
    }
    if (page !== 1) {
      throw syncValidationFailed(
        'page out of range for placeholder bootstrap',
        {
          page: ['Only page 1 is available in infrastructure phase'],
        },
      );
    }

    const serverTime = new Date();
    return {
      bootstrap_id: bootstrapId,
      chunk_index: chunkIndex,
      chunk_count: session.chunkCount,
      entity_type: '_bootstrap_complete',
      page: 1,
      has_more_pages: false,
      rows: [] as unknown[],
      tombstones: [] as unknown[],
      initial_cursor: watermarkCursor(serverTime),
      server_time: serverTime.toISOString(),
      protocol_version: SYNC_PROTOCOL_VERSION,
      schema_version: session.schemaVersion || SYNC_SCHEMA_VERSION_FALLBACK,
    };
  }
}

/** Test helper */
export function clearBootstrapSessionsForTests(): void {
  bootstrapSessions.clear();
}
