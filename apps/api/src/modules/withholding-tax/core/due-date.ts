const IST_OFFSET_MS = 5.5 * 60 * 60 * 1000;

function istParts(date: Date): { year: number; month: number; day: number } {
  const ist = new Date(date.getTime() + IST_OFFSET_MS);
  return {
    year: ist.getUTCFullYear(),
    month: ist.getUTCMonth() + 1,
    day: ist.getUTCDate(),
  };
}

/** Deposit due: 7th of next month; March entries due 30 April (IST). */
export function dueDate(entryDate: Date, _kind: 'tds' | 'tcs'): Date {
  const { year, month } = istParts(entryDate);
  if (month === 3) {
    return new Date(Date.UTC(year, 3, 30) - IST_OFFSET_MS);
  }
  const nextMonth = month === 12 ? 1 : month + 1;
  const nextYear = month === 12 ? year + 1 : year;
  return new Date(Date.UTC(nextYear, nextMonth - 1, 7) - IST_OFFSET_MS);
}
