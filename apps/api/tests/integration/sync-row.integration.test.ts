import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import { randomUUID } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import { encodeCursor, watermarkCursor } from '../../src/modules/sync/cursor';
import { ZERO_UUID } from '../../src/modules/sync/sync.constants';
import {
  createTestApp,
  jsonAuthHeaders,
  login,
  uniqueSuffix,
} from '../helpers/app';
import { canRunDbTests, INTEGRATION_TIMEOUT_MS } from '../helpers/env';

function syncHeaders(token: string, deviceId: string): Record<string, string> {
  return {
    ...jsonAuthHeaders(token),
    'x-device-id': deviceId,
    'x-app-version': '1.4.0',
    'x-sync-protocol-version': '1',
  };
}

describe.skipIf(!canRunDbTests)('Sync row push/pull integration', () => {
  let app: FastifyInstance;
  let token: string;
  let deviceId: string;
  let syncPrefix: string;
  const suffix = uniqueSuffix();

  beforeAll(async () => {
    app = await createTestApp();
    token = await login(app);
    const config = loadAppConfig();
    syncPrefix = `${config.apiPrefix}/sync`;
    deviceId = randomUUID();

    const registered = await app.inject({
      method: 'POST',
      url: `${syncPrefix}/devices`,
      headers: syncHeaders(token, deviceId),
      payload: {
        device_id: deviceId,
        platform: 'macos',
        app_version: '1.4.0',
        device_name: `sync-test-${suffix}`,
      },
    });
    expect(registered.statusCode).toBe(200);
  });

  afterAll(async () => {
    await app.close();
  });

  test(
    'create → pull → update → conflict → delete → duplicate replay → command NOT_IMPLEMENTED',
    async () => {
      const partyId = randomUUID();
      const mutationCreate = randomUUID();
      const batch1 = randomUUID();

      const createPush = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: batch1,
          mutations: [
            {
              mutation_id: mutationCreate,
              kind: 'row',
              entity_type: 'parties',
              entity_id: partyId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                name: `Sync Party ${suffix}`,
                party_type: 'customer',
                state_code: '27',
                mobile: `9${String(Date.now()).slice(-9)}`,
              },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(createPush.statusCode).toBe(200);
      const createBody = createPush.json() as {
        data: {
          accepted: Array<{ sync_version: number; entity_id: string }>;
          conflicts: unknown[];
          errors: unknown[];
        };
      };
      expect(createBody.data.errors).toEqual([]);
      expect(createBody.data.conflicts).toEqual([]);
      expect(createBody.data.accepted).toHaveLength(1);
      expect(createBody.data.accepted[0]?.sync_version).toBe(1);
      expect(createBody.data.accepted[0]?.entity_id).toBe(partyId);

      const pullCursor = encodeCursor({
        t: new Date(Date.now() - 60_000).toISOString(),
        i: ZERO_UUID,
      });
      const pull1 = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(pullCursor)}&entity_types=parties&limit=200`,
        headers: syncHeaders(token, deviceId),
      });
      expect(pull1.statusCode).toBe(200);
      const pull1Body = pull1.json() as {
        data: {
          changes: Array<{
            entity_id: string;
            sync_version: number;
            is_deleted: boolean;
            payload: Record<string, unknown> | null;
          }>;
          next_cursor: string;
        };
      };
      const createdChange = pull1Body.data.changes.find(
        (c) => c.entity_id === partyId,
      );
      expect(createdChange).toBeTruthy();
      expect(createdChange?.sync_version).toBe(1);
      expect(createdChange?.is_deleted).toBe(false);
      expect(createdChange?.payload?.name).toBe(`Sync Party ${suffix}`);

      const mutationUpdate = randomUUID();
      const updateOk = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: mutationUpdate,
              kind: 'row',
              entity_type: 'parties',
              entity_id: partyId,
              operation: 'update',
              base_sync_version: 1,
              payload: { notes: 'updated via sync' },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(updateOk.statusCode).toBe(200);
      const updateOkBody = updateOk.json() as {
        data: { accepted: Array<{ sync_version: number }> };
      };
      expect(updateOkBody.data.accepted[0]?.sync_version).toBe(2);

      const conflictPush = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'parties',
              entity_id: partyId,
              operation: 'update',
              base_sync_version: 1,
              payload: { notes: 'stale' },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(conflictPush.statusCode).toBe(200);
      const conflictBody = conflictPush.json() as {
        data: {
          conflicts: Array<{
            code: string;
            server_sync_version: number;
          }>;
        };
      };
      expect(conflictBody.data.conflicts).toHaveLength(1);
      expect(conflictBody.data.conflicts[0]?.code).toBe('CONFLICT');
      expect(conflictBody.data.conflicts[0]?.server_sync_version).toBe(2);

      const mutationDelete = randomUUID();
      const deletePush = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: mutationDelete,
              kind: 'row',
              entity_type: 'parties',
              entity_id: partyId,
              operation: 'delete',
              base_sync_version: 2,
              payload: {},
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(deletePush.statusCode).toBe(200);
      const deleteBody = deletePush.json() as {
        data: { accepted: Array<{ sync_version: number }> };
      };
      expect(deleteBody.data.accepted[0]?.sync_version).toBe(3);

      const pullAfterDelete = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(pullCursor)}&entity_types=parties&limit=100`,
        headers: syncHeaders(token, deviceId),
      });
      const pullDeleteBody = pullAfterDelete.json() as {
        data: {
          changes: Array<{
            entity_id: string;
            is_deleted: boolean;
            payload: unknown;
            sync_version: number;
          }>;
        };
      };
      const tombstone = pullDeleteBody.data.changes.find(
        (c) => c.entity_id === partyId && c.is_deleted,
      );
      expect(tombstone).toBeTruthy();
      expect(tombstone?.payload).toBeNull();
      expect(tombstone?.sync_version).toBe(3);

      const replay = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: mutationCreate,
              kind: 'row',
              entity_type: 'parties',
              entity_id: partyId,
              operation: 'create',
              base_sync_version: 0,
              payload: { name: 'should not re-apply' },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(replay.statusCode).toBe(200);
      const replayBody = replay.json() as {
        data: {
          replayed: Array<{ mutation_id: string; idempotent_replay: boolean }>;
          accepted: unknown[];
        };
      };
      expect(replayBody.data.accepted).toEqual([]);
      expect(replayBody.data.replayed).toHaveLength(1);
      expect(replayBody.data.replayed[0]?.mutation_id).toBe(mutationCreate);
      expect(replayBody.data.replayed[0]?.idempotent_replay).toBe(true);

      const commandPush = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: randomUUID(),
              kind: 'command',
              command: 'finalize_sale',
              command_id: randomUUID(),
              payload: {},
              client_updated_at: new Date().toISOString(),
            },
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'sales_documents',
              entity_id: randomUUID(),
              operation: 'create',
              base_sync_version: 0,
              payload: {},
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(commandPush.statusCode).toBe(200);
      const cmdBody = commandPush.json() as {
        data: { errors: Array<{ code: string }> };
      };
      expect(cmdBody.data.errors).toHaveLength(2);
      expect(cmdBody.data.errors.every((e) => e.code === 'NOT_IMPLEMENTED')).toBe(
        true,
      );

      const emptyPull = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(watermarkCursor())}&entity_types=parties&limit=10`,
        headers: syncHeaders(token, deviceId),
      });
      expect(emptyPull.statusCode).toBe(200);
      const emptyBody = emptyPull.json() as {
        data: { changes: unknown[]; has_more: boolean };
      };
      expect(emptyBody.data.changes).toEqual([]);
      expect(emptyBody.data.has_more).toBe(false);
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
