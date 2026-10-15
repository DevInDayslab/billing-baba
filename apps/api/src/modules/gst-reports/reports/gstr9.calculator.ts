import type { ResolvedReportPeriod } from '../../../shared/reporting/report-period';
import type { GstDataset } from '../core/models';
import { listFinancialYearMonths } from '../core/gst-period';
import type { GstReportEnvelope } from '../gst-reports.types';
import { buildGstr1Report } from './gstr1.calculator';
import { buildGstr3bReport } from './gstr3b.calculator';
import { addPaise, formatPaise, parseMoneyToPaise } from '../core/gst-money';

export type Gstr9Options = {
  nonTaxAsExempt: boolean;
  filterDataset: (
    dataset: GstDataset,
    monthRange: ResolvedReportPeriod,
  ) => GstDataset;
};

function filterByDate<T extends { documentDate: Date }>(
  items: T[],
  range: ResolvedReportPeriod,
): T[] {
  return items.filter(
    (item) => item.documentDate >= range.from && item.documentDate < range.to,
  );
}

export function buildGstr9Report(
  fullDataset: GstDataset,
  fyRange: ResolvedReportPeriod,
  options: Gstr9Options,
): GstReportEnvelope {
  const months = listFinancialYearMonths(fyRange);
  const monthlyRows: Record<string, unknown>[] = [];

  let annualTaxable = BigInt(0);
  let annualIgst = BigInt(0);

  for (const month of months) {
    const monthData: GstDataset = {
      ...fullDataset,
      sales: filterByDate(fullDataset.sales, month),
      purchases: filterByDate(fullDataset.purchases, month),
      cancelledBySeries: fullDataset.cancelledBySeries,
    };

    const gstr3b = buildGstr3bReport(monthData, {
      nonTaxAsExempt: options.nonTaxAsExempt,
    });
    const row31 = gstr3b.sections.find((s) => s.key === 'table_3_1')?.rows[0] as
      | Record<string, string>
      | undefined;
    const taxable = parseMoneyToPaise(row31?.taxable_value ?? '0');
    const igst = parseMoneyToPaise(row31?.igst ?? '0');
    annualTaxable = addPaise(annualTaxable, taxable);
    annualIgst = addPaise(annualIgst, igst);

    monthlyRows.push({
      month: month.key,
      from: month.from.toISOString(),
      to: month.to.toISOString(),
      taxable_value: formatPaise(taxable),
      igst: formatPaise(igst),
    });
  }

  const annual3b = buildGstr3bReport(fullDataset, {
    nonTaxAsExempt: options.nonTaxAsExempt,
  });
  const annualGstr1 = buildGstr1Report(fullDataset, {
    nonTaxAsExempt: options.nonTaxAsExempt,
  });

  return {
    meta: {
      period: fyRange.key,
      from: fyRange.from.toISOString(),
      to: fyRange.to.toISOString(),
      business_id: fullDataset.business.id,
      generated_at: new Date().toISOString(),
      flags: {
        non_tax_as_exempt: options.nonTaxAsExempt,
        disclaimer:
          'Books-based summary for management; not a filing-ready GSTR-9.',
      } as GstReportEnvelope['meta']['flags'],
    },
    sections: [
      {
        key: 'monthly',
        title: 'Monthly summary (Apr–Mar)',
        rows: monthlyRows,
        totals: {
          taxable_value: formatPaise(annualTaxable),
          igst: formatPaise(annualIgst),
        },
      },
      {
        key: 'annual_3b',
        title: 'Annual GSTR-3B summary',
        rows: annual3b.sections.flatMap((s) => s.rows),
      },
      {
        key: 'annual_gstr1_highlights',
        title: 'Annual outward highlights',
        rows: annualGstr1.sections
          .filter((s) => ['b2b', 'b2cl', 'b2cs'].includes(s.key))
          .flatMap((s) => s.rows),
      },
    ],
    totals: {
      annual_taxable: formatPaise(annualTaxable),
    },
    warnings: [...annual3b.warnings, ...annualGstr1.warnings],
  };
}
