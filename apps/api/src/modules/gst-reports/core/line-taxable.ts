import { addPaise, parseMoneyToPaise, subtractPaise } from './gst-money';

/** Report taxable value per data contract (stored amounts). */
export function lineTaxablePaise(line: {
  lineTotal: string;
  cgstAmount: string;
  sgstAmount: string;
  igstAmount: string;
  cessAmount: string;
}): bigint {
  const total = parseMoneyToPaise(line.lineTotal);
  const tax = addPaise(
    parseMoneyToPaise(line.cgstAmount),
    parseMoneyToPaise(line.sgstAmount),
    parseMoneyToPaise(line.igstAmount),
    parseMoneyToPaise(line.cessAmount),
  );
  return subtractPaise(total, tax);
}
