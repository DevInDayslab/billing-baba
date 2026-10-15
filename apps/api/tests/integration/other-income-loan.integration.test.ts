import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import { createTestApp, getAuthHeaders, login } from '../helpers/app';
import { canRunDbTests, INTEGRATION_TIMEOUT_MS } from '../helpers/env';

describe.skipIf(!canRunDbTests)('Other income and loan reports integration', () => {
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
    'other income list report returns paginated payload',
    async () => {
      const config = loadAppConfig();
      const res = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/reports/other-income?from=2025-01-01&to=2026-12-31&page=1&limit=10`,
        headers: getAuthHeaders(token),
      });
      expect(res.statusCode).toBe(200);
      const body = res.json() as { data: { rows: unknown[] }; meta: { total: number } };
      expect(Array.isArray(body.data.rows)).toBe(true);
      expect(typeof body.meta.total).toBe('number');
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'loan statement requires loan_account',
    async () => {
      const config = loadAppConfig();
      const res = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/reports/loan-statement?from=2025-01-01&to=2026-12-31`,
        headers: getAuthHeaders(token),
      });
      expect(res.statusCode).toBeGreaterThanOrEqual(400);
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
