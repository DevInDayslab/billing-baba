import { describe, expect, test } from 'bun:test';
import { randomUUID } from 'node:crypto';
import { replaceItemSuppliersBodySchema } from '../../../src/modules/inventory/item-supplier.schema';

describe('replaceItemSuppliersBodySchema', () => {
  test('accepts empty supplier list', () => {
    const result = replaceItemSuppliersBodySchema.safeParse({ suppliers: [] });
    expect(result.success).toBe(true);
  });

  test('accepts one default supplier', () => {
    const partyId = randomUUID();
    const result = replaceItemSuppliersBodySchema.safeParse({
      suppliers: [{ party_id: partyId, is_default: true }],
    });
    expect(result.success).toBe(true);
  });

  test('rejects duplicate party IDs', () => {
    const partyId = randomUUID();
    const result = replaceItemSuppliersBodySchema.safeParse({
      suppliers: [
        { party_id: partyId, is_default: true },
        { party_id: partyId, is_default: false },
      ],
    });
    expect(result.success).toBe(false);
  });

  test('rejects empty default when suppliers exist', () => {
    const result = replaceItemSuppliersBodySchema.safeParse({
      suppliers: [
        { party_id: randomUUID(), is_default: false },
        { party_id: randomUUID(), is_default: false },
      ],
    });
    expect(result.success).toBe(false);
  });

  test('rejects more than one default supplier', () => {
    const result = replaceItemSuppliersBodySchema.safeParse({
      suppliers: [
        { party_id: randomUUID(), is_default: true },
        { party_id: randomUUID(), is_default: true },
      ],
    });
    expect(result.success).toBe(false);
  });
});
