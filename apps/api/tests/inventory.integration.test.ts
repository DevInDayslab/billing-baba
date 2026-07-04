import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../src/app';
import { loadAppConfig } from '../src/config/app_config';

const hasDatabase = Boolean(process.env.DATABASE_URL);
const canRun = hasDatabase && process.env.JWT_SECRET;

function getAuthHeaders(token: string): Record<string, string> {
  return { authorization: `Bearer ${token}` };
}

function jsonAuthHeaders(token: string): Record<string, string> {
  return {
    authorization: `Bearer ${token}`,
    'content-type': 'application/json',
  };
}

async function login(app: FastifyInstance): Promise<string> {
  const config = loadAppConfig();
  const response = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/auth/dev-login`,
    payload: {},
  });

  expect(response.statusCode).toBe(200);
  const body = response.json() as {
    data: { access_token: string };
  };
  return body.data.access_token;
}

describe.skipIf(!canRun)('Inventory API integration', () => {
  let app: FastifyInstance;
  let token: string;
  const suffix = Date.now().toString(36).slice(-6);
  const testTimeout = 30_000;

  beforeAll(async () => {
    process.env.ENABLE_DEV_LOGIN = 'true';
    process.env.NODE_ENV = process.env.NODE_ENV ?? 'test';
    const config = loadAppConfig();
    app = await buildApp(config);
    await app.ready();
    token = await login(app);
  });

  afterAll(async () => {
    await app.close();
  });

  test(
    'categories CRUD with duplicate prevention',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/inventory/categories`;
      const name = `Cat-${suffix}`;

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: { name },
      });
      expect(created.statusCode).toBe(201);
      const categoryId = (created.json() as { data: { id: string } }).data.id;

      const duplicate = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: { name },
      });
      expect(duplicate.statusCode).toBe(400);

      const listed = await app.inject({
        method: 'GET',
        url: `${prefix}?q=${name}`,
        headers: getAuthHeaders(token),
      });
      expect(listed.statusCode).toBe(200);
      const listBody = listed.json() as {
        data: unknown[];
        meta: { total: number };
      };
      expect(listBody.meta.total).toBeGreaterThanOrEqual(1);

      const deleted = await app.inject({
        method: 'DELETE',
        url: `${prefix}/${categoryId}`,
        headers: getAuthHeaders(token),
      });
      expect(deleted.statusCode).toBe(204);
    },
    testTimeout,
  );

  test(
    'brands CRUD with item dependency guard',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/inventory/brands`;
      const name = `Brand-${suffix}`;

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: { name },
      });
      expect(created.statusCode).toBe(201);
      const brandId = (created.json() as { data: { id: string } }).data.id;

      const unitRes = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/inventory/units`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `Piece-${suffix}`,
          short_name: `PC${suffix}`,
        },
      });
      expect(unitRes.statusCode).toBe(201);

      const itemRes = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/inventory/items`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `Item-${suffix}`,
          item_type: 'service',
          base_unit: `PC${suffix}`,
        },
      });
      expect(itemRes.statusCode).toBe(201);
      const itemId = (itemRes.json() as { data: { id: string } }).data.id;

      await app.inject({
        method: 'PATCH',
        url: `${config.apiPrefix}/inventory/items/${itemId}`,
        headers: jsonAuthHeaders(token),
        payload: { brand_id: brandId },
      });

      const blocked = await app.inject({
        method: 'DELETE',
        url: `${prefix}/${brandId}`,
        headers: getAuthHeaders(token),
      });
      expect(blocked.statusCode).toBe(422);

      await app.inject({
        method: 'PATCH',
        url: `${config.apiPrefix}/inventory/items/${itemId}`,
        headers: jsonAuthHeaders(token),
        payload: { brand_id: null },
      });

      const deleted = await app.inject({
        method: 'DELETE',
        url: `${prefix}/${brandId}`,
        headers: getAuthHeaders(token),
      });
      expect(deleted.statusCode).toBe(204);
    },
    testTimeout,
  );

  test(
    'units and conversions validation',
    async () => {
      const config = loadAppConfig();
      const unitsPrefix = `${config.apiPrefix}/inventory/units`;
      const conversionsPrefix = `${config.apiPrefix}/inventory/unit-conversions`;

      const pcs = await app.inject({
        method: 'POST',
        url: unitsPrefix,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `Pieces-${suffix}`,
          short_name: `PCS${suffix}`,
          symbol: 'pcs',
        },
      });
      expect(pcs.statusCode).toBe(201);
      const pcsId = (pcs.json() as { data: { id: string } }).data.id;

      const btl = await app.inject({
        method: 'POST',
        url: unitsPrefix,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `Bottle-${suffix}`,
          short_name: `BTL${suffix}`,
        },
      });
      expect(btl.statusCode).toBe(201);
      const btlId = (btl.json() as { data: { id: string } }).data.id;

      const selfConversion = await app.inject({
        method: 'POST',
        url: conversionsPrefix,
        headers: jsonAuthHeaders(token),
        payload: {
          from_unit_id: pcsId,
          to_unit_id: pcsId,
          conversion_factor: '1',
        },
      });
      expect(selfConversion.statusCode).toBe(400);

      const conversion = await app.inject({
        method: 'POST',
        url: conversionsPrefix,
        headers: jsonAuthHeaders(token),
        payload: {
          from_unit_id: pcsId,
          to_unit_id: btlId,
          conversion_factor: '10',
        },
      });
      expect(conversion.statusCode).toBe(201);
    },
    testTimeout,
  );

  test(
    'godowns list includes default warehouse',
    async () => {
      const config = loadAppConfig();
      const response = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/godowns`,
        headers: getAuthHeaders(token),
      });
      expect(response.statusCode).toBe(200);
      const body = response.json() as {
        data: { name: string; is_default: boolean }[];
      };
      expect(body.data.some((row) => row.is_default)).toBe(true);
    },
    testTimeout,
  );

  test(
    'product opening stock transaction',
    async () => {
      const config = loadAppConfig();
      const godowns = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/godowns`,
        headers: getAuthHeaders(token),
      });
      const defaultGodown = (
        godowns.json() as {
          data: { id: string; is_default: boolean }[];
        }
      ).data.find((row) => row.is_default);
      expect(defaultGodown).toBeDefined();

      const unitRes = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/inventory/units`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `Box-${suffix}`,
          short_name: `BOX${suffix}`,
        },
      });
      expect(unitRes.statusCode).toBe(201);

      const itemRes = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/inventory/items`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `Product-${suffix}`,
          item_type: 'product',
          base_unit: `BOX${suffix}`,
          opening_quantity: '5',
          opening_cost_per_unit: '100',
          opening_godown_id: defaultGodown?.id,
        },
      });
      expect(itemRes.statusCode).toBe(201);
      const itemId = (itemRes.json() as { data: { id: string } }).data.id;

      const stock = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/stock-levels?item_id=${itemId}`,
        headers: getAuthHeaders(token),
      });
      expect(stock.statusCode).toBe(200);
      const stockBody = stock.json() as { data: { quantity: string }[] };
      expect(stockBody.data[0]?.quantity).toBe('5.0000');

      const movements = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/movements?item_id=${itemId}`,
        headers: getAuthHeaders(token),
      });
      expect(movements.statusCode).toBe(200);
      const movementBody = movements.json() as {
        data: { movement_type: string }[];
      };
      expect(
        movementBody.data.some((row) => row.movement_type === 'opening'),
      ).toBe(true);
    },
    testTimeout,
  );

  test(
    'item images tier prices and price history',
    async () => {
      const config = loadAppConfig();
      const unitRes = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/inventory/units`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `Each-${suffix}`,
          short_name: `EA${suffix}`,
        },
      });
      expect(unitRes.statusCode).toBe(201);

      const itemRes = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/inventory/items`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `Svc-${suffix}`,
          item_type: 'service',
          base_unit: `EA${suffix}`,
          sale_price: '100',
          tier_prices: [{ pricing_tier: 'tier_2', price: '90' }],
        },
      });
      expect(itemRes.statusCode).toBe(201);
      const itemId = (itemRes.json() as { data: { id: string } }).data.id;

      const image = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/inventory/items/${itemId}/images`,
        headers: jsonAuthHeaders(token),
        payload: {
          image_url: 'https://example.com/item.jpg',
          is_primary: true,
        },
      });
      expect(image.statusCode).toBe(201);
      const imageId = (image.json() as { data: { id: string } }).data.id;

      const imagePatch = await app.inject({
        method: 'PATCH',
        url: `${config.apiPrefix}/inventory/items/${itemId}/images/${imageId}`,
        headers: jsonAuthHeaders(token),
        payload: { sort_order: 1 },
      });
      expect(imagePatch.statusCode).toBe(200);

      const tierDelete = await app.inject({
        method: 'DELETE',
        url: `${config.apiPrefix}/inventory/items/${itemId}/tier-prices/tier_2`,
        headers: getAuthHeaders(token),
      });
      expect(tierDelete.statusCode).toBe(204);

      const history = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/price-history?item_id=${itemId}`,
        headers: getAuthHeaders(token),
      });
      expect(history.statusCode).toBe(200);
      const historyBody = history.json() as { meta: { total: number } };
      expect(historyBody.meta.total).toBeGreaterThan(0);
    },
    testTimeout,
  );
});
