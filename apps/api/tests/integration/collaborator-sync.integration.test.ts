import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import { randomUUID } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import { watermarkCursor } from '../../src/modules/sync/cursor';
import { loadAppConfig } from '../../src/config/app_config';
import {
  ensureAccount,
  issueTestSession,
} from '../helpers/auth-session';
import {
  createTestApp,
  jsonAuthHeaders,
  uniqueIndianMobile,
} from '../helpers/app';
import { canRunDbTests, INTEGRATION_TIMEOUT_MS } from '../helpers/env';

function syncHeaders(token: string, deviceId: string): Record<string, string> {
  return {
    ...jsonAuthHeaders(token),
    'x-device-id': deviceId,
    'x-app-version': '1.4.0',
    'x-sync-protocol-version': '1',
  };
}

describe.skipIf(!canRunDbTests)('Collaborator sync integration', () => {
  let app: FastifyInstance;
  let ownerToken: string;
  let businessId: string;
  const inviteePhone = uniqueIndianMobile('9');

  beforeAll(async () => {
    app = await createTestApp();
    const config = loadAppConfig();
    const ownerSession = await app.inject({
      method: 'POST',
      url: `${config.apiPrefix}/auth/dev-login`,
      payload: {},
    });
    const ownerBody = ownerSession.json() as {
      data: { access_token: string; refresh_token: string };
    };
    ownerToken = ownerBody.data.access_token;

    const me = await app.inject({
      method: 'GET',
      url: `${config.apiPrefix}/auth/me`,
      headers: jsonAuthHeaders(ownerToken),
    });
    businessId = (
      me.json() as { data: { businesses: Array<{ id: string }> } }
    ).data.businesses[0]!.id;
  });

  afterAll(async () => {
    await app.close();
  });

  test(
    'collaborator can accept invite, scope JWT, register device, and sync',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/collaboration`;
      const syncPrefix = `${config.apiPrefix}/sync`;

      const created = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {
          full_name: 'Sync Collaborator',
          phone_or_email: inviteePhone,
          role: 'biller',
        },
      });
      expect(created.statusCode).toBe(201);
      const inviteCode = (
        created.json() as { data: { invite_code: string } }
      ).data.invite_code;

      const inviteeAccountId = await ensureAccount(
        inviteePhone,
        'Sync Collaborator',
      );
      const inviteeSession = await issueTestSession(app, inviteeAccountId);

      const accepted = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations/${inviteCode}/accept`,
        headers: jsonAuthHeaders(inviteeSession.access_token),
        payload: {},
      });
      expect(accepted.statusCode).toBe(200);

      const scoped = await issueTestSession(
        app,
        inviteeAccountId,
        businessId,
      );
      expect(scoped.access_token).toBeTruthy();

      const me = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/auth/me`,
        headers: jsonAuthHeaders(scoped.access_token),
      });
      expect(me.statusCode).toBe(200);
      const businesses = (
        me.json() as { data: { businesses: Array<{ id: string }> } }
      ).data.businesses;
      expect(businesses.some((entry) => entry.id === businessId)).toBe(true);

      const permissions = await app.inject({
        method: 'GET',
        url: `${prefix}/permissions/me`,
        headers: jsonAuthHeaders(scoped.access_token),
      });
      expect(permissions.statusCode).toBe(200);
      const permissionBody = permissions.json() as {
        data: { access_kind: string; collaboration_role: string };
      };
      expect(permissionBody.data.access_kind).toBe('collaborator');
      expect(permissionBody.data.collaboration_role).toBe('biller');

      const deviceId = randomUUID();
      const registered = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/devices`,
        headers: syncHeaders(scoped.access_token, deviceId),
        payload: {
          device_id: deviceId,
          platform: 'android',
          app_version: '1.4.0',
          device_name: 'Collaborator Phone',
        },
      });
      expect(registered.statusCode).toBe(200);

      const status = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/status`,
        headers: syncHeaders(scoped.access_token, deviceId),
      });
      expect(status.statusCode).toBe(200);

      const pull = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/pull?cursor=${encodeURIComponent(watermarkCursor())}`,
        headers: syncHeaders(scoped.access_token, deviceId),
      });
      expect(pull.statusCode).toBe(200);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'accept rejects mismatched authenticated account',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/collaboration`;
      const otherPhone = uniqueIndianMobile('8');

      const created = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {
          full_name: 'Wrong Account',
          phone_or_email: otherPhone,
          role: 'salesman',
        },
      });
      const inviteCode = (
        created.json() as { data: { invite_code: string } }
      ).data.invite_code;

      const wrongAccountId = await ensureAccount(uniqueIndianMobile('7'));
      const wrongSession = await issueTestSession(app, wrongAccountId);

      const accepted = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations/${inviteCode}/accept`,
        headers: jsonAuthHeaders(wrongSession.access_token),
        payload: {},
      });
      expect(accepted.statusCode).toBe(403);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'accept requires authentication',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/collaboration`;
      const phone = uniqueIndianMobile('6');

      const created = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {
          full_name: 'Unauthenticated',
          phone_or_email: phone,
          role: 'salesman',
        },
      });
      const inviteCode = (
        created.json() as { data: { invite_code: string } }
      ).data.invite_code;

      const accepted = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations/${inviteCode}/accept`,
      });
      expect(accepted.statusCode).toBe(401);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'biller cannot push purchase documents',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/collaboration`;
      const syncPrefix = `${config.apiPrefix}/sync`;
      const phone = uniqueIndianMobile('5');

      const created = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {
          full_name: 'Purchase Blocked',
          phone_or_email: phone,
          role: 'biller',
        },
      });
      const inviteCode = (
        created.json() as { data: { invite_code: string } }
      ).data.invite_code;

      const accountId = await ensureAccount(phone, 'Purchase Blocked');
      const preAccept = await issueTestSession(app, accountId);
      await app.inject({
        method: 'POST',
        url: `${prefix}/invitations/${inviteCode}/accept`,
        headers: jsonAuthHeaders(preAccept.access_token),
        payload: {},
      });

      const scoped = await issueTestSession(app, accountId, businessId);
      const deviceId = randomUUID();
      await app.inject({
        method: 'POST',
        url: `${syncPrefix}/devices`,
        headers: syncHeaders(scoped.access_token, deviceId),
        payload: {
          device_id: deviceId,
          platform: 'android',
          app_version: '1.4.0',
          device_name: 'Biller Phone',
        },
      });

      const push = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(scoped.access_token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'purchase_documents',
              entity_id: randomUUID(),
              operation: 'create',
              base_sync_version: 0,
              client_updated_at: new Date().toISOString(),
              payload: {
                document_type: 'purchase_bill',
                status: 'draft',
              },
            },
          ],
        },
      });
      expect(push.statusCode).toBe(200);
      const body = push.json() as {
        data: { errors: Array<{ code: string }> };
      };
      expect(body.data.errors[0]?.code).toBe('FORBIDDEN');
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
