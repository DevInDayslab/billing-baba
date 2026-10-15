import { describe, expect, test } from 'bun:test';
import { buildAccountStatement } from '../../../src/modules/bank-accounts/domain/build-account-statement';
import { expenseDateToOccurredAt } from '../../../src/modules/bank-accounts/utils/ist-date';

describe('buildAccountStatement', () => {
  test('computes opening row and running balance', () => {
    const rangeFrom = expenseDateToOccurredAt('2025-01-01');
    const rangeTo = expenseDateToOccurredAt('2025-02-01');
    const occurred = expenseDateToOccurredAt('2025-01-15');

    const result = buildAccountStatement({
      openingBalance: '100',
      openingBalanceAsOf: '2025-01-01',
      movements: [
        {
          id: 'm1',
          direction: 'deposit',
          amount: '50',
          occurredAt: occurred,
          createdAt: occurred,
          description: 'Payment In',
          referenceNumber: null,
          movementType: 'payment_in',
          referenceType: 'payment',
          referenceId: 'p1',
        },
      ],
      rangeFrom,
      rangeTo,
    });

    expect(result.summary.opening_balance).toBe('100.00');
    expect(result.summary.total_deposits).toBe('50.00');
    expect(result.summary.closing_balance).toBe('150.00');
    expect(result.rows.some((r) => r.is_opening)).toBe(true);
  });
});
