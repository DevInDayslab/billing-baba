import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import {
  createTestApp,
  getAuthHeaders,
  jsonAuthHeaders,
  uniqueSuffix,
} from '../helpers/app';
import { canRunDbTests, INTEGRATION_TIMEOUT_MS } from '../helpers/env';

describe.skipIf(!canRunDbTests)('Collaboration integration', () => {
  let app: FastifyInstance;
  let ownerToken: string;
  let businessId: string;
  const suffix = uniqueSuffix();
  const inviteePhone = `+9199${suffix.padStart(8, '0').slice(-8)}`;

  beforeAll(async () => {
    app = await createTestApp();
    const config = loadAppConfig();

    const loginResponse = await app.inject({
      method: 'POST',
      url: `${config.apiPrefix}/auth/dev-login`,
      payload: {},
    });
    const loginBody = loginResponse.json() as {
      data: {
        access_token: string;
        refresh_token: string;
        businesses?: Array<{ id: string }>;
      };
    };
    ownerToken = loginBody.data.access_token;

    const me = await app.inject({
      method: 'GET',
      url: `${config.apiPrefix}/auth/me`,
      headers: jsonAuthHeaders(ownerToken),
    });
    const meBody = me.json() as {
      data: { businesses: Array<{ id: string }> };
    };
    businessId = meBody.data.businesses[0]?.id ?? '';

    if (!businessId) {
      const created = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/businesses`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {
          name: `Collab Biz ${suffix}`,
          state_code: '27',
        },
      });
      businessId = (created.json() as { data: { id: string } }).data.id;
    }

    const refresh = await app.inject({
      method: 'POST',
      url: `${config.apiPrefix}/auth/refresh`,
      headers: { 'content-type': 'application/json' },
      payload: {
        refresh_token: loginBody.data.refresh_token,
        business_id: businessId,
      },
    });
    ownerToken = (refresh.json() as { data: { access_token: string } }).data
      .access_token;
  });

  afterAll(async () => {
    await app.close();
  });

  test(
    'invitation lifecycle: create, open, accept, list shared',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/collaboration`;

      const created = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {
          full_name: 'Invitee User',
          phone_or_email: inviteePhone,
          role: 'biller',
        },
      });
      expect(created.statusCode).toBe(201);
      const invitation = (created.json() as { data: { invite_code: string } })
        .data;
      const token = invitation.invite_code;

      const firstGet = await app.inject({
        method: 'GET',
        url: `${prefix}/invitations/${token}`,
      });
      expect(firstGet.statusCode).toBe(200);
      const opened = (firstGet.json() as { data: { status: string } }).data;
      expect(opened.status).toBe('opened');

      const secondGet = await app.inject({
        method: 'GET',
        url: `${prefix}/invitations/${token}`,
      });
      expect(secondGet.statusCode).toBe(200);

      const accepted = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations/${token}/accept`,
      });
      expect(accepted.statusCode).toBe(200);
      const acceptBody = accepted.json() as {
        data: { member_id: string };
      };
      expect(acceptBody.data.member_id).toBeTruthy();

      const doubleAccept = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations/${token}/accept`,
      });
      expect(doubleAccept.statusCode).toBe(409);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'reject invitation flow',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/collaboration`;
      const rejectPhone = `+9198${suffix.padStart(8, '1').slice(-8)}`;

      const created = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {
          full_name: 'Reject User',
          phone_or_email: rejectPhone,
          role: 'salesman',
        },
      });
      expect(created.statusCode).toBe(201);
      const token = (created.json() as { data: { invite_code: string } }).data
        .invite_code;

      await app.inject({
        method: 'GET',
        url: `${prefix}/invitations/${token}`,
      });

      const rejected = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations/${token}/reject`,
      });
      expect(rejected.statusCode).toBe(200);
      const status = (rejected.json() as { data: { status: string } }).data
        .status;
      expect(status).toBe('rejected');
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'reinvite cancels prior invitation',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/collaboration`;
      const reinvitePhone = `+9197${suffix.padStart(8, '2').slice(-8)}`;

      const created = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {
          full_name: 'Reinvite User',
          phone_or_email: reinvitePhone,
          role: 'stock_keeper',
        },
      });
      const first = (
        created.json() as {
          data: { id: string; invite_code: string };
        }
      ).data;

      await app.inject({
        method: 'POST',
        url: `${prefix}/invitations/${first.invite_code}/reject`,
      });

      const reinvited = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations/reinvite/${first.id}`,
        headers: getAuthHeaders(ownerToken),
      });
      expect(reinvited.statusCode).toBe(201);
      const newInvite = (reinvited.json() as { data: { invite_code: string } })
        .data;
      expect(newInvite.invite_code).not.toBe(first.invite_code);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'list invitations and cancel pending invite',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/collaboration`;
      const cancelPhone = `+9196${suffix.padStart(8, '3').slice(-8)}`;

      const created = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {
          full_name: 'Cancel User',
          phone_or_email: cancelPhone,
          role: 'accountant',
        },
      });
      expect(created.statusCode).toBe(201);
      const createdBody = created.json() as {
        data: { id: string; status: string };
      };

      const listed = await app.inject({
        method: 'GET',
        url: `${prefix}/invitations`,
        headers: jsonAuthHeaders(ownerToken),
      });
      expect(listed.statusCode).toBe(200);
      const listBody = listed.json() as {
        data: Array<{ id: string; status: string; invite_code: string }>;
      };
      const listedInvite = listBody.data.find(
        (item) => item.id === createdBody.data.id,
      );
      expect(listedInvite).toBeTruthy();
      expect(listedInvite!.invite_code.length).toBeGreaterThan(0);

      const cancelled = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations/${createdBody.data.id}/cancel`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {},
      });
      expect(cancelled.statusCode).toBe(200);
      const cancelBody = cancelled.json() as { data: { status: string } };
      expect(cancelBody.data.status).toBe('cancelled');
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
