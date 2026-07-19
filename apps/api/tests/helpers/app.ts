import { expect } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../../src/app';
import { loadAppConfig } from '../../src/config/app_config';
import { resetSharedNotificationService } from '../../src/modules/notifications/notification-service.factory';

export function getAuthHeaders(token: string): Record<string, string> {
  return { authorization: `Bearer ${token}` };
}

export function jsonAuthHeaders(token: string): Record<string, string> {
  return {
    authorization: `Bearer ${token}`,
    'content-type': 'application/json',
  };
}

export async function login(app: FastifyInstance): Promise<string> {
  const config = loadAppConfig();
  const response = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/auth/dev-login`,
    payload: {},
  });

  expect(response.statusCode).toBe(200);
  const body = response.json() as { data: { access_token: string } };
  return body.data.access_token;
}

export async function createTestApp(): Promise<FastifyInstance> {
  process.env.ENABLE_DEV_LOGIN = 'true';
  process.env.NODE_ENV = process.env.NODE_ENV ?? 'test';
  // Integration tests must not hit live Twilio (awaitDelivery / session window).
  process.env.NOTIFICATION_PROVIDER = 'console';
  resetSharedNotificationService();
  const config = loadAppConfig();
  const app = await buildApp(config);
  await app.ready();
  return app;
}

export function uniqueSuffix(): string {
  return Date.now().toString(36).slice(-6);
}

/** Unique valid Indian mobile E.164 for invite/party tests (always digits, starts 6–9). */
export function uniqueIndianMobile(prefixDigit = '8'): string {
  const lead = /^[6-9]$/.test(prefixDigit) ? prefixDigit : '8';
  const tail = `${Date.now()}${Math.floor(Math.random() * 1_000)}`.replace(
    /\D/g,
    '',
  );
  return `+91${lead}${tail.slice(-9)}`;
}
