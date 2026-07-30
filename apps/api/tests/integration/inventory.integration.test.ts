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

describe.skipIf(!canRunDbTests)('Inventory integration', () => {
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

  test(
    'categories CRUD',
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

      const fetched = await app.inject({
        method: 'GET',
        url: `${prefix}/${categoryId}`,
        headers: getAuthHeaders(token),
      });
      expect(fetched.statusCode).toBe(200);

      const updated = await app.inject({
        method: 'PATCH',
        url: `${prefix}/${categoryId}`,
        headers: jsonAuthHeaders(token),
        payload: { name: `${name}-updated` },
      });
      expect(updated.statusCode).toBe(200);

      const deleted = await app.inject({
        method: 'DELETE',
        url: `${prefix}/${categoryId}`,
        headers: getAuthHeaders(token),
      });
      expect(deleted.statusCode).toBe(204);
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
