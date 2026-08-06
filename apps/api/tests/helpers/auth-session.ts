import { createHash, randomBytes } from 'node:crypto';
import { expect } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import { getDb } from '../../src/db/client';
import { AuthRepository } from '../../src/modules/auth/auth.repository';

function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

export async function ensureAccount(
  phone: string,
  name = 'Test User',
): Promise<string> {
  const db = getDb();
  if (!db) {
    throw new Error('Database is not configured');
  }

  const authRepo = new AuthRepository(db);
  const existing = await authRepo.findAccountByPhone(phone);
  if (existing) {
    return existing.id;
  }

  const created = await authRepo.createAccount(phone, name);
  return created.id;
}

export async function issueTestSession(
  app: FastifyInstance,
  accountId: string,
  businessId?: string,
): Promise<{ access_token: string; refresh_token: string }> {
  const db = getDb();
  if (!db) {
    throw new Error('Database is not configured');
  }

  const authRepo = new AuthRepository(db);
  const memberships = await authRepo.findMembershipsByAccountId(accountId);
  const membership = businessId
    ? memberships.find((entry) => entry.businessId === businessId)
    : memberships[0];

  const refreshToken = randomBytes(32).toString('base64url');
  await authRepo.createRefreshToken({
    accountId,
    userId: membership?.userId,
    tokenHash: hashToken(refreshToken),
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });

  const config = loadAppConfig();
  const response = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/auth/refresh`,
    payload: {
      refresh_token: refreshToken,
      ...(businessId ? { business_id: businessId } : {}),
    },
  });

  expect(response.statusCode).toBe(200);
  return (response.json() as { data: { access_token: string; refresh_token: string } })
    .data;
}
