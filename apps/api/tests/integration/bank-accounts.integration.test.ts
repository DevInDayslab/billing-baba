import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import { createTestApp, getAuthHeaders, login } from '../helpers/app';
import { canRunDbTests, INTEGRATION_TIMEOUT_MS } from '../helpers/env';

describe.skipIf(!canRunDbTests)('Bank accounts integration', () => {
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
    'lists cash account and returns balances',
    async () => {
      const config = loadAppConfig();
      const list = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/accounting/bank-accounts`,
        headers: getAuthHeaders(token),
      });
      expect(list.statusCode).toBe(200);
      const accounts = (list.json() as { data: { type: string }[] }).data;
      expect(accounts.some((a) => a.type === 'cash')).toBe(true);

      const balances = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/accounting/bank-accounts/balances`,
        headers: getAuthHeaders(token),
      });
      expect(balances.statusCode).toBe(200);
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
