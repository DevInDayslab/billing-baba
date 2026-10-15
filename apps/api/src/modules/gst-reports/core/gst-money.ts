/** Decimal-safe money using integer paise (1 INR = 100 paise). */

export type MoneyPaise = bigint;

const TEN = BigInt(10);

export function zeroPaise(): MoneyPaise {
  return BigInt(0);
}

export function parseMoneyToPaise(value: string | number | null | undefined): MoneyPaise {
  if (value === null || value === undefined || value === '') {
    return zeroPaise();
  }
  const raw = String(value).trim().replace(/,/g, '');
  if (!raw || raw === '-') return zeroPaise();
  const negative = raw.startsWith('-');
  const unsigned = negative ? raw.slice(1) : raw;
  const [whole, frac = ''] = unsigned.split('.');
  const fracPadded = `${frac}00`.slice(0, 2);
  const paise =
    BigInt(whole || '0') * BigInt(100) + BigInt(fracPadded.padEnd(2, '0'));
  return negative ? -paise : paise;
}

export function formatPaise(paise: MoneyPaise): string {
  const negative = paise < zeroPaise();
  const abs = negative ? -paise : paise;
  const whole = abs / BigInt(100);
  const frac = abs % BigInt(100);
  const fracStr = frac.toString().padStart(2, '0');
  return `${negative ? '-' : ''}${whole.toString()}.${fracStr}`;
}

export function addPaise(...values: MoneyPaise[]): MoneyPaise {
  return values.reduce((sum, v) => sum + v, zeroPaise());
}

export function subtractPaise(a: MoneyPaise, b: MoneyPaise): MoneyPaise {
  return a - b;
}

export function negatePaise(value: MoneyPaise): MoneyPaise {
  return -value;
}

export function multiplyPaiseByRatio(
  paise: MoneyPaise,
  numerator: bigint,
  denominator: bigint,
): MoneyPaise {
  if (denominator === zeroPaise()) return zeroPaise();
  return (paise * numerator) / denominator;
}
