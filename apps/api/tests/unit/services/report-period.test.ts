import { describe, expect, test } from 'bun:test';
import { resolveReportPeriod } from '../../../src/shared/reporting/report-period';

describe('report-period service', () => {
  const now = new Date('2026-07-17T10:30:00.000Z');

  test('resolves this_month in IST', () => {
    const period = resolveReportPeriod({ period: 'this_month', now });
    expect(period.key).toBe('this_month');
    expect(period.from < period.to).toBe(true);
  });

  test('requires from/to for custom periods', () => {
    expect(() => resolveReportPeriod({ period: 'custom', now })).toThrow();
  });

  test('rejects unsupported period values', () => {
    expect(() => resolveReportPeriod({ period: 'invalid', now })).toThrow();
  });
});
