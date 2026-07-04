import type {
  PartyStatementQuery,
  ReportBaseQuery,
  ReportDateQuery,
  ReportExtendedQuery,
} from '../reports.schema';
import type { ReportPeriodMeta } from '../reports.types';
import {
  resolveReportPeriod,
  type ResolvedReportPeriod,
} from '../../../shared/reporting/report-period';

export function toPeriodMeta(range: ResolvedReportPeriod): ReportPeriodMeta {
  return {
    period: range.key,
    from: range.from.toISOString(),
    to: range.to.toISOString(),
  };
}

export function resolveRange(
  query: ReportBaseQuery | ReportExtendedQuery | PartyStatementQuery,
): ResolvedReportPeriod {
  return resolveReportPeriod({
    period: query.period,
    from: query.from,
    to: query.to,
  });
}

export function resolveSingleDate(query: ReportDateQuery): Date {
  if (query.date) {
    return new Date(query.date);
  }
  const range = resolveRange(query);
  return range.from;
}

export function paginateSlice<T>(
  rows: T[],
  page: number,
  limit: number,
): { rows: T[]; total: number } {
  const total = rows.length;
  const offset = (page - 1) * limit;
  return {
    total,
    rows: rows.slice(offset, offset + limit),
  };
}

export function isUuid(value: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
    value,
  );
}
