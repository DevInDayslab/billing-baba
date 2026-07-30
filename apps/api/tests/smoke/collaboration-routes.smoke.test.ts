import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../../src/app';
import { loadAppConfig } from '../../src/config/app_config';

describe('Collaboration route registration', () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    process.env.ENABLE_DEV_LOGIN = 'true';
    const config = loadAppConfig();
    app = await buildApp(config);
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  test('company directory routes exist (unauthenticated → 401, not 404)', async () => {
    const config = loadAppConfig();
    const prefix = `${config.apiPrefix}/collaboration`;

    const shared = await app.inject({
      method: 'GET',
      url: `${prefix}/companies/shared`,
    });
    expect(shared.statusCode).toBe(401);

    const invitations = await app.inject({
      method: 'GET',
      url: `${prefix}/companies/invitations`,
    });
    expect(invitations.statusCode).toBe(401);
  });

  test('core collaboration routes exist (unauthenticated → 401, not 404)', async () => {
    const config = loadAppConfig();
    const prefix = `${config.apiPrefix}/collaboration`;

    const members = await app.inject({
      method: 'GET',
      url: `${prefix}/company-members`,
    });
    expect(members.statusCode).toBe(401);

    const inviteList = await app.inject({
      method: 'GET',
      url: `${prefix}/invitations`,
    });
    expect(inviteList.statusCode).toBe(401);
  });
});
