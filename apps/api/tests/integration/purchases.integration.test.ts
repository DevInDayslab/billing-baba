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

describe.skipIf(!canRunDbTests)('Purchases integration', () => {
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
    'purchase document draft CRUD',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const supplierId = await createParty(
        app,
        token,
        `${suffix}-supplier`,
        'supplier',
      );

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_order',
          document_series: `PO${suffix}`,
          party_id: supplierId,
        },
      });
      expect(created.statusCode).toBe(201);
      const docId = (created.json() as { data: { id: string } }).data.id;

      const fetched = await app.inject({
        method: 'GET',
        url: `${prefix}/${docId}`,
        headers: getAuthHeaders(token),
      });
      expect(fetched.statusCode).toBe(200);

      const updated = await app.inject({
        method: 'PATCH',
        url: `${prefix}/${docId}`,
        headers: jsonAuthHeaders(token),
        payload: { notes: 'Updated purchase order' },
      });
      expect(updated.statusCode).toBe(200);

      const deleted = await app.inject({
        method: 'DELETE',
        url: `${prefix}/${docId}`,
        headers: getAuthHeaders(token),
      });
      expect(deleted.statusCode).toBe(204);
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
