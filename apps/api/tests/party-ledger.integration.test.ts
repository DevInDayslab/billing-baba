import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../src/app';
import { loadAppConfig } from '../src/config/app_config';
import { getDb } from '../src/db/client';
import { OutstandingRepository } from '../src/modules/accounting/outstanding.repository';
import { buildPartyLedgerReport } from '../src/shared/reporting/party-ledger';

const canRun = Boolean(process.env.DATABASE_URL) && process.env.JWT_SECRET;

function getAuthHeaders(token: string): Record<string, string> {
  return { authorization: `Bearer ${token}` };
}

function jsonAuthHeaders(token: string): Record<string, string> {
  return {
    authorization: `Bearer ${token}`,
    'content-type': 'application/json',
  };
}

function businessIdFromToken(token: string): string {
  const payload = JSON.parse(
    Buffer.from(token.split('.')[1] ?? '', 'base64url').toString(),
  ) as { business_id: string };
  return payload.business_id;
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

async function createInventoryFixtures(
  app: FastifyInstance,
  token: string,
  suffix: string,
) {
  const config = loadAppConfig();

  const godowns = await app.inject({
    method: 'GET',
    url: `${config.apiPrefix}/inventory/godowns`,
    headers: getAuthHeaders(token),
  });
  const defaultGodown = (
    godowns.json() as { data: { id: string; is_default: boolean }[] }
  ).data.find((row) => row.is_default);
  expect(defaultGodown).toBeDefined();

  const unitRes = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/inventory/units`,
    headers: jsonAuthHeaders(token),
    payload: {
      name: `LedgerUnit-${suffix}`,
      short_name: `LU${suffix}`,
    },
  });
  expect(unitRes.statusCode).toBe(201);
  const unitShortName = (unitRes.json() as { data: { short_name: string } })
    .data.short_name;

  const itemRes = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/inventory/items`,
    headers: jsonAuthHeaders(token),
    payload: {
      name: `LedgerItem-${suffix}`,
      item_type: 'product',
      base_unit: unitShortName,
      opening_quantity: '20',
      opening_cost_per_unit: '100',
      opening_godown_id: defaultGodown?.id,
      sale_price: '150',
    },
  });
  expect(itemRes.statusCode).toBe(201);
  const itemId = (itemRes.json() as { data: { id: string } }).data.id;

  return { itemId, unitShortName };
}

