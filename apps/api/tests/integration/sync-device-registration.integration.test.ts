import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import { randomUUID } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import { getDb } from '../../src/db/client';
import { AuthRepository } from '../../src/modules/auth/auth.repository';
import {
  createTestApp,
  jsonAuthHeaders,
  uniqueSuffix,
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

function businessIdFromToken(token: string): string {
  const payload = JSON.parse(
    Buffer.from(token.split('.')[1] ?? '', 'base64url').toString(),
  ) as { business_id: string };
  return payload.business_id;
}

type AuthSession = {
  access_token: string;
  refresh_token: string;
};

async function devLogin(app: FastifyInstance): Promise<AuthSession> {
  const config = loadAppConfig();
  const response = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/auth/dev-login`,
    payload: {},
  });
  expect(response.statusCode).toBe(200);
  return (response.json() as { data: AuthSession }).data;
}

async function refreshForBusiness(
  app: FastifyInstance,
  refreshToken: string,
  businessId: string,
): Promise<string> {
  const config = loadAppConfig();
  const response = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/auth/refresh`,
    payload: {
      refresh_token: refreshToken,
      business_id: businessId,
    },
  });
  expect(response.statusCode).toBe(200);
  return (response.json() as { data: { access_token: string } }).data
    .access_token;
}

async function registerDevice(
  app: FastifyInstance,
  syncPrefix: string,
  token: string,
  deviceId: string,
  overrides: Partial<{
    platform: string;
    app_version: string;
    device_name: string;
  }> = {},
) {
  return app.inject({
    method: 'POST',
    url: `${syncPrefix}/devices`,
    headers: syncHeaders(token, deviceId),
    payload: {
      device_id: deviceId,
      platform: overrides.platform ?? 'macos',
      app_version: overrides.app_version ?? '1.4.0',
      device_name: overrides.device_name ?? 'test-device',
    },
  });
}

describe.skipIf(!canRunDbTests)('Sync device registration integration', () => {
  let app: FastifyInstance;
  let syncPrefix: string;
  const suffix = uniqueSuffix();
  const deviceId = randomUUID();

  beforeAll(async () => {
    app = await createTestApp();
    const config = loadAppConfig();
    syncPrefix = `${config.apiPrefix}/sync`;
  });

  afterAll(async () => {
    await app.close();
  });

  test(
    'registers the same device for multiple businesses on one account',
    async () => {
      const session = await devLogin(app);
      const businessAId = businessIdFromToken(session.access_token);

      const regA = await registerDevice(
        app,
        syncPrefix,
        session.access_token,
        deviceId,
        { device_name: `device-a-${suffix}` },
      );
      expect(regA.statusCode).toBe(200);
      const regABody = regA.json() as {
        data: { device_id: string; business_id: string };
      };
      expect(regABody.data.device_id).toBe(deviceId);
      expect(regABody.data.business_id).toBe(businessAId);

      const config = loadAppConfig();
      const createBusiness = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/businesses`,
        headers: jsonAuthHeaders(session.access_token),
        payload: {
          name: `Second Business ${suffix}`,
          state_code: '27',
        },
      });
      expect(createBusiness.statusCode).toBe(201);
      const businessBId = (
        createBusiness.json() as { data: { id: string } }
      ).data.id;

      const tokenB = await refreshForBusiness(
        app,
        session.refresh_token,
        businessBId,
      );
      expect(businessIdFromToken(tokenB)).toBe(businessBId);

      const regB = await registerDevice(
        app,
        syncPrefix,
        tokenB,
        deviceId,
        { device_name: `device-b-${suffix}` },
      );
      expect(regB.statusCode).toBe(200);
      const regBBody = regB.json() as {
        data: { device_id: string; business_id: string };
      };
      expect(regBBody.data.device_id).toBe(deviceId);
      expect(regBBody.data.business_id).toBe(businessBId);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    're-registering for the same business is idempotent and updates metadata',
    async () => {
      const session = await devLogin(app);
      const localDeviceId = randomUUID();

      const first = await registerDevice(
        app,
        syncPrefix,
        session.access_token,
        localDeviceId,
        {
          app_version: '1.0.0',
          device_name: `first-${suffix}`,
        },
      );
      expect(first.statusCode).toBe(200);

      const second = await registerDevice(
        app,
        syncPrefix,
        session.access_token,
        localDeviceId,
        {
          app_version: '2.0.0',
          device_name: `reinstall-${suffix}`,
        },
      );
      expect(second.statusCode).toBe(200);
      const body = second.json() as {
        data: {
          device_id: string;
          app_version: string;
          device_name: string;
          last_sync_at: string | null;
        };
      };
      expect(body.data.device_id).toBe(localDeviceId);
      expect(body.data.app_version).toBe('2.0.0');
      expect(body.data.device_name).toBe(`reinstall-${suffix}`);
      expect(body.data.last_sync_at).not.toBeNull();
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'allows the same device_id for a different account business (JWT-scoped)',
    async () => {
      const sharedDeviceId = randomUUID();
      const ownerSession = await devLogin(app);
      const ownerReg = await registerDevice(
        app,
        syncPrefix,
        ownerSession.access_token,
        sharedDeviceId,
      );
      expect(ownerReg.statusCode).toBe(200);

      const db = getDb();
      expect(db).not.toBeNull();
      const authRepo = new AuthRepository(db!);
      const otherAccount = await authRepo.createAccount(
        `+9198${suffix}${Math.floor(Math.random() * 10_000)
          .toString()
          .padStart(4, '0')}`.slice(0, 13),
        'Other Account',
      );
      const otherMembership = await authRepo.createBusinessWithOwner({
        accountId: otherAccount.id,
        businessName: `Other Business ${suffix}`,
        ownerName: 'Other Owner',
        phone: `98${suffix}`.slice(0, 10),
      });

      const otherToken = app.jwt.sign({
        account_id: otherAccount.id,
        phone: otherAccount.phone,
        user_id: otherMembership.userId,
        business_id: otherMembership.businessId,
        role: otherMembership.role,
      });

      const allowed = await registerDevice(
        app,
        syncPrefix,
        otherToken,
        sharedDeviceId,
      );
      expect(allowed.statusCode).toBe(200);
      const body = allowed.json() as {
        data: { device_id: string; business_id: string };
      };
      expect(body.data.device_id).toBe(sharedDeviceId);
      expect(body.data.business_id).toBe(otherMembership.businessId);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'sync startup after business switch: register then status succeeds',
    async () => {
      const session = await devLogin(app);
      const startupDeviceId = randomUUID();

      const regA = await registerDevice(
        app,
        syncPrefix,
        session.access_token,
        startupDeviceId,
      );
      expect(regA.statusCode).toBe(200);

      const config = loadAppConfig();
      const createBusiness = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/businesses`,
        headers: jsonAuthHeaders(session.access_token),
        payload: {
          name: `Switch Business ${suffix}`,
          state_code: '27',
        },
      });
      expect(createBusiness.statusCode).toBe(201);
      const businessBId = (
        createBusiness.json() as { data: { id: string } }
      ).data.id;

      const tokenB = await refreshForBusiness(
        app,
        session.refresh_token,
        businessBId,
      );

      const regB = await registerDevice(
        app,
        syncPrefix,
        tokenB,
        startupDeviceId,
      );
      expect(regB.statusCode).toBe(200);

      const status = await app.inject({
        method: 'GET',
        url: `${syncPrefix}/status`,
        headers: syncHeaders(tokenB, startupDeviceId),
      });
      expect(status.statusCode).toBe(200);
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
