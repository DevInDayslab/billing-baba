import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import {
  createTestApp,
  getAuthHeaders,
  jsonAuthHeaders,
  login,
} from '../helpers/app';
import { canRunDbTests, INTEGRATION_TIMEOUT_MS } from '../helpers/env';

describe.skipIf(!canRunDbTests)('Party contact import integration', () => {
  let app: FastifyInstance;
  let ownerToken: string;
  let businessId: string;

  beforeAll(async () => {
    app = await createTestApp();
    ownerToken = await login(app);

    const config = loadAppConfig();
    const me = await app.inject({
      method: 'GET',
      url: `${config.apiPrefix}/auth/me`,
      headers: jsonAuthHeaders(ownerToken),
    });
    expect(me.statusCode).toBe(200);
    const meBody = me.json() as {
      data: { businesses: Array<{ id: string }> };
    };
    businessId = meBody.data.businesses[0]?.id ?? '';
    expect(businessId).toBeTruthy();
  });

  afterAll(async () => {
    await app.close();
  });

  test(
    'session lifecycle: create, stage contacts, poll, commit',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/parties`;

      const created = await app.inject({
        method: 'POST',
        url: `${prefix}/contact-import-sessions`,
        headers: getAuthHeaders(ownerToken, businessId),
      });
      expect(created.statusCode).toBe(201);
      const createBody = created.json() as {
        data: {
          session_id: string;
          token: string;
          web_url: string;
          qr_data_url: string;
        };
      };
      const sessionId = createBody.data.session_id;
      const token = createBody.data.token;
      expect(sessionId).toBeTruthy();
      expect(token).toBeTruthy();
      expect(createBody.data.web_url).toContain(token);
      expect(createBody.data.qr_data_url.startsWith('data:image')).toBe(true);

      const publicMeta = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/public/party-contact-import/${token}`,
      });
      expect(publicMeta.statusCode).toBe(200);

      const opened = await app.inject({
        method: 'GET',
        url: `${prefix}/contact-import-sessions/by-token/${token}`,
        headers: jsonAuthHeaders(ownerToken),
      });
      expect(opened.statusCode).toBe(200);
      const openedBody = opened.json() as { data: { status: string } };
      expect(openedBody.data.status).toBe('opened');

      const staged = await app.inject({
        method: 'PUT',
        url: `${prefix}/contact-import-sessions/by-token/${token}/staging`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {
          contacts: [
            {
              display_name: 'Import Test Party',
              phones: ['9876543210'],
              email: 'test@example.com',
            },
          ],
        },
      });
      expect(staged.statusCode).toBe(200);
      const stagedBody = staged.json() as {
        data: { status: string; staging_count: number };
      };
      expect(stagedBody.data.status).toBe('submitted');
      expect(stagedBody.data.staging_count).toBe(1);

      const polled = await app.inject({
        method: 'GET',
        url: `${prefix}/contact-import-sessions/${sessionId}?include_staging=true`,
        headers: getAuthHeaders(ownerToken, businessId),
      });
      expect(polled.statusCode).toBe(200);
      const polledBody = polled.json() as {
        data: {
          status: string;
          staging_rows?: Array<{ display_name: string }>;
        };
      };
      expect(polledBody.data.status).toBe('submitted');
      expect(polledBody.data.staging_rows?.length).toBe(1);

      const committed = await app.inject({
        method: 'POST',
        url: `${prefix}/contact-import-sessions/${sessionId}/commit`,
        headers: getAuthHeaders(ownerToken, businessId),
      });
      expect(committed.statusCode).toBe(200);
      const committedBody = committed.json() as { data: { status: string } };
      expect(committedBody.data.status).toBe('completed');
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
