import {
  resolveReportPeriod,
  type ResolvedReportPeriod,
} from '../../shared/reporting/report-period';

export type ResolvedDashboardPeriod = ResolvedReportPeriod;

export function resolveDashboardPeriod(params: {
  period?: string;
  from?: string;
  to?: string;
  now?: Date;
}): ResolvedDashboardPeriod {
  return resolveReportPeriod(params);
}
