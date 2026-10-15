import { addPaise, parseMoneyToPaise, type MoneyPaise } from '../../gst-reports/core/gst-money';
import { signedPaiseForMovement, type MovementDirection } from './signed-amount';

export type BalanceMovementRow = {
  occurredAt: Date;
  createdAt: Date;
  id: string;
  direction: MovementDirection;
  amount: string;
};

const IST_OFFSET_MS = 5.5 * 60 * 60 * 1000;

export function startOfDayIstFromDateKey(dateKey: string): Date {
  const [y = 1970, m = 1, d = 1] = dateKey.split('-').map(Number);
  const utcMidnight = Date.UTC(y, m - 1, d);
  return new Date(utcMidnight - IST_OFFSET_MS);
}

/** Movements before opening_balance_as_of (start of that IST day) are ignored. */
export function balanceAtFromMovements(
  openingBalance: string,
  openingBalanceAsOf: string,
  movements: BalanceMovementRow[],
  asOfExclusive: Date,
): MoneyPaise {
  const asOfKey = asOfExclusive.toISOString();
  const cutoff = startOfDayIstFromDateKey(openingBalanceAsOf);
  let balance = parseMoneyToPaise(openingBalance);

  const sorted = [...movements].sort(
    (a, b) =>
      a.occurredAt.getTime() - b.occurredAt.getTime() ||
      a.createdAt.getTime() - b.createdAt.getTime() ||
      a.id.localeCompare(b.id),
  );

  for (const row of sorted) {
    if (row.occurredAt < cutoff) {
      continue;
    }
    if (row.occurredAt >= asOfExclusive) {
      break;
    }
    balance = addPaise(
      balance,
      signedPaiseForMovement(row.direction, row.amount),
    );
  }

  return balance;
}

export function sumSignedMovementsInRange(
  openingBalance: string,
  openingBalanceAsOf: string,
  movements: BalanceMovementRow[],
  rangeFrom: Date,
  rangeTo: Date,
): { opening: MoneyPaise; closing: MoneyPaise } {
  const opening = balanceAtFromMovements(
    openingBalance,
    openingBalanceAsOf,
    movements,
    rangeFrom,
  );
  const closing = balanceAtFromMovements(
    openingBalance,
    openingBalanceAsOf,
    movements,
    rangeTo,
  );
  return { opening, closing };
}
