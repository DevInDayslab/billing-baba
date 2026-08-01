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

function businessIdFromToken(token: string): string {
  const payload = JSON.parse(
    Buffer.from(token.split('.')[1] ?? '', 'base64url').toString(),
  ) as { business_id: string };
  return payload.business_id;
}

async function devLogin(app: FastifyInstance): Promise<{
  access_token: string;
  refresh_token: string;
}> {
  const config = loadAppConfig();
  const response = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/auth/dev-login`,
    payload: {},
  });
  expect(response.statusCode).toBe(200);
  return (response.json() as { data: { access_token: string; refresh_token: string } })
    .data;
}

async function refreshForBusiness(
  app: FastifyInstance,
  refreshToken: string,
  businessId: string,
): Promise<string> {
  const config = loadAppConfig();
  const response = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/auth/refresh`,
    payload: {
      refresh_token: refreshToken,
      business_id: businessId,
    },
  });
  expect(response.statusCode).toBe(200);
  return (response.json() as { data: { access_token: string } }).data.access_token;
}

type PullChange = {
  entity_type: string;
  entity_id: string;
  sync_version: number;
  updated_at: string;
  is_deleted: boolean;
  payload: Record<string, unknown> | null;
};

describe.skipIf(!canRunDbTests)('Stock levels sync integration', () => {
  let app: FastifyInstance;
  let token: string;
  let deviceId: string;
  let syncPrefix: string;
  let apiPrefix: string;
  let godownId: string;
  let unitShortName: string;
  const suffix = uniqueSuffix();

  beforeAll(async () => {
    app = await createTestApp();
    token = await login(app);
    const config = loadAppConfig();
    apiPrefix = config.apiPrefix;
    syncPrefix = `${apiPrefix}/sync`;
    deviceId = randomUUID();

    await app.inject({
      method: 'POST',
      url: `${syncPrefix}/devices`,
      headers: syncHeaders(token, deviceId),
      payload: {
        device_id: deviceId,
        platform: 'macos',
        app_version: '1.4.0',
        device_name: `stock-sync-${suffix}`,
      },
    });

    const godowns = await app.inject({
      method: 'GET',
      url: `${apiPrefix}/inventory/godowns`,
      headers: jsonAuthHeaders(token),
    });
    godownId = (
      godowns.json() as { data: { id: string; is_default: boolean }[] }
    ).data.find((row) => row.is_default)!.id;

    const unitRes = await app.inject({
      method: 'POST',
      url: `${apiPrefix}/inventory/units`,
      headers: jsonAuthHeaders(token),
      payload: {
        name: `StockSyncUnit-${suffix}`,
        short_name: `SL${suffix.slice(0, 4)}`,
      },
    });
    unitShortName = (unitRes.json() as { data: { short_name: string } }).data
      .short_name;
  }, INTEGRATION_TIMEOUT_MS);

  afterAll(async () => {
    await app.close();
  });

  async function createItemWithOpeningStock(
    authToken: string,
    label: string,
    openingQty: string,
  ): Promise<string> {
    const itemRes = await app.inject({
      method: 'POST',
      url: `${apiPrefix}/inventory/items`,
      headers: jsonAuthHeaders(authToken),
      payload: {
        name: `${label}-${suffix}`,
        item_type: 'product',
        base_unit: unitShortName,
        opening_quantity: openingQty,
        opening_cost_per_unit: '50',
        opening_godown_id: godownId,
        sale_price: '100',
      },
    });
    expect(itemRes.statusCode).toBe(201);
    return (itemRes.json() as { data: { id: string } }).data.id;
  }

  async function pullStockLevels(
    authToken: string,
    localDeviceId: string,
    cursor: string,
  ): Promise<PullChange[]> {
    const pull = await app.inject({
      method: 'GET',
      url: `${syncPrefix}/pull?cursor=${encodeURIComponent(cursor)}&entity_types=stock_levels&limit=200`,
      headers: syncHeaders(authToken, localDeviceId),
    });
    expect(pull.statusCode).toBe(200);
    return (pull.json() as { data: { changes: PullChange[] } }).data.changes;
  }

  test(
    'pull returns stock_levels for the caller business with expected fields',
    async () => {
      await createItemWithOpeningStock(token, 'StockPullItem', '25');

      const cursor = encodeCursor({
        t: new Date(Date.now() - 60_000).toISOString(),
        i: ZERO_UUID,
      });
      const changes = await pullStockLevels(token, deviceId, cursor);
      const stockChanges = changes.filter(
        (row) => row.entity_type === 'stock_levels',
      );

      expect(stockChanges.length).toBeGreaterThan(0);

      const row = stockChanges.find(
        (change) => change.payload?.godown_id === godownId,
      );
      expect(row).toBeTruthy();
      expect(row!.entity_id).toMatch(
        /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i,
      );
      expect(row!.sync_version).toBeGreaterThan(0);
      expect(row!.is_deleted).toBe(false);
      expect(row!.payload).toMatchObject({
        item_id: expect.any(String),
        godown_id: godownId,
        quantity: '25.0000',
        average_cost: '50.0000',
      });
      expect(row!.updated_at).toBeTruthy();
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'two businesses do not leak stock_levels across tenants',
    async () => {
      const session = await devLogin(app);
      const businessAId = businessIdFromToken(session.access_token);
      await createItemWithOpeningStock(
        session.access_token,
        'TenantAStock',
        '10',
      );

      const createBusiness = await app.inject({
        method: 'POST',
        url: `${apiPrefix}/businesses`,
        headers: jsonAuthHeaders(session.access_token),
        payload: {
          name: `Stock Tenant B ${suffix}`,
          state_code: '27',
        },
      });
      expect(createBusiness.statusCode).toBe(201);
      const businessBId = (
        createBusiness.json() as { data: { id: string } }
      ).data.id;
      const tokenB = await refreshForBusiness(
        app,
        session.refresh_token,
        businessBId,
      );
      expect(businessIdFromToken(tokenB)).toBe(businessBId);
      expect(businessBId).not.toBe(businessAId);

      const deviceB = randomUUID();
      await app.inject({
        method: 'POST',
        url: `${syncPrefix}/devices`,
        headers: syncHeaders(tokenB, deviceB),
        payload: {
          device_id: deviceB,
          platform: 'macos',
          app_version: '1.4.0',
          device_name: `stock-tenant-b-${suffix}`,
        },
      });

      const cursor = encodeCursor({
        t: new Date(0).toISOString(),
        i: ZERO_UUID,
      });
      const changesA = await pullStockLevels(session.access_token, deviceId, cursor);
      const changesB = await pullStockLevels(tokenB, deviceB, cursor);

      expect(
        changesA.some(
          (row) =>
            row.entity_type === 'stock_levels' &&
            row.payload?.quantity === '10.0000',
        ),
      ).toBe(true);
      expect(
        changesB.some(
          (row) =>
            row.entity_type === 'stock_levels' &&
            row.payload?.quantity === '10.0000',
        ),
      ).toBe(false);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'pull with a newer cursor returns only changed stock_levels rows',
    async () => {
      const itemId = await createItemWithOpeningStock(
        token,
        'CursorStockItem',
        '40',
      );

      const baselineCursor = watermarkCursor(new Date());
      await new Promise((resolve) => setTimeout(resolve, 5));

      const stockRes = await app.inject({
        method: 'GET',
        url: `${apiPrefix}/inventory/stock-levels?item_id=${itemId}`,
        headers: jsonAuthHeaders(token),
      });
      const stockLevelId = (
        stockRes.json() as { data: { id: string }[] }
      ).data[0]!.id;

      const partyRes = await app.inject({
        method: 'POST',
        url: `${apiPrefix}/parties`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `StockCursorParty-${suffix}`,
          party_type: 'customer',
          mobile: `9${suffix.replace(/\D/g, '').slice(0, 9).padEnd(9, '3')}`,
        },
      });
      const partyId = (partyRes.json() as { data: { id: string } }).data.id;

      const docRes = await app.inject({
        method: 'POST',
        url: `${apiPrefix}/sales/sales-documents`,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'tax_invoice',
          document_series: 'INV',
          party_id: partyId,
          is_gst_formal: false,
        },
      });
      const docId = (docRes.json() as { data: { id: string } }).data.id;

      await app.inject({
        method: 'POST',
        url: `${apiPrefix}/sales/sales-documents/${docId}/lines`,
        headers: jsonAuthHeaders(token),
        payload: {
          item_id: itemId,
          quantity: '5',
          unit: unitShortName,
          unit_price: '100',
          tax_rate: '0',
        },
      });

      await app.inject({
        method: 'POST',
        url: `${apiPrefix}/sales/sales-documents/${docId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: { godown_id: godownId },
      });

      const incrementalChanges = await pullStockLevels(
        token,
        deviceId,
        baselineCursor,
      );
      const stockChanges = incrementalChanges.filter(
        (row) => row.entity_type === 'stock_levels',
      );

      expect(stockChanges).toHaveLength(1);
      expect(stockChanges[0]?.entity_id).toBe(stockLevelId);
      expect(stockChanges[0]?.payload?.quantity).toBe('35.0000');
      expect(stockChanges[0]?.sync_version).toBeGreaterThan(1);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'push containing stock_levels is rejected with PULL_ONLY_ENTITY',
    async () => {
      const push = await app.inject({
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
              entity_type: 'stock_levels',
              entity_id: randomUUID(),
              operation: 'update',
              base_sync_version: 1,
              payload: {
                quantity: '999',
              },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });

      expect(push.statusCode).toBe(200);
      const body = push.json() as {
        data: {
          accepted: unknown[];
          errors: Array<{ code?: string; message?: string }>;
        };
      };
      expect(body.data.accepted).toEqual([]);
      expect(body.data.errors).toHaveLength(1);
      expect(body.data.errors[0]?.code).toBe('PULL_ONLY_ENTITY');
      expect(body.data.errors[0]?.message).toContain('server-derived projection');
      expect(body.data.errors[0]?.message).toContain('stock_levels');
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'pre-existing entities still pull unchanged alongside stock_levels filter',
    async () => {
      const categoryId = randomUUID();
      const categoryName = `StockSideCategory-${suffix}`;
      const createPush = await app.inject({
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
              operation: 'create',
              base_sync_version: 0,
              payload: { name: categoryName },
              client_updated_at: new Date().toISOString(),
            },
          ],
        },
      });
      expect(createPush.statusCode).toBe(200);

      const cursor = encodeCursor({
        t: new Date(Date.now() - 60_000).toISOString(),
        i: ZERO_UUID,
      });
      const pull = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(cursor)}&entity_types=categories&limit=200`,
        headers: syncHeaders(token, deviceId),
      });
      expect(pull.statusCode).toBe(200);
      const changes = (pull.json() as { data: { changes: PullChange[] } }).data
        .changes;
      expect(
        changes.some(
          (row) =>
            row.entity_type === 'categories' &&
            row.entity_id === categoryId &&
            row.payload?.name === categoryName,
        ),
      ).toBe(true);
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
