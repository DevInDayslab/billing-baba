import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import {
  createTestApp,
  getAuthHeaders,
  jsonAuthHeaders,
  login,
  uniqueSuffix,
} from '../helpers/app';
import { canRunDbTests, INTEGRATION_TIMEOUT_MS } from '../helpers/env';
import { createParty } from '../helpers/fixtures';

describe.skipIf(!canRunDbTests)('API smoke', () => {
  let app: FastifyInstance;
  let token: string;
  const suffix = uniqueSuffix();

  beforeAll(async () => {
    app = await createTestApp();
    token = await login(app);
  });

  afterAll(async () => {
    await app.close();
  });

  test('app boots and health endpoint responds', async () => {
    const config = loadAppConfig();
    const response = await app.inject({
      method: 'GET',
      url: `${config.apiPrefix}/health`,
    });
    expect(response.statusCode).toBe(200);
    const body = response.json() as { data: { status: string } };
    expect(body.data.status).toBe('ok');
  });

  test('database health check passes', async () => {
    const config = loadAppConfig();
    const response = await app.inject({
      method: 'GET',
      url: `${config.apiPrefix}/health/db`,
    });
    expect(response.statusCode).toBe(200);
    const body = response.json() as { data: { database: string } };
    expect(body.data.database).toBe('connected');
  });

  test('auth dev-login returns a bearer token', async () => {
    expect(token.length).toBeGreaterThan(10);
  });

  test(
    'one lightweight CRUD per core module',
    async () => {
      const config = loadAppConfig();

      const category = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/inventory/categories`,
        headers: jsonAuthHeaders(token),
        payload: { name: `SmokeCat-${suffix}` },
      });
      expect(category.statusCode).toBe(201);

      const partyId = await createParty(
        app,
        token,
        `${suffix}-smoke`,
        'supplier',
      );

      const sale = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/sales/sales-documents`,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'estimate',
          document_series: `SMK${suffix}`,
        },
      });
      expect(sale.statusCode).toBe(201);

      const purchase = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/purchases/purchase-documents`,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_order',
          document_series: `SMKPO${suffix}`,
          party_id: partyId,
        },
      });
      expect(purchase.statusCode).toBe(201);

      const payment = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/accounting/payments`,
        headers: jsonAuthHeaders(token),
        payload: {
          party_id: partyId,
          direction: 'received',
          amount: '100',
          payment_mode: 'cash',
        },
      });
      expect(payment.statusCode).toBe(201);

      const dashboard = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/dashboard?period=this_month`,
        headers: getAuthHeaders(token),
      });
      expect(dashboard.statusCode).toBe(200);
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
