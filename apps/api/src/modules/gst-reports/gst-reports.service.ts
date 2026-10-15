import type { Database } from '../../db/client';
import type { ResolvedReportPeriod } from '../../shared/reporting/report-period';
import { GstDataRepository } from './data/gst-data.repository';
import { resolveGstReportPeriod } from './core/gst-period';
import type { GstReportQuery } from './gst-reports.schema';
import type { GstReportEnvelope } from './gst-reports.types';
import { buildHsnSummary } from './reports/hsn-summary.calculator';
import { buildGstr1Report } from './reports/gstr1.calculator';
import { buildGstr2Report } from './reports/gstr2.calculator';
import { buildGstr3bReport } from './reports/gstr3b.calculator';
import { buildGstr9Report } from './reports/gstr9.calculator';
import { mapGstr1ToGstnJson } from './exports/gstn-gstr1.mapper';
import { mapGstr3bToGstnJson } from './exports/gstn-gstr3b.mapper';

export class GstReportsService {
  private readonly data: GstDataRepository;

  constructor(db: Database) {
    this.data = new GstDataRepository(db);
  }

  private withMeta(
    envelope: GstReportEnvelope,
    range: ResolvedReportPeriod,
    businessId: string,
    query: GstReportQuery,
  ): GstReportEnvelope {
    return {
      ...envelope,
      meta: {
        ...envelope.meta,
        period: range.key,
        from: range.from.toISOString(),
        to: range.to.toISOString(),
        business_id: businessId,
        generated_at: new Date().toISOString(),
        flags: {
          ...envelope.meta.flags,
          non_tax_as_exempt: query.non_tax_as_exempt,
          financial_year: query.financial_year,
        },
      },
    };
  }

  async getHsnSummary(
    businessId: string,
    query: GstReportQuery,
  ): Promise<GstReportEnvelope> {
    const range = resolveGstReportPeriod(query);
    const dataset = await this.data.loadDataset(businessId, range);
    const { section, warnings } = buildHsnSummary(dataset, {
      itemType: 'product',
      codeField: 'hsn',
    });
    return this.withMeta(
      {
        meta: { period: '', from: '', to: '', business_id: businessId, generated_at: '', flags: {} },
        sections: [section],
        totals: section.totals ?? {},
        warnings: warnings.toArray(),
      },
      range,
      businessId,
      query,
    );
  }

  async getSacReport(
    businessId: string,
    query: GstReportQuery,
  ): Promise<GstReportEnvelope> {
    const range = resolveGstReportPeriod(query);
    const dataset = await this.data.loadDataset(businessId, range);
    const { section, warnings } = buildHsnSummary(dataset, {
      itemType: 'service',
      codeField: 'sac',
    });
    return this.withMeta(
      {
        meta: { period: '', from: '', to: '', business_id: businessId, generated_at: '', flags: {} },
        sections: [section],
        totals: section.totals ?? {},
        warnings: warnings.toArray(),
      },
      range,
      businessId,
      query,
    );
  }

  async getGstr1(
    businessId: string,
    query: GstReportQuery,
  ): Promise<GstReportEnvelope | Record<string, unknown>> {
    const range = resolveGstReportPeriod(query);
    const dataset = await this.data.loadDataset(businessId, range);
    const envelope = this.withMeta(
      buildGstr1Report(dataset, {
        nonTaxAsExempt: query.non_tax_as_exempt ?? false,
      }),
      range,
      businessId,
      query,
    );
    if (query.format === 'gstn_json') {
      return mapGstr1ToGstnJson(envelope);
    }
    return envelope;
  }

  async getGstr2(
    businessId: string,
    query: GstReportQuery,
  ): Promise<GstReportEnvelope> {
    const range = resolveGstReportPeriod(query);
    const dataset = await this.data.loadDataset(businessId, range);
    return this.withMeta(buildGstr2Report(dataset), range, businessId, query);
  }

  async getGstr3b(
    businessId: string,
    query: GstReportQuery,
  ): Promise<GstReportEnvelope | Record<string, unknown>> {
    const range = resolveGstReportPeriod(query);
    const dataset = await this.data.loadDataset(businessId, range);
    const envelope = this.withMeta(
      buildGstr3bReport(dataset, {
        nonTaxAsExempt: query.non_tax_as_exempt ?? false,
      }),
      range,
      businessId,
      query,
    );
    if (query.format === 'gstn_json') {
      return mapGstr3bToGstnJson(envelope);
    }
    return envelope;
  }

  async getGstr9(
    businessId: string,
    query: GstReportQuery,
  ): Promise<GstReportEnvelope> {
    const range = query.financial_year
      ? resolveGstReportPeriod({ financial_year: query.financial_year })
      : resolveGstReportPeriod({
          financial_year: undefined,
          period: query.period ?? 'this_month',
          from: query.from,
          to: query.to,
        });
    const fyRange =
      query.financial_year || query.period === 'financial_year'
        ? range
        : resolveGstReportPeriod({
            financial_year: `${new Date().getFullYear()}-${(new Date().getFullYear() + 1).toString().slice(-2)}`,
          });
    const dataset = await this.data.loadDataset(businessId, fyRange);
    return this.withMeta(
      buildGstr9Report(dataset, fyRange, {
        nonTaxAsExempt: query.non_tax_as_exempt ?? false,
        filterDataset: (d, m) => d,
      }),
      fyRange,
      businessId,
      query,
    );
  }
}
