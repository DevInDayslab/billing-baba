import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../src/app';
import { loadAppConfig } from '../src/config/app_config';

const canRun = Boolean(process.env.DATABASE_URL) && process.env.JWT_SECRET;

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

describe.skipIf(!canRun)('Dashboard API integration', () => {
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
    'GET /dashboard returns aggregated payload',
    async () => {
      const config = loadAppConfig();
      const response = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/dashboard?period=this_month`,
        headers: getAuthHeaders(token),
      });

      expect(response.statusCode).toBe(200);
      const body = response.json() as { data: Record<string, unknown> };
      expect(body.data).toBeDefined();
      expect(body.data.overview).toBeDefined();
      expect(body.data.sales).toBeDefined();
      expect(body.data.purchases).toBeDefined();
      expect(body.data.finance).toBeDefined();
      expect(body.data.inventory).toBeDefined();
      expect(body.data.charts).toBeDefined();
      expect(body.data.recent_transactions).toBeInstanceOf(Array);
      expect(body.data.quick_reports).toBeInstanceOf(Array);
      expect(body.data.alerts).toEqual([]);
    },
    testTimeout,
  );

  test(
    'GET /dashboard rejects invalid period',
    async () => {
      const config = loadAppConfig();
      const response = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/dashboard?period=invalid`,
        headers: getAuthHeaders(token),
      });

      expect(response.statusCode).toBe(400);
    },
    testTimeout,
  );
});
