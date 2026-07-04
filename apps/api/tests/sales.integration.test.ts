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
  const body = response.json() as {
    data: { access_token: string };
  };
  return body.data.access_token;
}

async function createSalesFixtures(
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
      name: `SalesUnit-${suffix}`,
      short_name: `SU${suffix}`,
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
      name: `SalesItem-${suffix}`,
      item_type: 'product',
      base_unit: unitShortName,
      opening_quantity: '10',
      opening_cost_per_unit: '100',
      opening_godown_id: defaultGodown?.id,
      sale_price: '150',
    },
  });
  expect(itemRes.statusCode).toBe(201);
  const itemId = (itemRes.json() as { data: { id: string } }).data.id;

  const partyRes = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/parties`,
    headers: jsonAuthHeaders(token),
    payload: {
      name: `Customer-${suffix}`,
      party_type: 'customer',
      state_code: '27',
    },
  });
  expect(partyRes.statusCode).toBe(201);
  const partyId = (partyRes.json() as { data: { id: string } }).data.id;

  return { itemId, partyId, unitShortName, defaultGodownId: defaultGodown!.id };
}

describe.skipIf(!canRun)('Sales API integration', () => {
  let app: FastifyInstance;
  let token: string;
  const suffix = Date.now().toString(36).slice(-6);
  const testTimeout = 30_000;

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
    'estimate draft CRUD',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/sales/sales-documents`;

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'estimate',
          document_series: `EST${suffix}`,
        },
      });
      expect(created.statusCode).toBe(201);
      const docId = (created.json() as { data: { id: string } }).data.id;

      const fetched = await app.inject({
        method: 'GET',
        url: `${prefix}/${docId}`,
        headers: getAuthHeaders(token),
      });
      expect(fetched.statusCode).toBe(200);

      const updated = await app.inject({
        method: 'PATCH',
        url: `${prefix}/${docId}`,
        headers: jsonAuthHeaders(token),
        payload: { notes: 'Updated estimate' },
      });
      expect(updated.statusCode).toBe(200);

      const deleted = await app.inject({
        method: 'DELETE',
        url: `${prefix}/${docId}`,
        headers: getAuthHeaders(token),
      });
      expect(deleted.statusCode).toBe(204);
    },
    testTimeout,
  );

  test(
    'lines update document totals',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/sales/sales-documents`;
      const { itemId, partyId, unitShortName } = await createSalesFixtures(
        app,
        token,
        suffix,
      );

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'tax_invoice',
          document_series: 'INV',
          party_id: partyId,
          is_gst_formal: true,
          party_state_code: '27',
        },
      });
      expect(created.statusCode).toBe(201);
      const docId = (created.json() as { data: { id: string } }).data.id;

      const line = await app.inject({
        method: 'POST',
        url: `${prefix}/${docId}/lines`,
        headers: jsonAuthHeaders(token),
        payload: {
          item_id: itemId,
          quantity: '2',
          unit: unitShortName,
          unit_price: '100',
          tax_rate: '18',
        },
      });
      expect(line.statusCode).toBe(201);

      const detail = await app.inject({
        method: 'GET',
        url: `${prefix}/${docId}`,
        headers: getAuthHeaders(token),
      });
      expect(detail.statusCode).toBe(200);
      const body = detail.json() as {
        data: { total_amount: string; lines: unknown[] };
      };
      expect(body.data.lines.length).toBe(1);
      expect(parseFloat(body.data.total_amount)).toBeGreaterThan(0);
    },
    testTimeout,
  );

  test(
    'finalize guards',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/sales/sales-documents`;

      const emptyDraft = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'estimate',
          document_series: `EG${suffix}`,
        },
      });
      const emptyId = (emptyDraft.json() as { data: { id: string } }).data.id;

      const emptyFinalize = await app.inject({
        method: 'POST',
        url: `${prefix}/${emptyId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: {},
      });
      expect(emptyFinalize.statusCode).toBe(422);

      const cancelDraft = await app.inject({
        method: 'POST',
        url: `${prefix}/${emptyId}/cancel`,
        headers: getAuthHeaders(token),
      });
      expect(cancelDraft.statusCode).toBe(409);
    },
    testTimeout,
  );

  test(
    'finalize assigns number and deducts stock',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/sales/sales-documents`;
      const { itemId, partyId, unitShortName } = await createSalesFixtures(
        app,
        token,
        `${suffix}-fin`,
      );

      const created = await app.inject({
        method: 'POST',
        url: prefix,
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
        url: `${prefix}/${docId}/lines`,
        headers: jsonAuthHeaders(token),
        payload: {
          item_id: itemId,
          quantity: '2',
          unit: unitShortName,
          unit_price: '100',
          tax_rate: '18',
        },
      });

      const finalized = await app.inject({
        method: 'POST',
        url: `${prefix}/${docId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: {},
      });
      expect(finalized.statusCode).toBe(200);
      const finBody = finalized.json() as {
        data: { document_number: string; status: string };
      };
      expect(finBody.data.document_number).toBeTruthy();
      expect(finBody.data.status).toBe('finalized');

      const stock = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/stock-levels?item_id=${itemId}`,
        headers: getAuthHeaders(token),
      });
      const stockQty = (
        stock.json() as { data: { quantity: string }[] }
      ).data[0]?.quantity;
      expect(stockQty).toBe('8.0000');

      const movements = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/movements?item_id=${itemId}`,
        headers: getAuthHeaders(token),
      });
      const movementBody = movements.json() as {
        data: { movement_type: string }[];
      };
      expect(
        movementBody.data.some((row) => row.movement_type === 'sale'),
      ).toBe(true);
    },
    testTimeout,
  );

  test(
    'auto-bootstraps document sequence for new series on finalize',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/sales/sales-documents`;
      const series = `EST${suffix}`;
      const { itemId, unitShortName } = await createSalesFixtures(
        app,
        token,
        `${suffix}-seq`,
      );

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'estimate',
          document_series: series,
        },
      });
      const docId = (created.json() as { data: { id: string } }).data.id;

      await app.inject({
        method: 'POST',
        url: `${prefix}/${docId}/lines`,
        headers: jsonAuthHeaders(token),
        payload: {
          item_id: itemId,
          quantity: '1',
          unit: unitShortName,
          unit_price: '50',
        },
      });

      const finalized = await app.inject({
        method: 'POST',
        url: `${prefix}/${docId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: {},
      });
      expect(finalized.statusCode).toBe(200);

      const sequences = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/sales/document-sequences`,
        headers: getAuthHeaders(token),
      });
      expect(sequences.statusCode).toBe(200);
      const seqBody = sequences.json() as {
        data: { document_series: string }[];
      };
      expect(
        seqBody.data.some((row) => row.document_series === series),
      ).toBe(true);
    },
    testTimeout,
  );

  test(
    'payment allocation validates remaining balance',
    async () => {
      const config = loadAppConfig();
      const salesPrefix = `${config.apiPrefix}/sales/sales-documents`;
      const paymentsPrefix = `${config.apiPrefix}/accounting/payments`;
      const { itemId, partyId, unitShortName } = await createSalesFixtures(
        app,
        token,
        `${suffix}-pay`,
      );

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

      const payment = await app.inject({
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
      expect(payment.statusCode).toBe(201);

      const overAllocate = await app.inject({
        method: 'POST',
        url: paymentsPrefix,
        headers: jsonAuthHeaders(token),
        payload: {
          party_id: partyId,
          direction: 'received',
          amount: '10',
          payment_mode: 'cash',
          allocations: [
            {
              sales_document_id: docId,
              allocated_amount: '10',
            },
          ],
        },
      });
      expect(overAllocate.statusCode).toBe(422);
    },
    testTimeout,
  );

  test(
    'convert applies GST and blocks invalid transitions',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/sales/sales-documents`;
      const { itemId, partyId, unitShortName } = await createSalesFixtures(
        app,
        token,
        `${suffix}-cvt`,
      );

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'normal_invoice',
          document_series: 'KINV',
          party_id: partyId,
          is_gst_formal: false,
        },
      });
      const docId = (created.json() as { data: { id: string } }).data.id;

      await app.inject({
        method: 'POST',
        url: `${prefix}/${docId}/lines`,
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
        url: `${prefix}/${docId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: {},
      });

      const converted = await app.inject({
        method: 'POST',
        url: `${prefix}/${docId}/convert`,
        headers: jsonAuthHeaders(token),
        payload: {
          target_type: 'tax_invoice',
          apply_gst: true,
        },
      });
      expect(converted.statusCode).toBe(201);
      const newDoc = (converted.json() as {
        data: {
          id: string;
          is_gst_formal: boolean;
          lines: { tax_amount?: string; cgst_amount: string }[];
        };
      }).data;
      expect(newDoc.is_gst_formal).toBe(true);
      expect(parseFloat(newDoc.lines[0]?.cgst_amount ?? '0')).toBeGreaterThan(0);

      const salesReturn = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'sales_return',
          document_series: 'SR',
          party_id: partyId,
        },
      });
      const returnId = (salesReturn.json() as { data: { id: string } }).data.id;

      await app.inject({
        method: 'POST',
        url: `${prefix}/${returnId}/lines`,
        headers: jsonAuthHeaders(token),
        payload: {
          item_id: itemId,
          quantity: '1',
          unit: unitShortName,
          unit_price: '50',
        },
      });

      await app.inject({
        method: 'POST',
        url: `${prefix}/${returnId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: {},
      });

      const invalidConvert = await app.inject({
        method: 'POST',
        url: `${prefix}/${returnId}/convert`,
        headers: jsonAuthHeaders(token),
        payload: {
          target_type: 'tax_invoice',
          apply_gst: true,
        },
      });
      expect(invalidConvert.statusCode).toBe(422);
    },
    testTimeout,
  );

  test(
    'document sequences PATCH updates prefix and next number',
    async () => {
      const config = loadAppConfig();
      const listRes = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/sales/document-sequences`,
        headers: getAuthHeaders(token),
      });
      expect(listRes.statusCode).toBe(200);
      const sequences = (listRes.json() as { data: { id: string }[] }).data;
      expect(sequences.length).toBeGreaterThan(0);

      const sequenceId = sequences[0]!.id;
      const patchRes = await app.inject({
        method: 'PATCH',
        url: `${config.apiPrefix}/sales/document-sequences/${sequenceId}`,
        headers: jsonAuthHeaders(token),
        payload: {
          prefix: `P${suffix}`,
          next_number: 42,
        },
      });
      expect(patchRes.statusCode).toBe(200);
      const patched = patchRes.json() as {
        data: { prefix: string; next_number: number };
      };
      expect(patched.data.prefix).toBe(`P${suffix}`);
      expect(patched.data.next_number).toBe(42);
    },
    testTimeout,
  );
});
