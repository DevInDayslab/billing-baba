import { describe, expect, test } from 'bun:test';
import {
  listFinancialYearMonths,
  resolveGstReportPeriod,
} from '../../../src/modules/gst-reports/core/gst-period';

describe('gst-period', () => {
  test('resolves financial year Apr–Mar IST', () => {
    const range = resolveGstReportPeriod(
      { financial_year: '2024-25' },
      new Date('2025-06-01T00:00:00.000Z'),
    );
    expect(range.key).toBe('fy_2024_2025');
    const months = listFinancialYearMonths(range);
    expect(months.length).toBe(12);
    expect(months[0]?.key).toBe('month_2024-04');
    expect(months[11]?.key).toBe('month_2025-03');
  });

  test('resolves calendar month', () => {
    const range = resolveGstReportPeriod({ month: '2025-04' });
    expect(range.key).toBe('month_2025-04');
  });
});
