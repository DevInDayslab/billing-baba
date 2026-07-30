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
    'create → pull → update → conflict → delete → duplicate replay → unsupported command payload',
    async () => {
      const categoryId = randomUUID();
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
              entity_type: 'categories',
              entity_id: categoryId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                name: `Sync Category ${suffix}`,
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
      expect(createBody.data.accepted[0]?.entity_id).toBe(categoryId);

      const pullCursor = encodeCursor({
        t: new Date(Date.now() - 60_000).toISOString(),
        i: ZERO_UUID,
      });
      const pull1 = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(pullCursor)}&entity_types=categories&limit=200`,
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
        (c) => c.entity_id === categoryId,
      );
      expect(createdChange).toBeTruthy();
      expect(createdChange?.sync_version).toBe(1);
      expect(createdChange?.is_deleted).toBe(false);
      expect(createdChange?.payload?.name).toBe(`Sync Category ${suffix}`);

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
              entity_type: 'categories',
              entity_id: categoryId,
              operation: 'update',
              base_sync_version: 1,
              payload: { name: `Sync Category ${suffix} Updated` },
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
              entity_type: 'categories',
              entity_id: categoryId,
              operation: 'update',
              base_sync_version: 1,
              payload: { name: 'stale' },
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
              entity_type: 'categories',
              entity_id: categoryId,
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
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(pullCursor)}&entity_types=categories&limit=100`,
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
        (c) => c.entity_id === categoryId && c.is_deleted,
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
              entity_type: 'categories',
              entity_id: categoryId,
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
          ],
        },
      });
      expect(commandPush.statusCode).toBe(200);
      const cmdBody = commandPush.json() as {
        data: { errors: Array<{ code: string }> };
      };
      expect(cmdBody.data.errors).toHaveLength(1);
      expect(cmdBody.data.errors[0]?.code).toBe('VALIDATION_FAILED');

      const emptyPull = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(watermarkCursor())}&entity_types=categories&limit=10`,
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

  test(
    'parties create → pull → conflict → duplicate replay',
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
                mobile: `9${suffix.slice(0, 9).padEnd(9, '0')}`,
                party_type: 'customer',
                pricing_tier: 'tier_1',
                credit_limit: '0',
                opening_balance: '0',
                is_active: true,
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
        };
      };
      const found = pull1Body.data.changes.find((c) => c.entity_id === partyId);
      expect(found).toBeTruthy();
      expect(found?.sync_version).toBe(1);
      expect(found?.is_deleted).toBe(false);
      expect(found?.payload?.name).toBe(`Sync Party ${suffix}`);

      const mutationUpdate = randomUUID();
      const conflictPush = await app.inject({
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
              base_sync_version: 0,
              payload: {
                name: 'Should Conflict',
                party_type: 'customer',
                pricing_tier: 'tier_1',
                credit_limit: '0',
                opening_balance: '0',
                is_active: true,
              },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(conflictPush.statusCode).toBe(200);
      const conflictBody = conflictPush.json() as {
        data: { conflicts: Array<{ mutation_id: string }>; accepted: unknown[] };
      };
      expect(conflictBody.data.accepted).toEqual([]);
      expect(conflictBody.data.conflicts).toHaveLength(1);
      expect(conflictBody.data.conflicts[0]?.mutation_id).toBe(mutationUpdate);

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
              payload: { name: 'should not re-apply', party_type: 'customer' },
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
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'items create → pull → conflict → duplicate replay',
    async () => {
      const itemId = randomUUID();
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
              entity_type: 'items',
              entity_id: itemId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                name: `Sync Item ${suffix}`,
                base_unit: 'piece',
                item_type: 'product',
                has_stock_tracking: true,
                sale_price: '100',
                purchase_price: '80',
                is_mrp_only: false,
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
      expect(createBody.data.accepted[0]?.entity_id).toBe(itemId);

      const pullCursor = encodeCursor({
        t: new Date(Date.now() - 60_000).toISOString(),
        i: ZERO_UUID,
      });
      const pull1 = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(pullCursor)}&entity_types=items&limit=200`,
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
        };
      };
      const found = pull1Body.data.changes.find((c) => c.entity_id === itemId);
      expect(found).toBeTruthy();
      expect(found?.sync_version).toBe(1);
      expect(found?.is_deleted).toBe(false);
      expect(found?.payload?.name).toBe(`Sync Item ${suffix}`);

      const mutationUpdate = randomUUID();
      const conflictPush = await app.inject({
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
              entity_type: 'items',
              entity_id: itemId,
              operation: 'update',
              base_sync_version: 0,
              payload: {
                name: 'Should Conflict',
                base_unit: 'piece',
                item_type: 'product',
                has_stock_tracking: true,
                sale_price: '100',
                purchase_price: '80',
                is_mrp_only: false,
              },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(conflictPush.statusCode).toBe(200);
      const conflictBody = conflictPush.json() as {
        data: { conflicts: Array<{ mutation_id: string }>; accepted: unknown[] };
      };
      expect(conflictBody.data.accepted).toEqual([]);
      expect(conflictBody.data.conflicts).toHaveLength(1);
      expect(conflictBody.data.conflicts[0]?.mutation_id).toBe(mutationUpdate);

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
              entity_type: 'items',
              entity_id: itemId,
              operation: 'create',
              base_sync_version: 0,
              payload: { name: 'should not re-apply', base_unit: 'piece' },
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
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'multi-device row pipeline: bootstrap pull, bidirectional sync, soft-delete, cursor',
    async () => {
      const desktopId = randomUUID();
      const androidId = randomUUID();

      for (const [id, platform, name] of [
        [desktopId, 'macos', 'desktop'] as const,
        [androidId, 'android', 'android'] as const,
      ]) {
        const reg = await app.inject({
          method: 'POST',
          url: `${syncPrefix}/devices`,
          headers: syncHeaders(token, id),
          payload: {
            device_id: id,
            platform,
            app_version: '1.4.0',
            device_name: `${name}-${suffix}`,
          },
        });
        expect(reg.statusCode).toBe(200);
      }

      const categoryId = randomUUID();
      const partyId = randomUUID();
      const itemId = randomUUID();
      const epoch = encodeCursor({
        t: new Date(0).toISOString(),
        i: ZERO_UUID,
      });

      // Desktop creates all three masters.
      const createPush = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, desktopId),
        payload: {
          device_id: desktopId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'categories',
              entity_id: categoryId,
              operation: 'create',
              base_sync_version: 0,
              payload: { name: `MD Cat ${suffix}` },
              client_updated_at: new Date().toISOString(),
            },
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'parties',
              entity_id: partyId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                name: `MD Party ${suffix}`,
                mobile: `8${suffix.slice(0, 9).padEnd(9, '0')}`,
                party_type: 'customer',
                pricing_tier: 'tier_1',
                credit_limit: '0',
                opening_balance: '0',
                is_active: true,
              },
              client_updated_at: new Date().toISOString(),
            },
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'items',
              entity_id: itemId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                name: `MD Item ${suffix}`,
                base_unit: 'piece',
                item_type: 'product',
                has_stock_tracking: true,
                sale_price: '50',
                purchase_price: '40',
                is_mrp_only: false,
              },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(createPush.statusCode).toBe(200);
      const createBody = createPush.json() as {
        data: { accepted: unknown[]; errors: unknown[]; conflicts: unknown[] };
      };
      expect(createBody.data.errors).toEqual([]);
      expect(createBody.data.conflicts).toEqual([]);
      expect(createBody.data.accepted).toHaveLength(3);

      // Android bootstrap-style pull from epoch for all registered entities.
      const androidChanges: Array<{
        entity_type: string;
        entity_id: string;
        is_deleted: boolean;
        payload: Record<string, unknown> | null;
      }> = [];
      let androidCursor = epoch;
      let androidNextCursor = epoch;
      for (let page = 0; page < 20; page += 1) {
        const androidBoot = await app.inject({
          method: 'GET',
          url: `${syncPrefix}/pull?cursor=${encodeURIComponent(androidCursor)}&entity_types=${encodeURIComponent('categories,parties,items')}&limit=200`,
          headers: syncHeaders(token, androidId),
        });
        expect(androidBoot.statusCode).toBe(200);
        const bootBody = androidBoot.json() as {
          data: {
            changes: Array<{
              entity_type: string;
              entity_id: string;
              is_deleted: boolean;
              payload: Record<string, unknown> | null;
            }>;
            next_cursor: string;
            has_more: boolean;
          };
        };
        androidChanges.push(...bootBody.data.changes);
        androidNextCursor = bootBody.data.next_cursor;
        if (!bootBody.data.has_more || bootBody.data.changes.length === 0) {
          break;
        }
        androidCursor = bootBody.data.next_cursor;
      }
      expect(androidNextCursor).toBeTruthy();
      const byId = new Map(
        androidChanges.map((c) => [c.entity_id, c] as const),
      );
      expect(byId.get(categoryId)?.payload?.name).toBe(`MD Cat ${suffix}`);
      expect(byId.get(partyId)?.payload?.name).toBe(`MD Party ${suffix}`);
      expect(byId.get(itemId)?.payload?.name).toBe(`MD Item ${suffix}`);
      expect(
        androidChanges.filter((c) =>
          [categoryId, partyId, itemId].includes(c.entity_id),
        ),
      ).toHaveLength(3);

      // Android edits all three.
      const androidEdit = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, androidId),
        payload: {
          device_id: androidId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'categories',
              entity_id: categoryId,
              operation: 'update',
              base_sync_version: 1,
              payload: { name: `MD Cat Edited ${suffix}` },
              client_updated_at: new Date().toISOString(),
            },
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'parties',
              entity_id: partyId,
              operation: 'update',
              base_sync_version: 1,
              payload: {
                name: `MD Party Edited ${suffix}`,
                party_type: 'customer',
                pricing_tier: 'tier_1',
                credit_limit: '0',
                opening_balance: '0',
                is_active: true,
              },
              client_updated_at: new Date().toISOString(),
            },
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'items',
              entity_id: itemId,
              operation: 'update',
              base_sync_version: 1,
              payload: {
                name: `MD Item Edited ${suffix}`,
                base_unit: 'piece',
                item_type: 'product',
                has_stock_tracking: true,
                sale_price: '55',
                purchase_price: '40',
                is_mrp_only: false,
              },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(androidEdit.statusCode).toBe(200);
      const editBody = androidEdit.json() as {
        data: { accepted: unknown[]; conflicts: unknown[]; errors: unknown[] };
      };
      expect(editBody.data.errors).toEqual([]);
      expect(editBody.data.conflicts).toEqual([]);
      expect(editBody.data.accepted).toHaveLength(3);

      // Desktop pulls edits using cursor after android's bootstrap catch-up.
      const desktopPull = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(androidNextCursor)}&entity_types=${encodeURIComponent('categories,parties,items')}&limit=200`,
        headers: syncHeaders(token, desktopId),
      });
      expect(desktopPull.statusCode).toBe(200);
      const desktopPullBody = desktopPull.json() as {
        data: {
          changes: Array<{
            entity_id: string;
            is_deleted: boolean;
            payload: Record<string, unknown> | null;
          }>;
          next_cursor: string;
        };
      };
      const edited = new Map(
        desktopPullBody.data.changes.map((c) => [c.entity_id, c] as const),
      );
      expect(edited.get(categoryId)?.payload?.name).toBe(
        `MD Cat Edited ${suffix}`,
      );
      expect(edited.get(partyId)?.payload?.name).toBe(
        `MD Party Edited ${suffix}`,
      );
      expect(edited.get(itemId)?.payload?.name).toBe(
        `MD Item Edited ${suffix}`,
      );

      // Desktop soft-deletes all three.
      const deletePush = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, desktopId),
        payload: {
          device_id: desktopId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'categories',
              entity_id: categoryId,
              operation: 'delete',
              base_sync_version: 2,
              payload: {},
              client_updated_at: new Date().toISOString(),
            },
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'parties',
              entity_id: partyId,
              operation: 'delete',
              base_sync_version: 2,
              payload: {},
              client_updated_at: new Date().toISOString(),
            },
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'items',
              entity_id: itemId,
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
        data: { accepted: unknown[]; conflicts: unknown[]; errors: unknown[] };
      };
      expect(deleteBody.data.errors).toEqual([]);
      expect(deleteBody.data.conflicts).toEqual([]);
      expect(deleteBody.data.accepted).toHaveLength(3);

      const androidDeletePull = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(desktopPullBody.data.next_cursor)}&entity_types=${encodeURIComponent('categories,parties,items')}&limit=200`,
        headers: syncHeaders(token, androidId),
      });
      expect(androidDeletePull.statusCode).toBe(200);
      const deletePullBody = androidDeletePull.json() as {
        data: {
          changes: Array<{ entity_id: string; is_deleted: boolean }>;
          next_cursor: string;
        };
      };
      const deleted = new Map(
        deletePullBody.data.changes.map((c) => [c.entity_id, c] as const),
      );
      expect(deleted.get(categoryId)?.is_deleted).toBe(true);
      expect(deleted.get(partyId)?.is_deleted).toBe(true);
      expect(deleted.get(itemId)?.is_deleted).toBe(true);
      expect(deletePullBody.data.next_cursor).not.toBe(
        desktopPullBody.data.next_cursor,
      );

      // Bootstrap endpoint still returns initial_cursor only (no chunk sessions).
      const bootstrap = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/bootstrap`,
        headers: syncHeaders(token, androidId),
        payload: { device_id: androidId, schema_version: 1 },
      });
      expect(bootstrap.statusCode).toBe(202);
      const bootstrapBody = bootstrap.json() as {
        data: { initial_cursor: string; estimated_rows: number };
      };
      expect(bootstrapBody.data.initial_cursor).toBeTruthy();
      expect(bootstrapBody.data.estimated_rows).toBe(0);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'remaining masters: units, tax_rates, godowns, business_settings create → pull → conflict → replay',
    async () => {
      const unitId = randomUUID();
      const taxId = randomUUID();
      const godownId = randomUUID();
      const settingsId = randomUUID();
      const unitMut = randomUUID();
      const taxMut = randomUUID();
      const godownMut = randomUUID();
      const settingsMut = randomUUID();

      const createPush = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: unitMut,
              kind: 'row',
              entity_type: 'unit_definitions',
              entity_id: unitId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                name: `Unit ${suffix}`,
                short_name: `u${suffix.slice(0, 4)}`,
                decimal_places: 0,
                is_system: false,
                is_active: true,
              },
              client_updated_at: new Date().toISOString(),
            },
            {
              mutation_id: taxMut,
              kind: 'row',
              entity_type: 'tax_rates',
              entity_id: taxId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                name: `Tax ${suffix}`,
                rate: '18',
                is_default: false,
              },
              client_updated_at: new Date().toISOString(),
            },
            {
              mutation_id: godownMut,
              kind: 'row',
              entity_type: 'godowns',
              entity_id: godownId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                name: `Godown ${suffix}`,
                address: 'Warehouse A',
                is_default: false,
              },
              client_updated_at: new Date().toISOString(),
            },
            {
              mutation_id: settingsMut,
              kind: 'row',
              entity_type: 'business_settings',
              entity_id: settingsId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                valuation_method: 'average',
                default_tax_type: 'none',
                enable_price_conflict_alerts: true,
                credit_limit_action: 'warn',
                pricing_tier_labels: { tier_1: 'Retail' },
                default_invoice_tax_rate: '18',
              },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(createPush.statusCode).toBe(200);
      const createBody = createPush.json() as {
        data: { accepted: unknown[]; conflicts: unknown[]; errors: unknown[] };
      };
      expect(createBody.data.errors).toEqual([]);
      expect(createBody.data.conflicts).toEqual([]);
      expect(createBody.data.accepted).toHaveLength(4);

      const pullCursor = encodeCursor({
        t: new Date(Date.now() - 60_000).toISOString(),
        i: ZERO_UUID,
      });
      const entityTypes =
        'unit_definitions,tax_rates,godowns,business_settings';
      const pull1 = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(pullCursor)}&entity_types=${encodeURIComponent(entityTypes)}&limit=200`,
        headers: syncHeaders(token, deviceId),
      });
      expect(pull1.statusCode).toBe(200);
      const pull1Body = pull1.json() as {
        data: {
          changes: Array<{
            entity_id: string;
            entity_type: string;
            payload: Record<string, unknown> | null;
          }>;
        };
      };
      const byId = new Map(
        pull1Body.data.changes.map((c) => [c.entity_id, c] as const),
      );
      expect(byId.get(unitId)?.payload?.name).toBe(`Unit ${suffix}`);
      expect(byId.get(taxId)?.payload?.name).toBe(`Tax ${suffix}`);
      expect(byId.get(godownId)?.payload?.name).toBe(`Godown ${suffix}`);
      expect(byId.get(settingsId)?.payload?.valuation_method).toBe('average');

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
              entity_type: 'unit_definitions',
              entity_id: unitId,
              operation: 'update',
              base_sync_version: 0,
              payload: {
                name: 'Should Conflict',
                short_name: 'x',
                decimal_places: 0,
                is_system: false,
                is_active: true,
              },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(conflictPush.statusCode).toBe(200);
      const conflictBody = conflictPush.json() as {
        data: { conflicts: unknown[]; accepted: unknown[] };
      };
      expect(conflictBody.data.accepted).toEqual([]);
      expect(conflictBody.data.conflicts).toHaveLength(1);

      const replay = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: unitMut,
              kind: 'row',
              entity_type: 'unit_definitions',
              entity_id: unitId,
              operation: 'create',
              base_sync_version: 0,
              payload: { name: 'nope', short_name: 'n' },
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
      expect(replayBody.data.replayed[0]?.mutation_id).toBe(unitMut);
      expect(replayBody.data.replayed[0]?.idempotent_replay).toBe(true);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'rejects push batches larger than max_push_mutations',
    async () => {
      const mutations = Array.from({ length: 101 }, (_, index) => ({
        mutation_id: randomUUID(),
        kind: 'row' as const,
        entity_type: 'categories',
        entity_id: randomUUID(),
        operation: 'create' as const,
        base_sync_version: 0,
        payload: {
          name: `Batch Category ${suffix}-${index}`,
        },
        client_updated_at: new Date().toISOString(),
      }));

      const response = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations,
        },
      });

      expect(response.statusCode).toBe(400);
      const body = response.json() as {
        error: { code: string };
      };
      expect(body.error.code).toBe('BATCH_TOO_LARGE');
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
