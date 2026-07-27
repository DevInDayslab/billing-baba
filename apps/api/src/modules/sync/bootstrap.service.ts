import { watermarkCursor } from './cursor';
import {
  SYNC_PROTOCOL_VERSION,
  SYNC_SCHEMA_VERSION_FALLBACK,
} from './sync.constants';
import type { BootstrapBody } from './sync.schema';

/**
 * MVP bootstrap: no chunk sessions.
 * Client should pull from epoch; this endpoint only returns an initial cursor.
 */
export class BootstrapService {
  start(
    _businessId: string,
    body: BootstrapBody,
  ): {
    initial_cursor: string;
    schema_version: number;
    protocol_version: number;
    server_time: string;
    estimated_rows: number;
  } {
    const serverTime = new Date();
    return {
      initial_cursor: watermarkCursor(serverTime),
      schema_version: body.schema_version || SYNC_SCHEMA_VERSION_FALLBACK,
      protocol_version: SYNC_PROTOCOL_VERSION,
      server_time: serverTime.toISOString(),
      estimated_rows: 0,
    };
  }
}
