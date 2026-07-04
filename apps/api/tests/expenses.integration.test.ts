import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../src/app';
import { loadAppConfig } from '../src/config/app_config';

const hasDatabase = Boolean(process.env.DATABASE_URL);
const canRun = hasDatabase && process.env.JWT_SECRET;

function getAuthHeaders(token: string): Record<string, string> {
  return { authorization: `Bearer ${token}` };
}

function jsonAuthHeaders(token: string): Record<string, string> {
  return {
    authorization: `Bearer ${token}`,
    'content-type': 'application/json',
  };
}

async function login(app: FastifyInstance): Promise<string> {
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

describe.skipIf(!canRun)('expenses integration', () => {
  let app: FastifyInstance;
  let token: string;
  let categoryId: string;
  let expenseId: string;

  beforeAll(async () => {
    const config = loadAppConfig();
    app = await buildApp(config);
    token = await login(app);
    const config = loadAppConfig();

    const categoryRes = await app.inject({
      method: 'POST',
      url: `${config.apiPrefix}/purchases/expense-categories`,
      headers: jsonAuthHeaders(token),
      payload: { name: `Test Category ${Date.now()}`, category_type: 'direct' },
    });
    expect(categoryRes.statusCode).toBe(201);
    categoryId = (categoryRes.json() as { data: { id: string } }).data.id;
  });

  afterAll(async () => {
    await app.close();
  });

  test('creates expense and posts ledger', async () => {
    const config = loadAppConfig();
    const today = new Date().toISOString().slice(0, 10);

    const createRes = await app.inject({
      method: 'POST',
      url: `${config.apiPrefix}/purchases/expenses`,
      headers: jsonAuthHeaders(token),
      payload: {
        category_id: categoryId,
        amount: '1500.0000',
        expense_date: today,
        description: 'Office supplies',
        payment_mode: 'cash',
      },
    });
    expect(createRes.statusCode).toBe(201);
    const created = createRes.json() as {
      data: { id: string; amount: string };
    };
    expenseId = created.data.id;
    expect(created.data.amount).toBe('1500.0000');
  });

  test('lists expenses', async () => {
    const config = loadAppConfig();
    const listRes = await app.inject({
      method: 'GET',
      url: `${config.apiPrefix}/purchases/expenses`,
      headers: getAuthHeaders(token),
    });
    expect(listRes.statusCode).toBe(200);
    const body = listRes.json() as { data: unknown[]; meta: { total: number } };
    expect(body.data.length).toBeGreaterThan(0);
    expect(body.meta.total).toBeGreaterThan(0);
  });

  test('updates expense', async () => {
    const config = loadAppConfig();
    const updateRes = await app.inject({
      method: 'PATCH',
      url: `${config.apiPrefix}/purchases/expenses/${expenseId}`,
      headers: jsonAuthHeaders(token),
      payload: { amount: '1600.0000' },
    });
    expect(updateRes.statusCode).toBe(200);
    const body = updateRes.json() as { data: { amount: string } };
    expect(body.data.amount).toBe('1600.0000');
  });

  test('blocks duplicate category name', async () => {
    const config = loadAppConfig();
    const dupRes = await app.inject({
      method: 'POST',
      url: `${config.apiPrefix}/purchases/expense-categories`,
      headers: jsonAuthHeaders(token),
      payload: { name: 'Rent', category_type: 'direct' },
    });
    expect(dupRes.statusCode).toBe(409);
  });

  test('deletes expense', async () => {
    const config = loadAppConfig();
    const deleteRes = await app.inject({
      method: 'DELETE',
      url: `${config.apiPrefix}/purchases/expenses/${expenseId}`,
      headers: getAuthHeaders(token),
    });
    expect(deleteRes.statusCode).toBe(204);
  });
});
