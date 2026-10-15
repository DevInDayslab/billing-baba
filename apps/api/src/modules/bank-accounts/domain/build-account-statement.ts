import {
  addPaise,
  formatPaise,
  parseMoneyToPaise,
  type MoneyPaise,
  zeroPaise,
} from '../../gst-reports/core/gst-money';
import {
  balanceAtFromMovements,
  startOfDayIstFromDateKey,
  type BalanceMovementRow,
} from './balance-at';
import { signedPaiseForMovement } from './signed-amount';

export type StatementMovementRow = BalanceMovementRow & {
  description: string;
  referenceNumber: string | null;
  movementType: string;
  referenceType: string;
  referenceId: string;
};

export type AccountStatementRow = {
  date: string;
  description: string;
  ref_no: string;
  deposit: string;
  withdrawal: string;
  balance: string;
  movement_type: string;
  reference_type: string;
  reference_id: string;
  is_opening: boolean;
};

export type AccountStatementSummary = {
  opening_balance: string;
  total_deposits: string;
  total_withdrawals: string;
  closing_balance: string;
};

export type BuildAccountStatementInput = {
  openingBalance: string;
  openingBalanceAsOf: string;
  movements: StatementMovementRow[];
  rangeFrom: Date;
  rangeTo: Date;
};

export type AccountStatementResult = {
  summary: AccountStatementSummary;
  rows: AccountStatementRow[];
};

export function buildAccountStatement(
  input: BuildAccountStatementInput,
): AccountStatementResult {
  const asOfStart = startOfDayIstFromDateKey(input.openingBalanceAsOf);
  const inRange = input.movements
    .filter(
      (m) => m.occurredAt >= input.rangeFrom && m.occurredAt < input.rangeTo,
    )
    .sort(
      (a, b) =>
        a.occurredAt.getTime() - b.occurredAt.getTime() ||
        a.createdAt.getTime() - b.createdAt.getTime() ||
        a.id.localeCompare(b.id),
    );

  const openingPaise = balanceAtFromMovements(
    input.openingBalance,
    input.openingBalanceAsOf,
    input.movements,
    input.rangeFrom,
  );

  const rows: AccountStatementRow[] = [];
  let running = openingPaise;
  let totalDeposits = zeroPaise();
  let totalWithdrawals = zeroPaise();

  const asOfInsideRange =
    asOfStart >= input.rangeFrom && asOfStart < input.rangeTo;

  if (asOfInsideRange) {
    rows.push({
      date: asOfStart.toISOString(),
      description: 'Opening Balance',
      ref_no: '-',
      deposit: '0',
      withdrawal: '0',
      balance: formatPaise(openingPaise),
      movement_type: 'opening',
      reference_type: 'opening',
      reference_id: '-',
      is_opening: true,
    });
  } else {
    rows.push({
      date: input.rangeFrom.toISOString(),
      description: 'Opening Balance',
      ref_no: '-',
      deposit: '0',
      withdrawal: '0',
      balance: formatPaise(openingPaise),
      movement_type: 'opening',
      reference_type: 'opening',
      reference_id: '-',
      is_opening: true,
    });
  }

  for (const m of inRange) {
    const signed = signedPaiseForMovement(m.direction, m.amount);
    running = addPaise(running, signed);
    const deposit =
      m.direction === 'deposit' ? parseMoneyToPaise(m.amount) : zeroPaise();
    const withdrawal =
      m.direction === 'withdrawal' ? parseMoneyToPaise(m.amount) : zeroPaise();
    totalDeposits = addPaise(totalDeposits, deposit);
    totalWithdrawals = addPaise(totalWithdrawals, withdrawal);

    rows.push({
      date: m.occurredAt.toISOString(),
      description: m.description,
      ref_no: m.referenceNumber ?? '-',
      deposit: deposit > zeroPaise() ? formatPaise(deposit) : '0',
      withdrawal: withdrawal > zeroPaise() ? formatPaise(withdrawal) : '0',
      balance: formatPaise(running),
      movement_type: m.movementType,
      reference_type: m.referenceType,
      reference_id: m.referenceId,
      is_opening: false,
    });
  }

  const closingPaise = balanceAtFromMovements(
    input.openingBalance,
    input.openingBalanceAsOf,
    input.movements,
    input.rangeTo,
  );

  return {
    summary: {
      opening_balance: formatPaise(openingPaise),
      total_deposits: formatPaise(totalDeposits),
      total_withdrawals: formatPaise(totalWithdrawals),
      closing_balance: formatPaise(closingPaise),
    },
    rows,
  };
}
