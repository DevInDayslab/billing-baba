const IST_OFFSET_MS = 5.5 * 60 * 60 * 1000;

export function todayIstDateKey(now = new Date()): string {
  const ist = new Date(now.getTime() + IST_OFFSET_MS);
  const y = ist.getUTCFullYear();
  const m = String(ist.getUTCMonth() + 1).padStart(2, '0');
  const d = String(ist.getUTCDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

export function expenseDateToOccurredAt(expenseDate: string): Date {
  const [y = 1970, m = 1, d = 1] = expenseDate.split('-').map(Number);
  const utcMidnight = Date.UTC(y, m - 1, d);
  return new Date(utcMidnight - IST_OFFSET_MS);
}
