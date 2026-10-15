import { describe, expect, test } from 'bun:test';
import { buildGstr1Report } from '../../src/modules/gst-reports/reports/gstr1.calculator';
import type { GstDataset } from '../../src/modules/gst-reports/core/models';

const emptyDataset: GstDataset = {
  business: {
    id: 'b1',
    gstin: '27AAAAA0000A1Z5',
    stateCode: '27',
  },
  sales: [],
  purchases: [],
  cancelledBySeries: [],
};

describe('gst-reports integration (calculators)', () => {
  test('GSTR-1 returns envelope sections for empty dataset', () => {
    const report = buildGstr1Report(emptyDataset, { nonTaxAsExempt: false });
    expect(report.sections.length).toBeGreaterThan(0);
    expect(report.warnings).toEqual([]);
  });
});
