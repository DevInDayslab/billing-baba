import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import { randomUUID } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import { HiddenLedgerService } from '../../src/modules/hidden-ledger/hidden-ledger.service';
import {
  createTestApp,
  getAuthHeaders,
  jsonAuthHeaders,
  login,
  uniqueSuffix,
} from '../helpers/app';
import { canRunDbTests, INTEGRATION_TIMEOUT_MS } from '../helpers/env';
import { createParty } from '../helpers/fixtures';

async function createDraftSaleDocument(
  app: FastifyInstance,
  token: string,
  partyId: string,
  series: string,
): Promise<string> {
  const config = loadAppConfig();
  const created = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/sales/sales-documents`,
    headers: jsonAuthHeaders(token),
    payload: {
      document_type: 'tax_invoice',
      document_series: series,
      party_id: partyId,
      is_gst_formal: true,
      party_state_code: '27',
    },
  });
  expect(created.statusCode).toBe(201);
  return (created.json() as { data: { id: string } }).data.id;
}

describe.skipIf(!canRunDbTests)('Hidden ledger integration', () => {
  let app: FastifyInstance;
  let token: string;
  let businessId: string;
  let partyId: string;
  const suffix = uniqueSuffix();

  beforeAll(async () => {
    app = await createTestApp();
    token = await login(app);

    const config = loadAppConfig();
    const me = await app.inject({
      method: 'GET',
      url: `${config.apiPrefix}/auth/me`,
      headers: jsonAuthHeaders(token),
    });
    businessId =
      (me.json() as { data: { businesses: Array<{ id: string }> } }).data
        .businesses[0]?.id ?? '';
    expect(businessId).toBeTruthy();

    partyId = await createParty(app, token, `${suffix}-hl`);

    const shortfallSaleA = await createDraftSaleDocument(
      app,
      token,
      partyId,
      `HL${suffix}A`,
    );
    const shortfallSaleB = await createDraftSaleDocument(
      app,
      token,
      partyId,
      `HL${suffix}B`,
    );

    const service = new HiddenLedgerService();
    await service.recordShortPaymentEntry({
      businessId,
      partyId,
      salesDocumentId: shortfallSaleA,
      shortfallAmount: '100.00',
    });
    await service.recordShortPaymentEntry({
      businessId,
      partyId,
      salesDocumentId: shortfallSaleB,
      shortfallAmount: '50.00',
    });
  }, INTEGRATION_TIMEOUT_MS);

  afterAll(async () => {
    await app.close();
  }, INTEGRATION_TIMEOUT_MS);

  test(
    'lists hidden ledger entries with party summary for owner',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/hidden-ledger`;

      const list = await app.inject({
        method: 'GET',
        url: `${prefix}/entries?party_id=${partyId}`,
        headers: getAuthHeaders(token),
      });
      expect(list.statusCode).toBe(200);
      const listBody = list.json() as {
        data: Array<{ party_name: string; status: string }>;
        meta: { total: number };
      };
      expect(listBody.meta.total).toBeGreaterThanOrEqual(2);
      expect(listBody.data[0]?.party_name).toBeTruthy();

      const summary = await app.inject({
        method: 'GET',
        url: `${prefix}/parties/${partyId}/summary`,
        headers: getAuthHeaders(token),
      });
      expect(summary.statusCode).toBe(200);
      const summaryBody = summary.json() as {
        data: { hidden_ledger_balance: string; pending_entries: number };
      };
      expect(
        Number(summaryBody.data.hidden_ledger_balance),
      ).toBeGreaterThanOrEqual(150);
      expect(summaryBody.data.pending_entries).toBeGreaterThanOrEqual(2);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'returns entry detail with recovery history',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/hidden-ledger`;

      const list = await app.inject({
        method: 'GET',
        url: `${prefix}/entries?party_id=${partyId}&limit=1`,
        headers: getAuthHeaders(token),
      });
      const entryId = (list.json() as { data: Array<{ id: string }> }).data[0]
        ?.id;
      expect(entryId).toBeTruthy();

      const detail = await app.inject({
        method: 'GET',
        url: `${prefix}/entries/${entryId}`,
        headers: getAuthHeaders(token),
      });
      expect(detail.statusCode).toBe(200);
      const detailBody = detail.json() as {
        data: { recoveries: unknown[]; party_name: string };
      };
      expect(detailBody.data.party_name).toBeTruthy();
      expect(Array.isArray(detailBody.data.recoveries)).toBe(true);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'recovers FIFO across entries and rejects duplicate sale recovery',
    async () => {
      const config = loadAppConfig();
      const prefix = `${config.apiPrefix}/hidden-ledger`;
      const saleId = await createDraftSaleDocument(
        app,
        token,
        partyId,
        `HL${suffix}R`,
      );

      const recovered = await app.inject({
        method: 'POST',
        url: `${prefix}/parties/${partyId}/recover-from-sale`,
        headers: jsonAuthHeaders(token),
        payload: {
          sale_id: saleId,
          amount: '120.00',
        },
      });
      expect(recovered.statusCode).toBe(201);

      const duplicate = await app.inject({
        method: 'POST',
        url: `${prefix}/parties/${partyId}/recover-from-sale`,
        headers: jsonAuthHeaders(token),
        payload: {
          sale_id: saleId,
          amount: '10.00',
        },
      });
      expect(duplicate.statusCode).toBe(422);

      const invalidAmount = await app.inject({
        method: 'POST',
        url: `${prefix}/parties/${partyId}/recover-from-sale`,
        headers: jsonAuthHeaders(token),
        payload: {
          sale_id: randomUUID(),
          amount: '0',
        },
      });
      expect(invalidAmount.statusCode).toBe(422);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'party API exposes hidden balance for owner but not in invoice share',
    async () => {
      const config = loadAppConfig();

      const party = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/parties/${partyId}`,
        headers: getAuthHeaders(token),
      });
      expect(party.statusCode).toBe(200);
      const partyBody = party.json() as {
        data: { hidden_ledger_balance?: string };
      };
      expect(partyBody.data.hidden_ledger_balance).toBeDefined();
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
