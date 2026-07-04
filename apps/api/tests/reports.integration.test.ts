import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../src/app';
import { loadAppConfig } from '../src/config/app_config';

const canRun = Boolean(process.env.DATABASE_URL) && process.env.JWT_SECRET;

function getAuthHeaders(token: string): Record<string, string> {
  return { authorization: `Bearer ${token}` };
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

describe.skipIf(!canRun)('Reports API integration', () => {
  let app: FastifyInstance;
  let token: string;
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
    'GET /reports/sales returns paginated payload',
    async () => {
      const config = loadAppConfig();
      const response = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/reports/sales?period=this_month`,
        headers: getAuthHeaders(token),
      });

      expect(response.statusCode).toBe(200);
      const body = response.json() as {
        data: Record<string, unknown>;
        meta: Record<string, unknown>;
      };
      expect(body.data).toBeDefined();
      expect(body.data.period).toBeDefined();
      expect(body.data.summary).toBeDefined();
      expect(body.data.rows).toBeInstanceOf(Array);
      expect(body.meta.total).toBeDefined();
    },
    testTimeout,
  );

  test(
    'GET /reports/bill-wise-profit returns paginated rows',
    async () => {
      const config = loadAppConfig();
      const response = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/reports/bill-wise-profit?period=this_month`,
        headers: getAuthHeaders(token),
      });

      expect(response.statusCode).toBe(200);
      const body = response.json() as {
        data: { rows: unknown[]; total_profit: string };
        meta: { total: number };
      };
      expect(body.data.rows).toBeInstanceOf(Array);
      expect(body.data.total_profit).toBeDefined();
      expect(body.meta.total).toBeGreaterThanOrEqual(0);
    },
    testTimeout,
  );

  test(
    'GET /reports/expenses returns paginated rows',
    async () => {
      const config = loadAppConfig();
      const response = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/reports/expenses?period=this_month`,
        headers: getAuthHeaders(token),
      });

      expect(response.statusCode).toBe(200);
      const body = response.json() as {
        data: { rows: unknown[] };
        meta: { total: number };
      };
      expect(body.data.rows).toBeInstanceOf(Array);
      expect(body.meta.total).toBeGreaterThanOrEqual(0);
    },
    testTimeout,
  );

  test(
    'GET /reports/trial-balance returns balanced totals',
    async () => {
      const config = loadAppConfig();
      const response = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/reports/trial-balance?period=this_month`,
        headers: getAuthHeaders(token),
      });

      expect(response.statusCode).toBe(200);
      const body = response.json() as {
        data: {
          rows: unknown[];
          total_debit: string;
          total_credit: string;
          is_balanced: boolean;
        };
      };
      expect(body.data.rows).toBeInstanceOf(Array);
      expect(body.data.total_debit).toBeDefined();
      expect(body.data.total_credit).toBeDefined();
      expect(body.data.is_balanced).toBe(true);
    },
    testTimeout,
  );

  test(
    'GET /reports/balance-sheet returns balanced assets and liabilities',
    async () => {
      const config = loadAppConfig();
      const response = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/reports/balance-sheet?period=this_month`,
        headers: getAuthHeaders(token),
      });

      expect(response.statusCode).toBe(200);
      const body = response.json() as {
        data: {
          assets: unknown[];
          liabilities: unknown[];
          assets_total: string;
          liabilities_total: string;
          is_balanced: boolean;
          as_on: string;
        };
      };
      expect(body.data.assets).toBeInstanceOf(Array);
      expect(body.data.liabilities).toBeInstanceOf(Array);
      expect(body.data.assets_total).toBeDefined();
      expect(body.data.liabilities_total).toBeDefined();
      expect(body.data.is_balanced).toBe(true);
      expect(body.data.as_on).toBeDefined();
    },
    testTimeout,
  );
});
