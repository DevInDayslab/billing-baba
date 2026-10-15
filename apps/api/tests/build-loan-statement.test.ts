import { describe, expect, it } from 'bun:test';
import {
  buildLoanStatement,
  computeOpeningOutstanding,
} from '../src/modules/loans/domain/build-loan-statement';

describe('buildLoanStatement', () => {
  it('computes opening and running outstanding from principal only', () => {
    const txns = [
      {
        id: '1',
        date: '2025-01-05',
        transactionType: 'increase' as const,
        principalAmount: '10000',
        interestAmount: '0',
        chargesAmount: '0',
        description: null,
        referenceNumber: null,
      },
      {
        id: '2',
        date: '2025-01-20',
        transactionType: 'repayment' as const,
        principalAmount: '2000',
        interestAmount: '100',
        chargesAmount: '0',
        description: null,
        referenceNumber: null,
      },
    ];

    const opening = computeOpeningOutstanding(
      '5000',
      '2025-01-01',
      txns,
      '2025-01-15',
    );
    expect(opening).toBe(15000);

    const rows = buildLoanStatement({
      openingOutstanding: '5000',
      openingBalanceAsOf: '2025-01-01',
      transactions: txns,
      rangeFrom: new Date('2025-01-10T00:00:00.000Z'),
      rangeTo: new Date('2025-02-01T00:00:00.000Z'),
    });

    const openingRow = rows.find((r) => r.is_opening);
    expect(openingRow?.is_opening).toBe(true);
    const last = rows[rows.length - 1];
    expect(Number(last?.balance)).toBe(13000);
  });
});
