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

describe.skipIf(!canRunDbTests)('Payments integration', () => {
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
    'payments CRUD',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/accounting/payments`;
      const partyId = await createParty(app, token, `${suffix}-payment`);

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          party_id: partyId,
          direction: 'received',
          amount: '500',
          payment_mode: 'cash',
        },
      });
      expect(created.statusCode).toBe(201);
      const paymentId = (created.json() as { data: { id: string } }).data.id;

      const fetched = await app.inject({
        method: 'GET',
        url: `${prefix}/${paymentId}`,
        headers: getAuthHeaders(token),
      });
      expect(fetched.statusCode).toBe(200);

      const updated = await app.inject({
        method: 'PATCH',
        url: `${prefix}/${paymentId}`,
        headers: jsonAuthHeaders(token),
        payload: { notes: 'Updated payment' },
      });
      expect(updated.statusCode).toBe(200);

      const deleted = await app.inject({
        method: 'DELETE',
        url: `${prefix}/${paymentId}`,
        headers: getAuthHeaders(token),
      });
      expect(deleted.statusCode).toBe(204);
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
