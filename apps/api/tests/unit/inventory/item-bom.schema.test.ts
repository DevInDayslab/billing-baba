import { describe, expect, test } from 'bun:test';
import { randomUUID } from 'node:crypto';
import { replaceItemBomBodySchema } from '../../../src/modules/inventory/item-bom.schema';

describe('replaceItemBomBodySchema', () => {
  test('accepts positive quantity materials', () => {
    const result = replaceItemBomBodySchema.safeParse({
      materials: [
        {
          raw_item_id: randomUUID(),
          qty: '2.5',
          unit_id: randomUUID(),
        },
      ],
      costs: [],
    });
    expect(result.success).toBe(true);
  });

  test('rejects zero quantity', () => {
    const result = replaceItemBomBodySchema.safeParse({
      materials: [
        {
          raw_item_id: randomUUID(),
          qty: '0',
          unit_id: randomUUID(),
        },
      ],
      costs: [],
    });
    expect(result.success).toBe(false);
  });

  test('rejects negative quantity', () => {
    const result = replaceItemBomBodySchema.safeParse({
      materials: [
        {
          raw_item_id: randomUUID(),
          qty: '-1',
          unit_id: randomUUID(),
        },
      ],
      costs: [],
    });
    expect(result.success).toBe(false);
  });

  test('rejects duplicate raw materials', () => {
    const rawItemId = randomUUID();
    const unitId = randomUUID();
    const result = replaceItemBomBodySchema.safeParse({
      materials: [
        { raw_item_id: rawItemId, qty: '1', unit_id: unitId },
        { raw_item_id: rawItemId, qty: '2', unit_id: unitId },
      ],
      costs: [],
    });
    expect(result.success).toBe(false);
  });
});
