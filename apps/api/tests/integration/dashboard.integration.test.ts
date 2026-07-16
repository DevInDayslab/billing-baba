import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import { createTestApp, getAuthHeaders, login } from '../helpers/app';
import { canRunDbTests, INTEGRATION_TIMEOUT_MS } from '../helpers/env';

describe.skipIf(!canRunDbTests)('Dashboard integration', () => {
  let app: FastifyInstance;
  let token: string;

  beforeAll(async () => {
    app = await createTestApp();
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
      expect(body.data.overview).toBeDefined();
      expect(body.data.sales).toBeDefined();
      expect(body.data.purchases).toBeDefined();
      expect(body.data.inventory).toBeDefined();
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
