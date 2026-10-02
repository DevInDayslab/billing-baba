import 'dotenv/config';
import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import { randomUUID } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import { LEGACY_WALK_IN_PARTY_ID } from '../../src/shared/parties/walk-in-party';
import {
  createTestApp,
  jsonAuthHeaders,
  login,
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

describe.skipIf(!canRunDbTests)('Sync command push integration', () => {
  let app: FastifyInstance;
  let token: string;
  let deviceId: string;
  let syncPrefix: string;
  let partyId: string;
  let itemId: string;
  let godownId: string;
  let unitShortName: string;
  const suffix = uniqueSuffix();

  beforeAll(async () => {
    app = await createTestApp();
    token = await login(app);
    const config = loadAppConfig();
    syncPrefix = `${config.apiPrefix}/sync`;
    deviceId = randomUUID();

    await app.inject({
      method: 'POST',
      url: `${syncPrefix}/devices`,
      headers: syncHeaders(token, deviceId),
      payload: {
        device_id: deviceId,
        platform: 'macos',
        app_version: '1.4.0',
        device_name: `cmd-sync-${suffix}`,
      },
    });

    const godowns = await app.inject({
      method: 'GET',
      url: `${config.apiPrefix}/inventory/godowns`,
      headers: jsonAuthHeaders(token),
    });
    godownId = (
      godowns.json() as { data: { id: string; is_default: boolean }[] }
    ).data.find((row) => row.is_default)!.id;

    const unitRes = await app.inject({
      method: 'POST',
      url: `${config.apiPrefix}/inventory/units`,
      headers: jsonAuthHeaders(token),
      payload: {
        name: `CmdUnit-${suffix}`,
        short_name: `CU${suffix.slice(0, 4)}`,
      },
    });
    unitShortName = (unitRes.json() as { data: { short_name: string } }).data
      .short_name;

    const itemRes = await app.inject({
      method: 'POST',
      url: `${config.apiPrefix}/inventory/items`,
      headers: jsonAuthHeaders(token),
      payload: {
        name: `CmdItem-${suffix}`,
        item_type: 'product',
        base_unit: unitShortName,
        opening_quantity: '20',
        opening_cost_per_unit: '50',
        opening_godown_id: godownId,
        sale_price: '100',
      },
    });
    itemId = (itemRes.json() as { data: { id: string } }).data.id;

    const partyRes = await app.inject({
      method: 'POST',
      url: `${config.apiPrefix}/parties`,
      headers: jsonAuthHeaders(token),
      payload: {
        name: `CmdCustomer-${suffix}`,
        party_type: 'customer',
        mobile: `9${suffix.replace(/\D/g, '').slice(0, 9).padEnd(9, '1')}`,
      },
    });
    partyId = (partyRes.json() as { data: { id: string } }).data.id;
  });

  afterAll(async () => {
    await app.close();
  });

  test(
    'draft row push + finalize_sale command + idempotent replay',
    async () => {
      const documentId = randomUUID();
      const lineId = randomUUID();
      const commandId = randomUUID();
      const now = new Date().toISOString();

      const draftPush = await app.inject({
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
                document_type: 'tax_invoice',
                status: 'draft',
                document_series: 'INV',
                document_number: 'LOCAL-000001',
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
              command: 'finalize_sale',
              command_id: commandId,
              payload: {
                document_id: documentId,
                local_document_number: 'LOCAL-000001',
                godown_id: godownId,
              },
              client_updated_at: now,
            },
          ],
        },
      });

      expect(draftPush.statusCode).toBe(200);
      const body = draftPush.json() as {
        data: {
          accepted: Array<Record<string, unknown>>;
          replayed: unknown[];
          conflicts: unknown[];
          errors: Array<{ code?: string }>;
        };
      };
      expect(body.data.errors).toEqual([]);
      expect(body.data.conflicts).toEqual([]);

      const commandAccepted = body.data.accepted.find(
        (row) => row.kind === 'command',
      );
      expect(commandAccepted).toBeTruthy();
      const result = commandAccepted?.result as {
        status?: string;
        document_number_remap?: {
          local_document_number: string;
          server_document_number: string;
        };
      };
      expect(result?.status).toBe('finalized');
      expect(result?.document_number_remap?.local_document_number).toBe(
        'LOCAL-000001',
      );
      expect(
        result?.document_number_remap?.server_document_number,
      ).toBeTruthy();

      const replayPush = await app.inject({
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
              command: 'finalize_sale',
              command_id: commandId,
              payload: {
                document_id: documentId,
                local_document_number: 'LOCAL-000001',
                godown_id: godownId,
              },
              client_updated_at: now,
            },
          ],
        },
      });
      const replayBody = replayPush.json() as {
        data: {
          replayed: Array<{ idempotent_replay?: boolean }>;
          errors: unknown[];
        };
      };
      expect(replayBody.data.errors).toEqual([]);
      expect(replayBody.data.replayed).toHaveLength(1);
      expect(replayBody.data.replayed[0]?.idempotent_replay).toBe(true);
    },
    INTEGRATION_TIMEOUT_MS,
  );

  test(
    'pos finalize_sale with legacy walk-in party deducts stock on server',
    async () => {
      const documentId = randomUUID();
      const lineId = randomUUID();
      const commandId = randomUUID();
      const now = new Date().toISOString();
      const config = loadAppConfig();

      const stockBefore = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/stock-levels?item_id=${itemId}`,
        headers: jsonAuthHeaders(token),
      });
      const qtyBefore = (stockBefore.json() as { data: { quantity: string }[] })
        .data[0]?.quantity;

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
                document_type: 'pos',
                status: 'draft',
                document_series: 'POS',
                document_number: 'LOCAL-000777',
                party_id: LEGACY_WALK_IN_PARTY_ID,
                is_gst_formal: false,
                subtotal: '200',
                discount_total: '0',
                tax_amount: '0',
                total_amount: '200',
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
                quantity: '2',
                unit: unitShortName,
                unit_price: '100',
                discount_amount: '0',
                tax_type: 'none',
                tax_rate: '0',
                cgst_amount: '0',
                sgst_amount: '0',
                igst_amount: '0',
                line_total: '200',
                sort_order: 0,
              },
              client_updated_at: now,
            },
            {
              mutation_id: randomUUID(),
              kind: 'command',
              command: 'finalize_sale',
              command_id: commandId,
              payload: {
                document_id: documentId,
                local_document_number: 'LOCAL-000777',
                godown_id: godownId,
                payment: {
                  amount: '200',
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
          accepted: unknown[];
          errors: Array<{ code?: string; message?: string }>;
        };
      };
      expect(body.data.errors).toEqual([]);

      const stockAfter = await app.inject({
        method: 'GET',
        url: `${config.apiPrefix}/inventory/stock-levels?item_id=${itemId}`,
        headers: jsonAuthHeaders(token),
      });
      const qtyAfter = (stockAfter.json() as { data: { quantity: string }[] })
        .data[0]?.quantity;

      expect(parseFloat(qtyAfter ?? '0')).toBe(
        parseFloat(qtyBefore ?? '0') - 2,
      );
    },
    INTEGRATION_TIMEOUT_MS,
  );
});
