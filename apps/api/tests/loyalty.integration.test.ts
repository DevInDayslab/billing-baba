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

async function createLoyaltyFixtures(
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
      name: `LoyaltyUnit-${suffix}`,
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
      name: `LoyaltyItem-${suffix}`,
      item_type: 'product',
      base_unit: unitShortName,
      opening_quantity: '100',
      opening_cost_per_unit: '100',
      opening_godown_id: defaultGodown?.id,
      sale_price: '150',
    },
  });
  expect(itemRes.statusCode).toBe(201);
  const itemId = (itemRes.json() as { data: { id: string } }).data.id;

  const customerRes = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/parties`,
    headers: jsonAuthHeaders(token),
    payload: {
      name: `LoyaltyCustomer-${suffix}`,
      party_type: 'customer',
      state_code: '27',
    },
  });
  expect(customerRes.statusCode).toBe(201);
  const customerId = (customerRes.json() as { data: { id: string } }).data.id;

  const supplierRes = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/parties`,
    headers: jsonAuthHeaders(token),
    payload: {
      name: `LoyaltySupplier-${suffix}`,
      party_type: 'supplier',
      state_code: '27',
    },
  });
  expect(supplierRes.statusCode).toBe(201);
  const supplierId = (supplierRes.json() as { data: { id: string } }).data.id;

  return {
    itemId,
    customerId,
    supplierId,
    unitShortName,
    defaultGodownId: defaultGodown!.id,
  };
}

async function createAndFinalizeInvoice(
  app: FastifyInstance,
  token: string,
  params: {
    partyId: string;
    itemId: string;
    unitShortName: string;
    suffix: string;
    loyaltyPointsRedeemed?: string;
  },
) {
  const config = loadAppConfig();
  const prefix = `${config.apiPrefix}/sales/sales-documents`;

  const created = await app.inject({
    method: 'POST',
    url: prefix,
    headers: jsonAuthHeaders(token),
    payload: {
      document_type: 'tax_invoice',
      document_series: `L${params.suffix.slice(-5)}`,
      party_id: params.partyId,
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
      item_id: params.itemId,
      quantity: '2',
      unit: params.unitShortName,
      unit_price: '100',
      tax_rate: '18',
    },
  });
  expect(line.statusCode).toBe(201);

  const finalized = await app.inject({
    method: 'POST',
    url: `${prefix}/${docId}/finalize`,
    headers: jsonAuthHeaders(token),
    payload: {
      loyalty_points_redeemed: params.loyaltyPointsRedeemed ?? '0',
    },
  });

  return { docId, finalized };
}

describe.skipIf(!canRun)('Loyalty API integration', () => {
  let app: FastifyInstance;
  let token: string;
  const suffix = Date.now().toString(36).slice(-6);
  const testTimeout = 60_000;

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
    'default loyalty rules and party balance endpoints',
    async () => {
      const config = loadAppConfig();
      const { customerId } = await createLoyaltyFixtures(app, token, suffix);

      const rules = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/settings/loyalty-rules`,
        headers: getAuthHeaders(token),
      });
      expect(rules.statusCode).toBe(200);
      const rulesBody = rules.json() as {
        data: { rupees_per_point: string; is_active: boolean };
      };
      expect(rulesBody.data.is_active).toBe(true);
      expect(parseFloat(rulesBody.data.rupees_per_point)).toBe(100);

      const balance = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/parties/${customerId}/loyalty`,
        headers: getAuthHeaders(token),
      });
      expect(balance.statusCode).toBe(200);
      const balanceBody = balance.json() as {
        data: { points_available: string };
      };
      expect(parseFloat(balanceBody.data.points_available)).toBe(0);
    },
    testTimeout,
  );

  test(
    'earn and redeem loyalty points on sale finalize',
    async () => {
      const config = loadAppConfig();
      const fixtures = await createLoyaltyFixtures(app, token, `${suffix}-earn`);

      const firstSale = await createAndFinalizeInvoice(app, token, {
        partyId: fixtures.customerId,
        itemId: fixtures.itemId,
        unitShortName: fixtures.unitShortName,
        suffix: `${suffix}-earn`,
      });
      expect(firstSale.finalized.statusCode).toBe(200);
      const firstBody = firstSale.finalized.json() as {
        data: { loyalty?: { earned_points: string } };
      };
      expect(parseFloat(firstBody.data.loyalty?.earned_points ?? '0')).toBe(2);

      const balanceAfterEarn = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/parties/${fixtures.customerId}/loyalty`,
        headers: getAuthHeaders(token),
      });
      expect(balanceAfterEarn.statusCode).toBe(200);
      expect(
        parseFloat(
          (
            balanceAfterEarn.json() as {
              data: { points_available: string };
            }
          ).data.points_available,
        ),
      ).toBe(2);

      const secondSale = await createAndFinalizeInvoice(app, token, {
        partyId: fixtures.customerId,
        itemId: fixtures.itemId,
        unitShortName: fixtures.unitShortName,
        suffix: `${suffix}-redeem`,
        loyaltyPointsRedeemed: '2',
      });
      expect(secondSale.finalized.statusCode).toBe(200);
      const secondBody = secondSale.finalized.json() as {
        data: {
          loyalty?: {
            redeemed_points: string;
            earned_points: string;
            points_available: string;
          };
        };
      };
      expect(parseFloat(secondBody.data.loyalty?.redeemed_points ?? '0')).toBe(
        2,
      );
      expect(parseFloat(secondBody.data.loyalty?.earned_points ?? '0')).toBe(2);
      expect(parseFloat(secondBody.data.loyalty?.points_available ?? '0')).toBe(
        2,
      );

      const history = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/parties/${fixtures.customerId}/loyalty/transactions`,
        headers: getAuthHeaders(token),
      });
      expect(history.statusCode).toBe(200);
      const historyBody = history.json() as {
        data: { transaction_type: string }[];
        meta: { total: number };
      };
      expect(historyBody.meta.total).toBeGreaterThanOrEqual(3);
      expect(
        historyBody.data.some((row) => row.transaction_type === 'earn'),
      ).toBe(true);
      expect(
        historyBody.data.some((row) => row.transaction_type === 'redeem'),
      ).toBe(true);
    },
    testTimeout,
  );

  test(
    'rejects loyalty redemption for suppliers and insufficient balance',
    async () => {
      const config = loadAppConfig();
      const fixtures = await createLoyaltyFixtures(
        app,
        token,
        `${suffix}-guard`,
      );

      const supplierSale = await createAndFinalizeInvoice(app, token, {
        partyId: fixtures.supplierId,
        itemId: fixtures.itemId,
        unitShortName: fixtures.unitShortName,
        suffix: `${suffix}-supplier`,
        loyaltyPointsRedeemed: '1',
      });
      expect(supplierSale.finalized.statusCode).toBe(422);

      const customerSale = await createAndFinalizeInvoice(app, token, {
        partyId: fixtures.customerId,
        itemId: fixtures.itemId,
        unitShortName: fixtures.unitShortName,
        suffix: `${suffix}-insufficient`,
        loyaltyPointsRedeemed: '99',
      });
      expect(customerSale.finalized.statusCode).toBe(422);
      const errorBody = customerSale.finalized.json() as {
        error: { code: string };
      };
      expect(errorBody.error.code).toBe('INSUFFICIENT_LOYALTY_POINTS');
    },
    testTimeout,
  );
});
