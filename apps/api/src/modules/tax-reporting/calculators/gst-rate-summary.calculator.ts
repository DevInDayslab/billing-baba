import {
  addPaise,
  formatPaise,
  parseMoneyToPaise,
  zeroPaise,
} from '../../gst-reports/core/gst-money';
import { lineTaxablePaise } from '../../gst-reports/core/line-taxable';
import type { GstLineModel } from '../../gst-reports/core/models';
import type { GstReportSection } from '../../gst-reports/gst-reports.types';
import {
  transactionKind,
  type RegisterDoc,
} from './gst-register-filters';

type RateBucket = {
  rate: string;
  saleTaxable: bigint;
  saleCgst: bigint;
  saleSgst: bigint;
  saleIgst: bigint;
  saleCess: bigint;
  purchaseTaxable: bigint;
  purchaseCgst: bigint;
  purchaseSgst: bigint;
  purchaseIgst: bigint;
  purchaseCess: bigint;
};

function bucketKey(rate: string): string {
  return rate || '0';
}

function applyLine(
  bucket: RateBucket,
  line: GstLineModel,
  side: 'sale' | 'purchase',
  negative: boolean,
) {
  const sign = negative ? -1n : 1n;
  const mul = (v: bigint) => v * sign;
  const taxable = mul(lineTaxablePaise(line));
  const cgst = mul(parseMoneyToPaise(line.cgstAmount));
  const sgst = mul(parseMoneyToPaise(line.sgstAmount));
  const igst = mul(parseMoneyToPaise(line.igstAmount));
  const cess = mul(parseMoneyToPaise(line.cessAmount));

  if (side === 'sale') {
    bucket.saleTaxable = addPaise(bucket.saleTaxable, taxable);
    bucket.saleCgst = addPaise(bucket.saleCgst, cgst);
    bucket.saleSgst = addPaise(bucket.saleSgst, sgst);
    bucket.saleIgst = addPaise(bucket.saleIgst, igst);
    bucket.saleCess = addPaise(bucket.saleCess, cess);
  } else {
    bucket.purchaseTaxable = addPaise(bucket.purchaseTaxable, taxable);
    bucket.purchaseCgst = addPaise(bucket.purchaseCgst, cgst);
    bucket.purchaseSgst = addPaise(bucket.purchaseSgst, sgst);
    bucket.purchaseIgst = addPaise(bucket.purchaseIgst, igst);
    bucket.purchaseCess = addPaise(bucket.purchaseCess, cess);
  }
}

export function buildGstRateSummary(entries: RegisterDoc[]): {
  rows: Record<string, string>[];
  totals: Record<string, string>;
} {
  const buckets = new Map<string, RateBucket>();

  for (const entry of entries) {
    const kind = transactionKind(entry.doc, entry.side);
    const negative = kind === 'credit_note' || kind === 'debit_note';
    const side = entry.side;
    for (const line of entry.doc.lines) {
      const key = bucketKey(line.taxRate);
      let bucket = buckets.get(key);
      if (!bucket) {
        bucket = {
          rate: key,
          saleTaxable: zeroPaise(),
          saleCgst: zeroPaise(),
          saleSgst: zeroPaise(),
          saleIgst: zeroPaise(),
          saleCess: zeroPaise(),
          purchaseTaxable: zeroPaise(),
          purchaseCgst: zeroPaise(),
          purchaseSgst: zeroPaise(),
          purchaseIgst: zeroPaise(),
          purchaseCess: zeroPaise(),
        };
        buckets.set(key, bucket);
      }
      applyLine(bucket, line, side, negative);
    }
  }

  const sorted = [...buckets.values()].sort(
    (a, b) => Number(b.rate) - Number(a.rate),
  );

  let gtSaleTaxable = zeroPaise();
  let gtSaleTax = zeroPaise();
  let gtPurchaseTaxable = zeroPaise();
  let gtPurchaseTax = zeroPaise();

  const rows = sorted.map((b) => {
    const saleTax = addPaise(b.saleCgst, b.saleSgst, b.saleIgst, b.saleCess);
    const purchaseTax = addPaise(
      b.purchaseCgst,
      b.purchaseSgst,
      b.purchaseIgst,
      b.purchaseCess,
    );
    gtSaleTaxable = addPaise(gtSaleTaxable, b.saleTaxable);
    gtSaleTax = addPaise(gtSaleTax, saleTax);
    gtPurchaseTaxable = addPaise(gtPurchaseTaxable, b.purchaseTaxable);
    gtPurchaseTax = addPaise(gtPurchaseTax, purchaseTax);

    return {
      tax_rate: b.rate,
      tax_name: `GST ${b.rate}%`,
      taxable_sale: formatPaise(b.saleTaxable),
      sale_cgst: formatPaise(b.saleCgst),
      sale_sgst: formatPaise(b.saleSgst),
      sale_igst: formatPaise(b.saleIgst),
      sale_cess: formatPaise(b.saleCess),
      sale_total_tax: formatPaise(saleTax),
      taxable_purchase: formatPaise(b.purchaseTaxable),
      purchase_cgst: formatPaise(b.purchaseCgst),
      purchase_sgst: formatPaise(b.purchaseSgst),
      purchase_igst: formatPaise(b.purchaseIgst),
      purchase_cess: formatPaise(b.purchaseCess),
      purchase_total_tax: formatPaise(purchaseTax),
    };
  });

  const totals = {
    taxable_sale: formatPaise(gtSaleTaxable),
    sale_total_tax: formatPaise(gtSaleTax),
    taxable_purchase: formatPaise(gtPurchaseTaxable),
    purchase_total_tax: formatPaise(gtPurchaseTax),
  };

  return { rows, totals };
}

export function rateSummarySection(
  rows: Record<string, string>[],
  totals: Record<string, string>,
): GstReportSection {
  return {
    key: 'rate_summary',
    title: 'GST Rate Summary',
    rows,
    totals,
  };
}
