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

async function createPurchaseFixtures(
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

  if (!defaultGodown) {
    throw new Error('Default godown not found');
  }

  const unitRes = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/inventory/units`,
    headers: jsonAuthHeaders(token),
    payload: {
      name: `PurchaseUnit-${suffix}`,
      short_name: `PU${suffix}`,
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
      name: `PurchaseItem-${suffix}`,
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

  const supplierRes = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/parties`,
    headers: jsonAuthHeaders(token),
    payload: {
      name: `Supplier-${suffix}`,
      party_type: 'supplier',
      state_code: '27',
    },
  });
  expect(supplierRes.statusCode).toBe(201);
  const supplierId = (supplierRes.json() as { data: { id: string } }).data.id;

  const customerRes = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/parties`,
    headers: jsonAuthHeaders(token),
    payload: {
      name: `Customer-${suffix}`,
      party_type: 'customer',
      state_code: '27',
    },
  });
  expect(customerRes.statusCode).toBe(201);
  const customerId = (customerRes.json() as { data: { id: string } }).data.id;

  return {
    itemId,
    supplierId,
    customerId,
    unitShortName,
    defaultGodownId: defaultGodown.id,
  };
}

describe.skipIf(!canRun)('Purchases API integration', () => {
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
    'draft CRUD',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const { supplierId } = await createPurchaseFixtures(
        app,
        token,
        `${suffix}-crud`,
      );

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_order',
          document_series: `PO${suffix}`,
          party_id: supplierId,
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
        payload: { notes: 'Updated purchase order' },
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
    'rejects customer-only party on create',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const { customerId } = await createPurchaseFixtures(
        app,
        token,
        `${suffix}-party`,
      );

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_bill',
          document_series: 'PB',
          party_id: customerId,
        },
      });
      expect(created.statusCode).toBe(422);
    },
    testTimeout,
  );

  test(
    'lines update document totals',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const { itemId, supplierId, unitShortName } =
        await createPurchaseFixtures(app, token, `${suffix}-lines`);

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_bill',
          document_series: 'PB',
          party_id: supplierId,
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
      const prefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const { supplierId } = await createPurchaseFixtures(
        app,
        token,
        `${suffix}-guard`,
      );

      const emptyDraft = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_order',
          document_series: `POG${suffix}`,
          party_id: supplierId,
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
    'purchase order finalize assigns number without stock change',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const { itemId, supplierId, unitShortName } =
        await createPurchaseFixtures(app, token, `${suffix}-po`);

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_order',
          document_series: `PO${suffix}`,
          party_id: supplierId,
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
        },
      });

      const stockBefore = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/stock-levels?item_id=${itemId}`,
        headers: getAuthHeaders(token),
      });
      const qtyBefore = (stockBefore.json() as { data: { quantity: string }[] })
        .data[0]?.quantity;

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

      const stockAfter = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/stock-levels?item_id=${itemId}`,
        headers: getAuthHeaders(token),
      });
      const qtyAfter = (stockAfter.json() as { data: { quantity: string }[] })
        .data[0]?.quantity;
      expect(qtyAfter).toBe(qtyBefore);
    },
    testTimeout,
  );

  test(
    'purchase bill finalize increases stock and posts payable',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const { itemId, supplierId, unitShortName } =
        await createPurchaseFixtures(app, token, `${suffix}-bill`);

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_bill',
          document_series: 'PB',
          party_id: supplierId,
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
          quantity: '3',
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

      const stock = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/stock-levels?item_id=${itemId}`,
        headers: getAuthHeaders(token),
      });
      const stockQty = (stock.json() as { data: { quantity: string }[] })
        .data[0]?.quantity;
      expect(stockQty).toBe('13.0000');

      const movements = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/movements?item_id=${itemId}`,
        headers: getAuthHeaders(token),
      });
      const movementBody = movements.json() as {
        data: { movement_type: string }[];
      };
      expect(
        movementBody.data.some((row) => row.movement_type === 'purchase'),
      ).toBe(true);
    },
    testTimeout,
  );

  test(
    'purchase return finalize decreases stock',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const { itemId, supplierId, unitShortName } =
        await createPurchaseFixtures(app, token, `${suffix}-ret`);

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_return',
          document_series: 'DN',
          party_id: supplierId,
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
        },
      });

      const finalized = await app.inject({
        method: 'POST',
        url: `${prefix}/${docId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: {},
      });
      expect(finalized.statusCode).toBe(200);

      const stock = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/stock-levels?item_id=${itemId}`,
        headers: getAuthHeaders(token),
      });
      const stockQty = (stock.json() as { data: { quantity: string }[] })
        .data[0]?.quantity;
      expect(stockQty).toBe('8.0000');

      const movements = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/movements?item_id=${itemId}`,
        headers: getAuthHeaders(token),
      });
      const movementBody = movements.json() as {
        data: {
          movement_type: string;
          cost_per_unit: string | null;
          unit: string | null;
        }[];
      };
      const returnMovement = movementBody.data.find(
        (row) => row.movement_type === 'purchase_return',
      );
      expect(returnMovement).toBeDefined();
      expect(returnMovement?.cost_per_unit).toBe('100.0000');
      expect(returnMovement?.unit).toBe(unitShortName);
    },
    testTimeout,
  );

  test(
    'convert purchase order to bill',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const { itemId, supplierId, unitShortName } =
        await createPurchaseFixtures(app, token, `${suffix}-cvt`);

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_order',
          document_series: `POC${suffix}`,
          party_id: supplierId,
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
        payload: { target_type: 'purchase_bill' },
      });
      expect(converted.statusCode).toBe(201);
      const newDoc = (
        converted.json() as {
          data: { document_type: string; converted_from_id: string };
        }
      ).data;
      expect(newDoc.document_type).toBe('purchase_bill');
      expect(newDoc.converted_from_id).toBe(docId);

      const source = await app.inject({
        method: 'GET',
        url: `${prefix}/${docId}`,
        headers: getAuthHeaders(token),
      });
      expect((source.json() as { data: { status: string } }).data.status).toBe(
        'converted',
      );
    },
    testTimeout,
  );

  test(
    'invalid convert rejected',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const { itemId, supplierId, unitShortName } =
        await createPurchaseFixtures(app, token, `${suffix}-icvt`);

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_bill',
          document_series: 'PB',
          party_id: supplierId,
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
        },
      });

      const invalidConvert = await app.inject({
        method: 'POST',
        url: `${prefix}/${docId}/convert`,
        headers: jsonAuthHeaders(token),
        payload: { target_type: 'purchase_bill' },
      });
      expect(invalidConvert.statusCode).toBe(422);
    },
    testTimeout,
  );

  test(
    'cancel finalized document',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const { itemId, supplierId, unitShortName } =
        await createPurchaseFixtures(app, token, `${suffix}-cancel`);

      const created = await app.inject({
        method: 'POST',
        url: prefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_order',
          document_series: `POX${suffix}`,
          party_id: supplierId,
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

      await app.inject({
        method: 'POST',
        url: `${prefix}/${docId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: {},
      });

      const cancelled = await app.inject({
        method: 'POST',
        url: `${prefix}/${docId}/cancel`,
        headers: getAuthHeaders(token),
      });
      expect(cancelled.statusCode).toBe(200);
      expect(
        (cancelled.json() as { data: { status: string } }).data.status,
      ).toBe('cancelled');
    },
    testTimeout,
  );

  test(
    'payment allocation validates purchase document',
    async () => {
      const config = loadAppConfig();
      const purchasePrefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const paymentsPrefix = `${config.apiPrefix}/accounting/payments`;
      const { itemId, supplierId, unitShortName } =
        await createPurchaseFixtures(app, token, `${suffix}-pay`);

      const created = await app.inject({
        method: 'POST',
        url: purchasePrefix,
        headers: jsonAuthHeaders(token),
        payload: {
          document_type: 'purchase_bill',
          document_series: 'PB',
          party_id: supplierId,
          is_gst_formal: true,
          party_state_code: '27',
        },
      });
      const docId = (created.json() as { data: { id: string } }).data.id;

      await app.inject({
        method: 'POST',
        url: `${purchasePrefix}/${docId}/lines`,
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
        url: `${purchasePrefix}/${docId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: {},
      });

      const detail = await app.inject({
        method: 'GET',
        url: `${purchasePrefix}/${docId}`,
        headers: getAuthHeaders(token),
      });
      const total = (detail.json() as { data: { total_amount: string } }).data
        .total_amount;

      const payment = await app.inject({
        method: 'POST',
        url: paymentsPrefix,
        headers: jsonAuthHeaders(token),
        payload: {
          party_id: supplierId,
          direction: 'paid',
          amount: total,
          payment_mode: 'cash',
          allocations: [
            {
              purchase_document_id: docId,
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
          party_id: supplierId,
          direction: 'paid',
          amount: '10',
          payment_mode: 'cash',
          allocations: [
            {
              purchase_document_id: docId,
              allocated_amount: '10',
            },
          ],
        },
      });
      expect(overAllocate.statusCode).toBe(422);
    },
    testTimeout,
  );
});
