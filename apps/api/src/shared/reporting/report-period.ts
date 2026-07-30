import { AppError } from '../errors/app-error';

export type ResolvedReportPeriod = {
  key: string;
  from: Date;
  to: Date;
};

const IST_OFFSET_MS = 5.5 * 60 * 60 * 1000;

function startOfDayInIst(date: Date): Date {
  const ist = new Date(date.getTime() + IST_OFFSET_MS);
  const utcStart = Date.UTC(
    ist.getUTCFullYear(),
    ist.getUTCMonth(),
    ist.getUTCDate(),
  );
  return new Date(utcStart - IST_OFFSET_MS);
}

function addDays(date: Date, days: number): Date {
  return new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
}

function startOfWeekInIst(date: Date): Date {
  const dayStart = startOfDayInIst(date);
  const ist = new Date(dayStart.getTime() + IST_OFFSET_MS);
  const day = ist.getUTCDay();
  const diff = day === 0 ? 6 : day - 1;
  return addDays(dayStart, -diff);
}

function startOfMonthInIst(date: Date): Date {
  const ist = new Date(date.getTime() + IST_OFFSET_MS);
  const utcStart = Date.UTC(ist.getUTCFullYear(), ist.getUTCMonth(), 1);
  return new Date(utcStart - IST_OFFSET_MS);
}

function startOfQuarterInIst(date: Date): Date {
  const ist = new Date(date.getTime() + IST_OFFSET_MS);
  const quarterMonth = Math.floor(ist.getUTCMonth() / 3) * 3;
  const utcStart = Date.UTC(ist.getUTCFullYear(), quarterMonth, 1);
  return new Date(utcStart - IST_OFFSET_MS);
}

function startOfYearInIst(date: Date): Date {
  const ist = new Date(date.getTime() + IST_OFFSET_MS);
  const utcStart = Date.UTC(ist.getUTCFullYear(), 0, 1);
  return new Date(utcStart - IST_OFFSET_MS);
}

export function resolveReportPeriod(params: {
  period?: string;
  from?: string;
  to?: string;
  now?: Date;
}): ResolvedReportPeriod {
  const now = params.now ?? new Date();
  const key = params.period ?? 'this_month';

  if (key === 'custom') {
    if (!params.from || !params.to) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Custom period requires from and to',
        400,
      );
    }
    const from = new Date(params.from);
    const to = new Date(params.to);
    if (Number.isNaN(from.getTime()) || Number.isNaN(to.getTime())) {
      throw new AppError('VALIDATION_ERROR', 'Invalid date range', 400);
    }
    if (from >= to) {
      throw new AppError('VALIDATION_ERROR', 'from must be before to', 400);
    }
    return { key, from, to };
  }

  const end = addDays(startOfDayInIst(now), 1);
  const todayStart = startOfDayInIst(now);
  const yesterdayStart = addDays(todayStart, -1);

  switch (key) {
    case 'today':
      return { key, from: todayStart, to: end };
    case 'yesterday':
      return { key, from: yesterdayStart, to: todayStart };
    case 'this_week':
      return { key, from: startOfWeekInIst(now), to: end };
    case 'last_week': {
      const thisWeekStart = startOfWeekInIst(now);
      const lastWeekStart = addDays(thisWeekStart, -7);
      return { key, from: lastWeekStart, to: thisWeekStart };
    }
    case 'this_month':
      return { key, from: startOfMonthInIst(now), to: end };
    case 'last_month': {
      const thisMonthStart = startOfMonthInIst(now);
      const lastMonthStart = startOfMonthInIst(addDays(thisMonthStart, -1));
      return { key, from: lastMonthStart, to: thisMonthStart };
    }
    case 'this_quarter':
      return { key, from: startOfQuarterInIst(now), to: end };
    case 'this_year':
      return { key, from: startOfYearInIst(now), to: end };
    case 'all_time':
      return { key, from: new Date(0), to: end };
    default:
      throw new AppError('VALIDATION_ERROR', 'Invalid period', 400, {
        period: ['Unsupported period value'],
      });
  }
}
