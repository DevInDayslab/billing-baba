import { describe, expect, test } from 'bun:test';
import { assertValidConversion } from '../../../src/modules/purchases/purchase-convert.rules';

describe('purchase-convert.rules', () => {
  test('allows purchase_order to purchase_bill', () => {
    expect(() =>
      assertValidConversion('purchase_order', 'purchase_bill'),
    ).not.toThrow();
  });

  test('rejects purchase_bill to purchase_bill', () => {
    expect(() =>
      assertValidConversion('purchase_bill', 'purchase_bill'),
    ).toThrow();
  });
});
