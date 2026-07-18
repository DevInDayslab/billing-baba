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
    'customer timeline includes all finalized sales documents and manual payment',
    async () => {
      const config = loadAppConfig();
      const salesPrefix = `${config.apiPrefix}/sales/sales-documents`;
      const paymentsPrefix = `${config.apiPrefix}/accounting/payments`;
      const { itemId, unitShortName } = await createInventoryFixtures(
        app,
        token,
        `${suffix}-cust`,
      );

      const partyRes = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/parties`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `TimelineCustomer-${suffix}`,
          party_type: 'customer',
          state_code: '27',
        },
      });
      const partyId = (partyRes.json() as { data: { id: string } }).data.id;

      async function createFinalizedSalesDoc(
        documentType: string,
        documentSeries: string,
      ) {
        const created = await app.inject({
          method: 'POST',
          url: salesPrefix,
          headers: jsonAuthHeaders(token),
          payload: {
            document_type: documentType,
            document_series: documentSeries,
            party_id: partyId,
            is_gst_formal: true,
            party_state_code: '27',
          },
        });
        expect(created.statusCode).toBe(201);
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

        const finalized = await app.inject({
          method: 'POST',
          url: `${salesPrefix}/${docId}/finalize`,
          headers: jsonAuthHeaders(token),
          payload: {},
        });
        expect(finalized.statusCode).toBe(200);
        return docId;
      }

      await createFinalizedSalesDoc('estimate', `EST${suffix}`);
      const orderId = await createFinalizedSalesDoc(
        'sale_order',
        `SO${suffix}`,
      );
      await createFinalizedSalesDoc('delivery_challan', `DC${suffix}`);
      await createFinalizedSalesDoc('sales_return', `CN${suffix}`);

      const invoiceRes = await app.inject({
        method: 'POST',
        url: `${salesPrefix}/${orderId}/convert`,
        headers: jsonAuthHeaders(token),
        payload: { target_type: 'tax_invoice' },
      });
      expect(invoiceRes.statusCode).toBe(201);
      const invoiceId = (invoiceRes.json() as { data: { id: string } }).data.id;
      await app.inject({
        method: 'POST',
        url: `${salesPrefix}/${invoiceId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: {},
      });

      await app.inject({
        method: 'POST',
        url: paymentsPrefix,
        headers: jsonAuthHeaders(token),
        payload: {
          party_id: partyId,
          direction: 'received',
          amount: '50',
          payment_mode: 'cash',
          source: 'manual',
        },
      });

      const ledgerRes = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/parties/${partyId}/ledger`,
        headers: getAuthHeaders(token),
      });
      expect(ledgerRes.statusCode).toBe(200);
      const ledger = ledgerRes.json() as {
        data: {
          transactions: {
            type: string;
            source: string;
            source_type: string;
            status: string | null;
            created_at: string;
          }[];
        };
      };

      const types = ledger.data.transactions.map((row) => row.type);
      expect(types).toContain('Estimate / Quotation');
      expect(types).toContain('Sale Order');
      expect(types).toContain('Delivery Challan');
      expect(types).toContain('Sale Return / Credit Note');
      expect(types).toContain('Sale Invoice');
      expect(types).toContain('Payment In');

      const deliveryChallan = ledger.data.transactions.find(
        (row) => row.source_type === 'delivery_challan',
      );
      expect(deliveryChallan?.status).toBe('Open');

      const estimate = ledger.data.transactions.find(
        (row) => row.source_type === 'estimate',
      );
      expect(estimate?.status).toBe('Open');

      const createdAtValues = ledger.data.transactions.map((row) =>
        Date.parse(row.created_at),
      );
      const sorted = [...createdAtValues].sort((a, b) => b - a);
      expect(createdAtValues).toEqual(sorted);
    },
    testTimeout,
  );

  test(
    'supplier timeline includes purchase documents, expense, and manual payment out',
    async () => {
      const config = loadAppConfig();
      const purchasePrefix = `${config.apiPrefix}/purchases/purchase-documents`;
      const paymentsPrefix = `${config.apiPrefix}/accounting/payments`;
      const { itemId, unitShortName } = await createInventoryFixtures(
        app,
        token,
        `${suffix}-sup`,
      );

      const partyRes = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/parties`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `TimelineSupplier-${suffix}`,
          party_type: 'supplier',
          state_code: '27',
        },
      });
      const partyId = (partyRes.json() as { data: { id: string } }).data.id;

      const categories = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/purchases/expense-categories`,
        headers: getAuthHeaders(token),
      });
      const categoryId = (categories.json() as { data: { id: string }[] })
        .data[0]?.id;
      expect(categoryId).toBeDefined();

      async function createFinalizedPurchaseDoc(
        documentType: string,
        documentSeries: string,
      ) {
        const created = await app.inject({
          method: 'POST',
          url: purchasePrefix,
          headers: jsonAuthHeaders(token),
          payload: {
            document_type: documentType,
            document_series: documentSeries,
            party_id: partyId,
          },
        });
        expect(created.statusCode).toBe(201);
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
          },
        });

        const finalized = await app.inject({
          method: 'POST',
          url: `${purchasePrefix}/${docId}/finalize`,
          headers: jsonAuthHeaders(token),
          payload: {},
        });
        expect(finalized.statusCode).toBe(200);
        return docId;
      }

      const orderId = await createFinalizedPurchaseDoc(
        'purchase_order',
        `PO${suffix}`,
      );
      await createFinalizedPurchaseDoc('purchase_return', `PR${suffix}`);

      const billRes = await app.inject({
        method: 'POST',
        url: `${purchasePrefix}/${orderId}/convert`,
        headers: jsonAuthHeaders(token),
        payload: { target_type: 'purchase_bill' },
      });
      expect(billRes.statusCode).toBe(201);
      const billId = (billRes.json() as { data: { id: string } }).data.id;
      await app.inject({
        method: 'POST',
        url: `${purchasePrefix}/${billId}/finalize`,
        headers: jsonAuthHeaders(token),
        payload: {},
      });

      await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/purchases/expenses`,
        headers: jsonAuthHeaders(token),
        payload: {
          category_id: categoryId,
          party_id: partyId,
          amount: '250',
          expense_date: new Date().toISOString().slice(0, 10),
          description: `Supplier expense ${suffix}`,
          payment_mode: 'cash',
        },
      });

      await app.inject({
        method: 'POST',
        url: paymentsPrefix,
        headers: jsonAuthHeaders(token),
        payload: {
          party_id: partyId,
          direction: 'paid',
          amount: '75',
          payment_mode: 'cash',
          source: 'manual',
        },
      });

      const ledgerRes = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/parties/${partyId}/ledger`,
        headers: getAuthHeaders(token),
      });
      expect(ledgerRes.statusCode).toBe(200);
      const ledger = ledgerRes.json() as {
        data: {
          transactions: {
            type: string;
            source: string;
            created_at: string;
          }[];
        };
      };

      const types = ledger.data.transactions.map((row) => row.type);
      expect(types).toContain('Purchase Order');
      expect(types).toContain('Purchase Bill');
      expect(types).toContain('Purchase Return / Debit Note');
      expect(types).toContain('Expense');
      expect(types).toContain('Payment Out');

      const createdAtValues = ledger.data.transactions.map((row) =>
        Date.parse(row.created_at),
      );
      const sorted = [...createdAtValues].sort((a, b) => b - a);
      expect(createdAtValues).toEqual(sorted);
    },
    testTimeout,
  );

  test(
    'cash sale timeline hides auto-finalize payment rows',
    async () => {
      const config = loadAppConfig();
      const salesPrefix = `${config.apiPrefix}/sales/sales-documents`;
      const paymentsPrefix = `${config.apiPrefix}/accounting/payments`;
      const { itemId, unitShortName } = await createInventoryFixtures(
        app,
        token,
        `${suffix}-cash`,
      );

      const partyRes = await app.inject({
        method: 'POST',
        url: `${config.apiPrefix}/parties`,
        headers: jsonAuthHeaders(token),
        payload: {
          name: `CashCustomer-${suffix}`,
          party_type: 'customer',
          state_code: '27',
        },
      });
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
          source: 'document_finalize',
          allocations: [{ sales_document_id: docId, allocated_amount: total }],
        },
      });

      const ledgerRes = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/parties/${partyId}/ledger`,
        headers: getAuthHeaders(token),
      });
      expect(ledgerRes.statusCode).toBe(200);
      const ledger = ledgerRes.json() as {
        data: {
          transactions: {
            type: string;
            source: string;
            payment_status?: string | null;
          }[];
        };
      };

      expect(ledger.data.transactions).toHaveLength(1);
      expect(ledger.data.transactions[0]?.type).toBe('Sale Invoice');
      expect(ledger.data.transactions[0]?.payment_status).toBe('Paid');
      expect(
        ledger.data.transactions.some((row) => row.source === 'payments'),
      ).toBe(false);
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