describe.skipIf(!canRun)('Party ledger API integration', () => {
  let app: FastifyInstance;
  let token: string;
  const suffix = Date.now().toString(36).slice(-6);
  const testTimeout = 45_000;

  beforeAll(async () => {
    process.env.ENABLE_DEV_LOGIN = 'true';
    process.env.NODE_ENV = process.env.NODE_ENV ?? 'test';
    const config = loadAppConfig();
    app = await buildApp(config);
    await app.ready();
    token = await login(app);
  });

  afterAll(async () => {
    await app.close();
  });

  test(
    'GET /parties/:id/ledger reflects invoice, payment, and filters',
    async () => {
      const config = loadAppConfig();
      const salesPrefix = `${config.apiPrefix}/sales/sales-documents`;
      const paymentsPrefix = `${config.apiPrefix}/accounting/payments`;
      const { itemId, unitShortName } = await createInventoryFixtures(
        app,
        token,
        suffix,
      );

      const partyRes = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/parties`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `LedgerCustomer-${suffix}`,
          party_type: 'customer',
          state_code: '27',
          opening_balance: '500',
        },
      });
      expect(partyRes.statusCode).toBe(201);
      const partyId = (partyRes.json() as { data: { id: string } }).data.id;

      const created = await app.inject({
        method: 'POST',
        url: salesPrefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'tax_invoice',
          document_series: 'INV',
          party_id: partyId,
          is_gst_formal: true,
          party_state_code: '27',
        },
      });
      const docId = (created.json() as { data: { id: string } }).data.id;

      await app.inject({
        method: 'POST',
        url: `${salesPrefix}/${docId}/lines`,
        headers: jsonAuthHeaders(token),
        payload: {
          item_id: itemId,
          quantity: '1',
          unit: unitShortName,
          unit_price: '100',
          tax_rate: '18',
        },
      });

      await app.inject({
        method: 'POST',
        url: `${salesPrefix}/${docId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: {},
      });

      const detail = await app.inject({
        method: 'GET',
        url: `${salesPrefix}/${docId}`,
        headers: getAuthHeaders(token),
      });
      const total = (detail.json() as { data: { total_amount: string } }).data
        .total_amount;

      await app.inject({
        method: 'POST',
        url: paymentsPrefix,
        headers: jsonAuthHeaders(token),
        payload: {
          party_id: partyId,
          direction: 'received',
          amount: total,
          payment_mode: 'cash',
          allocations: [
            {
              sales_document_id: docId,
              allocated_amount: total,
            },
          ],
        },
      });

      const partyDetail = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/parties/${partyId}`,
        headers: getAuthHeaders(token),
      });
      expect(partyDetail.statusCode).toBe(200);
      const partyBody = partyDetail.json() as {
        data: { balance: string; opening_balance: string };
      };
      expect(Number(partyBody.data.opening_balance)).toBe(500);
      expect(Number(partyBody.data.balance)).toBe(500);

      const ledgerRes = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/parties/${partyId}/ledger`,
        headers: getAuthHeaders(token),
      });
      expect(ledgerRes.statusCode).toBe(200);
      const ledger = ledgerRes.json() as {
        data: {
          summary: {
            opening_balance: string;
            outstanding: string;
            receive_amount: string;
            payable_amount: string;
            total_sales: string;
          };
          transactions: {
            entry_type: string;
            type: string;
          }[];
        };
      };

      expect(Number(ledger.data.summary.opening_balance)).toBe(500);
      expect(Number(ledger.data.summary.outstanding)).toBe(500);
      expect(Number(ledger.data.summary.receive_amount)).toBe(500);
      expect(Number(ledger.data.summary.payable_amount)).toBe(0);
      expect(Number(ledger.data.summary.total_sales)).toBeGreaterThan(0);
      expect(ledger.data.transactions.length).toBeGreaterThanOrEqual(2);
      expect(
        ledger.data.transactions.some((row) => row.entry_type === 'sale'),
      ).toBe(true);
      expect(
        ledger.data.transactions.some((row) => row.entry_type === 'payment'),
      ).toBe(true);

      const salesFilter = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/parties/${partyId}/ledger?filter=sales`,
        headers: getAuthHeaders(token),
      });
      const salesBody = salesFilter.json() as {
        data: { transactions: { entry_type: string }[] };
      };
      expect(
        salesBody.data.transactions.every((row) => row.entry_type === 'sale'),
      ).toBe(true);
    },
    testTimeout,
  );

  test(
    'party with no transactions returns opening balance only',
    async () => {
      const config = loadAppConfig();
      const partyRes = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/parties`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `EmptyParty-${suffix}`,
          party_type: 'customer',
          opening_balance: '1000',
        },
      });
      const partyId = (partyRes.json() as { data: { id: string } }).data.id;

      const ledgerRes = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/parties/${partyId}/ledger`,
        headers: getAuthHeaders(token),
      });
      expect(ledgerRes.statusCode).toBe(200);
      const ledger = ledgerRes.json() as {
        data: {
          summary: { outstanding: string };
          transactions: unknown[];
        };
      };
      expect(Number(ledger.data.summary.outstanding)).toBe(1000);
      expect(ledger.data.transactions).toEqual([]);
    },
    testTimeout,
  );

  test(
    'outstanding repository matches shared ledger engine',
    async () => {
      const db = getDb();
      if (!db) return;

      const businessId = businessIdFromToken(token);
      const listRes = await app.inject({
        method: 'GET',
        url: `${loadAppConfig().apiPrefix}/parties?limit=100&q=Sharma+Electrical`,
        headers: getAuthHeaders(token),
      });
      const party = (listRes.json() as { data: { id: string }[] }).data[0];
      if (!party) return;

      const report = await buildPartyLedgerReport(db, businessId, party.id);
      const outstandingRepo = new OutstandingRepository(db);
      const repoBalance = await outstandingRepo.getPartyBalance(
        businessId,
        party.id,
      );

      expect(Number(repoBalance)).toBeCloseTo(report.summary.outstanding, 2);
      expect(report.summary.totalSales).toBeGreaterThanOrEqual(0);
      expect(report.summary.totalPayments).toBeGreaterThanOrEqual(0);
    },
    testTimeout,
  );
});
