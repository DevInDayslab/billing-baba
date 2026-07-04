import { describe, expect, test } from 'bun:test';
import { createExpenseBodySchema } from '../src/modules/purchases/expense.schema';
import { createPurchaseFaBodySchema } from '../src/modules/purchases/purchase-fa.schema';

describe('expense schema', () => {
  test('rejects invalid amount format', () => {
    const result = createExpenseBodySchema.safeParse({
      category_id: '550e8400-e29b-41d4-a716-446655440000',
      amount: 'abc',
      expense_date: '2026-07-05',
    });
    expect(result.success).toBe(false);
  });

  test('accepts valid expense', () => {
    const result = createExpenseBodySchema.safeParse({
      category_id: '550e8400-e29b-41d4-a716-446655440000',
      amount: '100.50',
      expense_date: '2026-07-05',
      payment_mode: 'cash',
    });
    expect(result.success).toBe(true);
  });
});

describe('purchase fa schema', () => {
  test('requires at least one asset', () => {
    const result = createPurchaseFaBodySchema.safeParse({
      party_id: '550e8400-e29b-41d4-a716-446655440000',
      purchase_date: '2026-07-05',
      total_amount: '1000',
      assets: [],
    });
    expect(result.success).toBe(false);
  });
});
