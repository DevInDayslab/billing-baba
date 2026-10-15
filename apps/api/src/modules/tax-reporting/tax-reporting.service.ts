import type { Database } from '../../db/client';
import { resolveGstReportPeriod } from '../gst-reports/core/gst-period';
import { GstDataRepository } from '../gst-reports/data/gst-data.repository';
import type { GstReportEnvelope } from '../gst-reports/gst-reports.types';
import { paginateSlice } from '../reports/repositories/reports.helpers';
import { buildGstRateSummary, rateSummarySection } from './calculators/gst-rate-summary.calculator';
import { filterRegisterDocs } from './calculators/gst-register-filters';
import {
  buildGstTransactionRegister,
  registerSectionFromRows,
} from './calculators/gst-transaction-register.calculator';
import type { TaxReportQuery } from './tax-reporting.schema';
import {
  buildForm27eqRows,
  form27eqTotals,
} from '../withholding-tax/calculators/form-27eq.calculator';
import {
  buildWithholdingSummaryRows,
  summaryTotals,
} from '../withholding-tax/calculators/withholding-summary.calculator';
import { WithholdingTaxEntryRepository } from '../withholding-tax/withholding-tax-entry.repository';

export class TaxReportingService {
  private readonly data: GstDataRepository;
  private readonly withholdingEntries: WithholdingTaxEntryRepository;

  constructor(db: Database) {
    this.data = new GstDataRepository(db);
    this.withholdingEntries = new WithholdingTaxEntryRepository(db);
  }

  private envelope(
    businessId: string,
    range: ReturnType<typeof resolveGstReportPeriod>,
    sections: GstReportEnvelope['sections'],
    totals: Record<string, string>,
    warnings: GstReportEnvelope['warnings'],
  ): GstReportEnvelope {
    return {
      meta: {
        period: range.key,
        from: range.from.toISOString(),
        to: range.to.toISOString(),
        business_id: businessId,
        generated_at: new Date().toISOString(),
        flags: {},
      },
      sections,
      totals,
      warnings,
    };
  }

  async getGstRegister(
    businessId: string,
    query: TaxReportQuery,
  ): Promise<{ envelope: GstReportEnvelope; total: number }> {
    const range = resolveGstReportPeriod(query);
    const dataset = await this.data.loadDataset(businessId, range);
    const entries = filterRegisterDocs(dataset, query);
    const { rows, summary, warnings } = buildGstTransactionRegister(
      entries,
      dataset.business.stateCode,
    );
    const { rows: pageRows, total } = paginateSlice(
      rows,
      query.page,
      query.limit,
    );
    const section = registerSectionFromRows(pageRows, summary);
    return {
      total,
      envelope: this.envelope(businessId, range, [section], summary, warnings),
    };
  }

  async getGstRateSummary(
    businessId: string,
    query: TaxReportQuery,
  ): Promise<GstReportEnvelope> {
    const range = resolveGstReportPeriod(query);
    const dataset = await this.data.loadDataset(businessId, range);
    const entries = filterRegisterDocs(dataset, {
      ...query,
      transaction_type: query.transaction_type ?? 'all',
    });
    const { rows, totals } = buildGstRateSummary(entries);
    const section = rateSummarySection(rows, totals);
    return this.envelope(businessId, range, [section], totals, []);
  }

  async getWithholdingReport(
    businessId: string,
    query: TaxReportQuery,
    kind: 'tds' | 'tcs',
    direction: 'payable' | 'receivable',
  ): Promise<GstReportEnvelope> {
    const range = resolveGstReportPeriod(query);
    const entries = await this.withholdingEntries.listInPeriod({
      businessId,
      from: range.from,
      to: range.to,
      kind,
      direction,
    });
    const rows = buildWithholdingSummaryRows(entries);
    const totals = summaryTotals(rows);
    return this.envelope(
      businessId,
      range,
      [
        {
          key: 'summary',
          title: `${kind.toUpperCase()} ${direction}`,
          rows,
          totals,
        },
      ],
      totals,
      [],
    );
  }

  async getForm27eq(
    businessId: string,
    query: TaxReportQuery,
  ): Promise<GstReportEnvelope> {
    const range = resolveGstReportPeriod(query);
    const entries = await this.withholdingEntries.listTcsCollections(
      businessId,
      range.from,
      range.to,
    );
    const rows = buildForm27eqRows(entries);
    const totals = form27eqTotals(rows);
    return this.envelope(
      businessId,
      range,
      [
        {
          key: 'collections',
          title: 'TCS collections',
          rows,
          totals,
        },
      ],
      totals,
      [],
    );
  }
}
