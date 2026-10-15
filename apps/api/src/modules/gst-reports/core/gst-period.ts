import { AppError } from '../../../shared/errors/app-error';
import {
  type ResolvedReportPeriod,
  resolveReportPeriod,
} from '../../../shared/reporting/report-period';
import { FINANCIAL_YEAR_START_MONTH } from './constants';

const IST_OFFSET_MS = 5.5 * 60 * 60 * 1000;

function istParts(date: Date): { year: number; month: number; day: number } {
  const ist = new Date(date.getTime() + IST_OFFSET_MS);
  return {
    year: ist.getUTCFullYear(),
    month: ist.getUTCMonth() + 1,
    day: ist.getUTCDate(),
  };
}

function istStartOfDay(year: number, month: number, day: number): Date {
  const utcStart = Date.UTC(year, month - 1, day);
  return new Date(utcStart - IST_OFFSET_MS);
}

function addDays(date: Date, days: number): Date {
  return new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
}

function financialYearStartYear(reference: Date, explicitFy?: string): number {
  if (explicitFy) {
    const match = /^(\d{4})-(\d{2})$/.exec(explicitFy.trim());
    if (!match) {
      throw new AppError('VALIDATION_ERROR', 'Invalid financial_year', 400);
    }
    return Number.parseInt(match[1]!, 10);
  }
  const { year, month } = istParts(reference);
  return month >= FINANCIAL_YEAR_START_MONTH ? year : year - 1;
}

export type GstPeriodQuery = {
  period?: string;
  from?: string;
  to?: string;
  financial_year?: string;
  month?: string;
  quarter?: string;
};

export function resolveGstReportPeriod(
  query: GstPeriodQuery,
  now = new Date(),
): ResolvedReportPeriod {
  if (query.financial_year) {
    const startYear = financialYearStartYear(now, query.financial_year);
    const from = istStartOfDay(startYear, FINANCIAL_YEAR_START_MONTH, 1);
    const to = istStartOfDay(startYear + 1, FINANCIAL_YEAR_START_MONTH, 1);
    return { key: `fy_${startYear}_${startYear + 1}`, from, to };
  }

  if (query.month) {
    const match = /^(\d{4})-(\d{2})$/.exec(query.month.trim());
    if (!match) {
      throw new AppError('VALIDATION_ERROR', 'Invalid month (YYYY-MM)', 400);
    }
    const year = Number.parseInt(match[1]!, 10);
    const month = Number.parseInt(match[2]!, 10);
    const from = istStartOfDay(year, month, 1);
    const to =
      month === 12
        ? istStartOfDay(year + 1, 1, 1)
        : istStartOfDay(year, month + 1, 1);
    return { key: `month_${query.month}`, from, to };
  }

  if (query.quarter) {
    const match = /^(\d{4})-Q([1-4])$/.exec(query.quarter.trim());
    if (!match) {
      throw new AppError('VALIDATION_ERROR', 'Invalid quarter (YYYY-Qn)', 400);
    }
    const year = Number.parseInt(match[1]!, 10);
    const q = Number.parseInt(match[2]!, 10);
    const startMonth = (q - 1) * 3 + 1;
    const from = istStartOfDay(year, startMonth, 1);
    const endMonth = startMonth + 3;
    const to =
      endMonth > 12
        ? istStartOfDay(year + 1, endMonth - 12, 1)
        : istStartOfDay(year, endMonth, 1);
    return { key: `quarter_${query.quarter}`, from, to };
  }

  return resolveReportPeriod({
    period: query.period,
    from: query.from,
    to: query.to,
    now,
  });
}

export function listFinancialYearMonths(
  range: ResolvedReportPeriod,
): ResolvedReportPeriod[] {
  const months: ResolvedReportPeriod[] = [];
  let cursor = range.from;
  while (cursor < range.to) {
    const { year, month } = istParts(cursor);
    const from = istStartOfDay(year, month, 1);
    const to =
      month === 12
        ? istStartOfDay(year + 1, 1, 1)
        : istStartOfDay(year, month + 1, 1);
    const end = to > range.to ? range.to : to;
    months.push({
      key: `month_${year}-${month.toString().padStart(2, '0')}`,
      from,
      to: end,
    });
    cursor = to;
  }
  return months;
}
