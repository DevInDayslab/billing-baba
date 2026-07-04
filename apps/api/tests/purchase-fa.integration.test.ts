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
  const body = response.json() as { data: { access_token: string } };
  return body.data.access_token;
}

async function createSupplier(app: FastifyInstance, token: string) {
  const config = loadAppConfig();
  const suffix = Date.now();
  const res = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/parties`,
    headers: jsonAuthHeaders(token),
    payload: {
      name: `FA Supplier ${suffix}`,
      party_type: 'supplier',
      phone: `9${suffix.toString().slice(-9)}`,
    },
  });
  expect(res.statusCode).toBe(201);
  return (res.json() as { data: { id: string } }).data.id;
}

describe.skipIf(!canRun)('purchase fixed assets integration', () => {
  let app: FastifyInstance;
  let token: string;
  let partyId: string;
  let batchId: string;

  beforeAll(async () => {
    const config = loadAppConfig();
    app = await buildApp(config);
    token = await login(app);
    partyId = await createSupplier(app, token);
  });

  afterAll(async () => {
    await app.close();
  });

  test('creates fixed asset batch', async () => {
    const config = loadAppConfig();
    const today = new Date().toISOString().slice(0, 10);
    const res = await app.inject({
      method: 'POST',
      url: `${config.apiPrefix}/purchases/fixed-asset-purchases`,
      headers: jsonAuthHeaders(token),
      payload: {
        party_id: partyId,
        reference_number: `FA-${Date.now()}`,
        purchase_date: today,
        total_amount: '50000.0000',
        assets: [
          {
            asset_name: 'Laptop',
            purchase_price: '50000.0000',
            line_total: '50000.0000',
            serial_number: `SN-${Date.now()}`,
          },
        ],
      },
    });
    expect(res.statusCode).toBe(201);
    const body = res.json() as {
      data: { id: string; assets: { id: string }[] };
    };
    batchId = body.data.id;
    expect(body.data.assets).toHaveLength(1);
  });

  test('lists fixed asset batches', async () => {
    const config = loadAppConfig();
    const res = await app.inject({
      method: 'GET',
      url: `${config.apiPrefix}/purchases/fixed-asset-purchases`,
      headers: getAuthHeaders(token),
    });
    expect(res.statusCode).toBe(200);
    const body = res.json() as { data: unknown[] };
    expect(body.data.length).toBeGreaterThan(0);
  });

  test('gets batch detail', async () => {
    const config = loadAppConfig();
    const res = await app.inject({
      method: 'GET',
      url: `${config.apiPrefix}/purchases/fixed-asset-purchases/${batchId}`,
      headers: getAuthHeaders(token),
    });
    expect(res.statusCode).toBe(200);
    const body = res.json() as { data: { id: string; assets: unknown[] } };
    expect(body.data.id).toBe(batchId);
    expect(body.data.assets.length).toBeGreaterThan(0);
  });

  test('deletes batch', async () => {
    const config = loadAppConfig();
    const res = await app.inject({
      method: 'DELETE',
      url: `${config.apiPrefix}/purchases/fixed-asset-purchases/${batchId}`,
      headers: getAuthHeaders(token),
    });
    expect(res.statusCode).toBe(204);
  });
});
