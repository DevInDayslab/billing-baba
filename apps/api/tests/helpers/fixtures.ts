import { expect } from 'bun:test';
import type { FastifyInstance } from 'fastify';
import { loadAppConfig } from '../../src/config/app_config';
import { getAuthHeaders, jsonAuthHeaders } from './app';

export async function createInventoryFixtures(
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
      name: `Unit-${suffix}`,
      short_name: `U${suffix}`,
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
      name: `Item-${suffix}`,
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

  return { itemId, unitShortName, defaultGodownId: defaultGodown.id };
}

export async function createParty(
  app: FastifyInstance,
  token: string,
  suffix: string,
  partyType: 'customer' | 'supplier' = 'customer',
) {
  const config = loadAppConfig();
  const response = await app.inject({
    method: 'POST',
    url: `${config.apiPrefix}/parties`,
    headers: jsonAuthHeaders(token),
    payload: {
      name: `Party-${suffix}`,
      party_type: partyType,
      state_code: '27',
    },
  });
  expect(response.statusCode).toBe(201);
  return (response.json() as { data: { id: string } }).data.id;
}
