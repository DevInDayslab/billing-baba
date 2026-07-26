import { eq } from 'drizzle-orm';
import { getDb } from '../../db/client';
import { schemaVersion } from '../../db/schema/meta/tables';
import type { DeviceService } from './device.service';
import {
  SYNC_BOOTSTRAP_CHUNK_MAX_BYTES,
  SYNC_MAX_PUSH_BYTES,
  SYNC_MAX_PUSH_MUTATIONS,
  SYNC_MIN_CLIENT_VERSION,
  SYNC_NUMBERING_STRATEGY,
  SYNC_PROTOCOL_VERSION,
  SYNC_PULL_LIMIT_DEFAULT,
  SYNC_PULL_LIMIT_MAX,
  SYNC_SCHEMA_VERSION_FALLBACK,
} from './sync.constants';
import {
  SUPPORTED_ROW_ENTITY_TYPES,
  SUPPORTED_SYNC_COMMANDS,
} from './sync.types';

export class StatusService {
  constructor(private readonly deviceService: DeviceService) {}

  async getStatus(businessId: string, deviceId: string) {
    const serverTime = new Date();
    const schemaVer = await this.readSchemaVersion();
    const device = await this.deviceService.getDevice(businessId, deviceId);

    return {
      protocol_version: SYNC_PROTOCOL_VERSION,
      schema_version: schemaVer,
      min_client_version: SYNC_MIN_CLIENT_VERSION,
      min_protocol_version: SYNC_PROTOCOL_VERSION,
      server_time: serverTime.toISOString(),
      numbering_strategy: SYNC_NUMBERING_STRATEGY,
      compression: ['gzip'],
      max_push_mutations: SYNC_MAX_PUSH_MUTATIONS,
      max_push_bytes: SYNC_MAX_PUSH_BYTES,
      pull_limit_default: SYNC_PULL_LIMIT_DEFAULT,
      pull_limit_max: SYNC_PULL_LIMIT_MAX,
      bootstrap_chunk_max_bytes: SYNC_BOOTSTRAP_CHUNK_MAX_BYTES,
      supported_commands: [...SUPPORTED_SYNC_COMMANDS],
      supported_entities: [...SUPPORTED_ROW_ENTITY_TYPES],
      capabilities: {
        channels: ['http'],
        selective_sync: true,
        websocket: false,
        number_leases: false,
        cloud_backup_ack: false,
      },
      device: device
        ? {
            device_id: device.device_id,
            last_sync_at: device.last_sync_at,
          }
        : {
            device_id: deviceId,
            last_sync_at: null,
          },
    };
  }

  private async readSchemaVersion(): Promise<number> {
    const db = getDb();
    if (!db) {
      return SYNC_SCHEMA_VERSION_FALLBACK;
    }
    try {
      const [row] = await db
        .select()
        .from(schemaVersion)
        .where(eq(schemaVersion.id, 1))
        .limit(1);
      return row?.version ?? SYNC_SCHEMA_VERSION_FALLBACK;
    } catch {
      return SYNC_SCHEMA_VERSION_FALLBACK;
    }
  }
}
