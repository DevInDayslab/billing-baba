export type LoanStatementTransaction = {
  id: string;
  date: string;
  transactionType: 'increase' | 'repayment' | 'charges';
  principalAmount: string;
  interestAmount: string;
  chargesAmount: string;
  description: string | null;
  referenceNumber: string | null;
};

export type LoanStatementRow = {
  date: string;
  description: string;
  ref_no: string;
  debit: string;
  credit: string;
  balance: string;
  is_opening: boolean;
};

function principalDelta(txn: LoanStatementTransaction): number {
  const principal = Number(txn.principalAmount ?? 0);
  if (txn.transactionType === 'increase') return principal;
  if (txn.transactionType === 'repayment') return -principal;
  return 0;
}

function labelFor(txn: LoanStatementTransaction): string {
  if (txn.description?.trim()) return txn.description.trim();
  switch (txn.transactionType) {
    case 'increase':
      return 'Loan increase';
    case 'repayment':
      return 'Loan repayment';
    case 'charges':
      return 'Loan charges';
    default:
      return 'Loan transaction';
  }
}

export function computeOpeningOutstanding(
  openingOutstanding: string,
  openingBalanceAsOf: string,
  transactions: LoanStatementTransaction[],
  rangeFromDateKey: string,
): number {
  let balance = Number(openingOutstanding ?? 0);
  const from = rangeFromDateKey;
  const asOf = openingBalanceAsOf;
  const ordered = [...transactions].sort((a, b) => a.date.localeCompare(b.date));
  for (const txn of ordered) {
    if (txn.date < asOf) continue;
    if (txn.date >= from) continue;
    balance += principalDelta(txn);
  }
  return balance;
}

export function buildLoanStatement(input: {
  openingOutstanding: string;
  openingBalanceAsOf: string;
  transactions: LoanStatementTransaction[];
  rangeFrom: Date;
  rangeTo: Date;
}): LoanStatementRow[] {
  const fromKey = input.rangeFrom.toISOString().slice(0, 10);
  const toKey = input.rangeTo.toISOString().slice(0, 10);

  const sorted = [...input.transactions].sort((a, b) =>
    a.date.localeCompare(b.date),
  );

  let balance = computeOpeningOutstanding(
    input.openingOutstanding,
    input.openingBalanceAsOf,
    sorted,
    fromKey,
  );

  const rows: LoanStatementRow[] = [
    {
      date: input.rangeFrom.toISOString(),
      description: 'Opening balance',
      ref_no: '-',
      debit: '0',
      credit: '0',
      balance: balance.toFixed(2),
      is_opening: true,
    },
  ];

  for (const txn of sorted) {
    if (txn.date < fromKey || txn.date >= toKey) continue;

    const delta = principalDelta(txn);
    const credit =
      txn.transactionType === 'increase'
        ? Number(txn.principalAmount ?? 0)
        : 0;
    const debit =
      txn.transactionType === 'repayment'
        ? Number(txn.principalAmount ?? 0)
        : txn.transactionType === 'charges'
          ? Number(txn.chargesAmount ?? 0)
          : 0;

    balance += delta;

    rows.push({
      date: new Date(txn.date).toISOString(),
      description: labelFor(txn),
      ref_no: txn.referenceNumber ?? txn.transactionType,
      debit: debit > 0 ? debit.toFixed(2) : '0',
      credit: credit > 0 ? credit.toFixed(2) : '0',
      balance: balance.toFixed(2),
      is_opening: false,
    });
  }

  return rows;
}
