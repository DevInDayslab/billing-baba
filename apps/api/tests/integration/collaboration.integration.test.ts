import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import {
  createTestApp,
  getAuthHeaders,
  jsonAuthHeaders,
  login,
  uniqueIndianMobile,
} from '../helpers/app';
import { canRunDbTests, INTEGRATION_TIMEOUT_MS } from '../helpers/env';

describe.skipIf(!canRunDbTests)('Collaboration integration', () => {
  let app: FastifyInstance;
  let ownerToken: string;
  let businessId: string;
  const inviteePhone = uniqueIndianMobile('9');

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
      const rejectPhone = uniqueIndianMobile('8');

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
      const reinvitePhone = uniqueIndianMobile('7');

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
      const cancelPhone = uniqueIndianMobile('6');

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

  test(
    'company directory: list shared companies and pending invitations',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/collaboration`;

      const shared = await app.inject({
        method: 'GET',
        url: `${prefix}/companies/shared`,
        headers: jsonAuthHeaders(ownerToken),
      });
      expect(shared.statusCode).toBe(200);
      const sharedBody = shared.json() as { data: unknown[] };
      expect(Array.isArray(sharedBody.data)).toBe(true);

      const pending = await app.inject({
        method: 'GET',
        url: `${prefix}/companies/invitations`,
        headers: jsonAuthHeaders(ownerToken),
      });
      expect(pending.statusCode).toBe(200);
      const pendingBody = pending.json() as { data: unknown[] };
      expect(Array.isArray(pendingBody.data)).toBe(true);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'member management: list, update role, remove joined member',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/collaboration`;
      const memberPhone = uniqueIndianMobile('9');

      const created = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations`,
        headers: jsonAuthHeaders(ownerToken),
        payload: {
          full_name: 'Member Mgmt User',
          phone_or_email: memberPhone,
          role: 'biller',
        },
      });
      expect(created.statusCode).toBe(201);
      const invite = (
        created.json() as {
          data: { member_id: string; invite_code: string };
        }
      ).data;

      const listed = await app.inject({
        method: 'GET',
        url: `${prefix}/company-members`,
        headers: jsonAuthHeaders(ownerToken),
      });
      expect(listed.statusCode).toBe(200);
      const members = (listed.json() as { data: Array<{ id: string }> }).data;
      expect(members.some((m) => m.id.startsWith('owner-'))).toBe(true);
      expect(members.some((m) => m.id === invite.member_id)).toBe(true);

      const roleUpdated = await app.inject({
        method: 'PATCH',
        url: `${prefix}/company-members/${invite.member_id}`,
        headers: jsonAuthHeaders(ownerToken),
        payload: { role: 'salesman' },
      });
      expect(roleUpdated.statusCode).toBe(200);
      expect((roleUpdated.json() as { data: { role: string } }).data.role).toBe(
        'salesman',
      );

      await app.inject({
        method: 'GET',
        url: `${prefix}/invitations/${invite.invite_code}`,
      });

      const accepted = await app.inject({
        method: 'POST',
        url: `${prefix}/invitations/${invite.invite_code}/accept`,
      });
      expect(accepted.statusCode).toBe(200);

      const removed = await app.inject({
        method: 'DELETE',
        url: `${prefix}/company-members/${invite.member_id}`,
        headers: getAuthHeaders(ownerToken),
      });
      expect(removed.statusCode).toBe(200);

      const ownerDelete = await app.inject({
        method: 'DELETE',
        url: `${prefix}/company-members/owner-${businessId}`,
        headers: getAuthHeaders(ownerToken),
      });
      expect(ownerDelete.statusCode).toBe(403);
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
