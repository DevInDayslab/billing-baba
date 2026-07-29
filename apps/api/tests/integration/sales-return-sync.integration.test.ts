import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import { randomUUID } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import {
  createTestApp,
  jsonAuthHeaders,
  login,
  uniqueIndianMobile,
  uniqueSuffix,
} from '../helpers/app';
import { canRunDbTests, INTEGRATION_TIMEOUT_MS } from '../helpers/env';

function syncHeaders(token: string, deviceId: string): Record<string, string> {
  return {
    ...jsonAuthHeaders(token),
    'x-device-id': deviceId,
    'x-app-version': '1.4.0',
    'x-sync-protocol-version': '1',
  };
}

describe.skipIf(!canRunDbTests)('Sales return sync integration', () => {
  let app: FastifyInstance;
  let token: string;
  let deviceId: string;
  let syncPrefix: string;
  let apiPrefix: string;
  let partyId: string;
  let itemId: string;
  let godownId: string;
  let unitShortName: string;
  const suffix = uniqueSuffix();

  beforeAll(async () => {
    app = await createTestApp();
    token = await login(app);
    const config = loadAppConfig();
    apiPrefix = config.apiPrefix;
    syncPrefix = `${apiPrefix}/sync`;
    deviceId = randomUUID();

    await app.inject({
      method: 'POST',
      url: `${syncPrefix}/devices`,
      headers: syncHeaders(token, deviceId),
      payload: {
        device_id: deviceId,
        platform: 'macos',
        app_version: '1.4.0',
        device_name: `sales-return-sync-${suffix}`,
      },
    });

    const godowns = await app.inject({
      method: 'GET',
      url: `${apiPrefix}/inventory/godowns`,
      headers: jsonAuthHeaders(token),
    });
    godownId = (
      godowns.json() as { data: { id: string; is_default: boolean }[] }
    ).data.find((row) => row.is_default)!.id;

    const unitRes = await app.inject({
      method: 'POST',
      url: `${apiPrefix}/inventory/units`,
      headers: jsonAuthHeaders(token),
      payload: {
        name: `SalesReturnSyncUnit-${suffix}`,
        short_name: `SR${suffix.slice(0, 4)}`,
      },
    });
    unitShortName = (unitRes.json() as { data: { short_name: string } })
      .data.short_name;

    const itemRes = await app.inject({
      method: 'POST',
      url: `${apiPrefix}/inventory/items`,
      headers: jsonAuthHeaders(token),
      payload: {
        name: `SalesReturnSyncItem-${suffix}`,
        item_type: 'product',
        base_unit: unitShortName,
        opening_quantity: '50',
        opening_cost_per_unit: '50',
        opening_godown_id: godownId,
        sale_price: '100',
      },
    });
    itemId = (itemRes.json() as { data: { id: string } }).data.id;

    const partyRes = await app.inject({
      method: 'POST',
      url: `${apiPrefix}/parties`,
      headers: jsonAuthHeaders(token),
      payload: {
        name: `SalesReturnSyncCustomer-${suffix}`,
        party_type: 'customer',
        mobile: uniqueIndianMobile('9'),
      },
    });
    partyId = (partyRes.json() as { data: { id: string } }).data.id;
  }, INTEGRATION_TIMEOUT_MS);

  afterAll(async () => {
    await app.close();
  });

  test(
    'finalize_credit_note with refund records paid_amount',
    async () => {
      const documentId = randomUUID();
      const lineId = randomUUID();
      const now = new Date().toISOString();

      const push = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'sales_documents',
              entity_id: documentId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                document_type: 'sales_return',
                status: 'draft',
                document_series: 'CN',
                document_number: 'LOCAL-000010',
                party_id: partyId,
                is_gst_formal: false,
                subtotal: '100',
                discount_total: '0',
                tax_amount: '0',
                total_amount: '100',
                document_date: now,
              },
              client_updated_at: now,
            },
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'sales_document_lines',
              entity_id: lineId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                sales_document_id: documentId,
                item_id: itemId,
                quantity: '1',
                unit: unitShortName,
                unit_price: '100',
                discount_amount: '0',
                tax_type: 'none',
                tax_rate: '0',
                cgst_amount: '0',
                sgst_amount: '0',
                igst_amount: '0',
                line_total: '100',
                sort_order: 0,
              },
              client_updated_at: now,
            },
            {
              mutation_id: randomUUID(),
              kind: 'command',
              command: 'finalize_credit_note',
              command_id: randomUUID(),
              payload: {
                document_id: documentId,
                local_document_number: 'LOCAL-000010',
                godown_id: godownId,
                payment: {
                  amount: '50.0000',
                  payment_mode: 'cash',
                },
              },
              client_updated_at: now,
            },
          ],
        },
      });

      expect(push.statusCode).toBe(200);
      const body = push.json() as {
        data: {
          accepted: Array<Record<string, unknown>>;
          errors: unknown[];
          conflicts: unknown[];
        };
      };
      expect(body.data.errors).toEqual([]);
      expect(body.data.conflicts).toEqual([]);

      const commandAccepted = body.data.accepted.find(
        (row) => row.kind === 'command',
      ) as {
        result?: {
          paid_amount?: string;
          payment_mode?: string;
        };
      };
      expect(commandAccepted?.result?.paid_amount).toBe('50.0000');
      expect(commandAccepted?.result?.payment_mode).toBe('cash');

      const detail = await app.inject({
        method: 'GET',
        url: `${apiPrefix}/sales/sales-documents/${documentId}`,
        headers: jsonAuthHeaders(token),
      });
      expect(detail.statusCode).toBe(200);
      const doc = (detail.json() as { data: { status: string } }).data;
      expect(doc.status).toBe('finalized');
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'double finalize_credit_note returns DOCUMENT_ALREADY_FINALIZED conflict',
    async () => {
      const documentId = randomUUID();
      const lineId = randomUUID();
      const now = new Date().toISOString();

      const setup = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'sales_documents',
              entity_id: documentId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                document_type: 'sales_return',
                status: 'draft',
                document_series: 'CN',
                document_number: 'LOCAL-000020',
                party_id: partyId,
                is_gst_formal: false,
                subtotal: '100',
                discount_total: '0',
                tax_amount: '0',
                total_amount: '100',
                document_date: now,
              },
              client_updated_at: now,
            },
            {
              mutation_id: randomUUID(),
              kind: 'row',
              entity_type: 'sales_document_lines',
              entity_id: lineId,
              operation: 'create',
              base_sync_version: 0,
              payload: {
                sales_document_id: documentId,
                item_id: itemId,
                quantity: '1',
                unit: unitShortName,
                unit_price: '100',
                discount_amount: '0',
                tax_type: 'none',
                tax_rate: '0',
                cgst_amount: '0',
                sgst_amount: '0',
                igst_amount: '0',
                line_total: '100',
                sort_order: 0,
              },
              client_updated_at: now,
            },
            {
              mutation_id: randomUUID(),
              kind: 'command',
              command: 'finalize_credit_note',
              command_id: randomUUID(),
              payload: {
                document_id: documentId,
                local_document_number: 'LOCAL-000020',
                godown_id: godownId,
              },
              client_updated_at: now,
            },
          ],
        },
      });
      expect(setup.statusCode).toBe(200);

      const secondFinalize = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [
            {
              mutation_id: randomUUID(),
              kind: 'command',
              command: 'finalize_credit_note',
              command_id: randomUUID(),
              payload: {
                document_id: documentId,
                local_document_number: 'LOCAL-000020',
                godown_id: godownId,
              },
              client_updated_at: now,
            },
          ],
        },
      });

      const conflictBody = secondFinalize.json() as {
        data: {
          conflicts: Array<{ code?: string }>;
          errors: unknown[];
        };
      };
      expect(conflictBody.data.errors).toEqual([]);
      expect(conflictBody.data.conflicts).toHaveLength(1);
      expect(conflictBody.data.conflicts[0]?.code).toBe(
        'DOCUMENT_ALREADY_FINALIZED',
      );
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'finalize_credit_note command_id replay is idempotent',
    async () => {
      const documentId = randomUUID();
      const lineId = randomUUID();
      const commandId = randomUUID();
      const now = new Date().toISOString();

      const mutations = [
        {
          mutation_id: randomUUID(),
          kind: 'row',
          entity_type: 'sales_documents',
          entity_id: documentId,
          operation: 'create',
          base_sync_version: 0,
          payload: {
            document_type: 'sales_return',
            status: 'draft',
            document_series: 'CN',
            document_number: 'LOCAL-000030',
            party_id: partyId,
            is_gst_formal: false,
            subtotal: '100',
            discount_total: '0',
            tax_amount: '0',
            total_amount: '100',
            document_date: now,
          },
          client_updated_at: now,
        },
        {
          mutation_id: randomUUID(),
          kind: 'row',
          entity_type: 'sales_document_lines',
          entity_id: lineId,
          operation: 'create',
          base_sync_version: 0,
          payload: {
            sales_document_id: documentId,
            item_id: itemId,
            quantity: '1',
            unit: unitShortName,
            unit_price: '100',
            discount_amount: '0',
            tax_type: 'none',
            tax_rate: '0',
            cgst_amount: '0',
            sgst_amount: '0',
            igst_amount: '0',
            line_total: '100',
            sort_order: 0,
          },
          client_updated_at: now,
        },
        {
          mutation_id: randomUUID(),
          kind: 'command',
          command: 'finalize_credit_note',
          command_id: commandId,
          payload: {
            document_id: documentId,
            local_document_number: 'LOCAL-000030',
            godown_id: godownId,
          },
          client_updated_at: now,
        },
      ];

      const first = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations,
        },
      });
      expect(first.statusCode).toBe(200);

      const replay = await app.inject({
        method: 'POST',
        url: `${syncPrefix}/push`,
        headers: syncHeaders(token, deviceId),
        payload: {
          device_id: deviceId,
          client_batch_id: randomUUID(),
          mutations: [mutations[2]],
        },
      });

      const replayBody = replay.json() as {
        data: {
          replayed: Array<{ command_id?: string }>;
          conflicts: unknown[];
          errors: unknown[];
        };
      };
      expect(replayBody.data.errors).toEqual([]);
      expect(replayBody.data.conflicts).toEqual([]);
      expect(replayBody.data.replayed).toHaveLength(1);
      expect(replayBody.data.replayed[0]?.command_id).toBe(commandId);
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
