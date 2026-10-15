import {
  addPaise,
  formatPaise,
  negatePaise,
  parseMoneyToPaise,
  zeroPaise,
} from '../../gst-reports/core/gst-money';
import { lineTaxablePaise } from '../../gst-reports/core/line-taxable';
import type { GstLineModel } from '../../gst-reports/core/models';
import { WarningCollector } from '../../gst-reports/core/warning-collector';
import type { GstReportSection } from '../../gst-reports/gst-reports.types';
import {
  transactionKind,
  transactionLabel,
  type RegisterDoc,
} from './gst-register-filters';

type LineAgg = {
  taxable: bigint;
  cgst: bigint;
  sgst: bigint;
  igst: bigint;
  cess: bigint;
};

function aggregateLines(lines: GstLineModel[]): LineAgg {
  let taxable = zeroPaise();
  let cgst = zeroPaise();
  let sgst = zeroPaise();
  let igst = zeroPaise();
  let cess = zeroPaise();
  for (const line of lines) {
    taxable = addPaise(taxable, lineTaxablePaise(line));
    cgst = addPaise(cgst, parseMoneyToPaise(line.cgstAmount));
    sgst = addPaise(sgst, parseMoneyToPaise(line.sgstAmount));
    igst = addPaise(igst, parseMoneyToPaise(line.igstAmount));
    cess = addPaise(cess, parseMoneyToPaise(line.cessAmount));
  }
  return { taxable, cgst, sgst, igst, cess };
}

function signed(paise: bigint, negative: boolean): bigint {
  return negative ? negatePaise(paise) : paise;
}

function formatSigned(paise: bigint): string {
  return formatPaise(paise);
}

function rateLabel(lines: GstLineModel[]): string {
  const rates = new Set(
    lines.map((l) => l.taxRate).filter((r) => r && r !== '0'),
  );
  if (rates.size === 0) return '0';
  if (rates.size === 1) return `${[...rates][0]}%`;
  return 'Multiple';
}

function isOutputSide(entry: RegisterDoc): boolean {
  const kind = transactionKind(entry.doc, entry.side);
  return kind === 'sale' || kind === 'credit_note';
}

function isNegativeEffect(entry: RegisterDoc): boolean {
  const kind = transactionKind(entry.doc, entry.side);
  return kind === 'credit_note' || kind === 'debit_note';
}

export type GstRegisterResult = {
  rows: Record<string, string>[];
  summary: Record<string, string>;
  warnings: ReturnType<WarningCollector['toArray']>;
};

export function buildGstTransactionRegister(
  entries: RegisterDoc[],
  businessStateCode: string,
): GstRegisterResult {
  const warnings = new WarningCollector();

  const rows: Record<string, string>[] = [];
  let outTaxable = zeroPaise();
  let outCgst = zeroPaise();
  let outSgst = zeroPaise();
  let outIgst = zeroPaise();
  let outCess = zeroPaise();
  let inTaxable = zeroPaise();
  let inCgst = zeroPaise();
  let inSgst = zeroPaise();
  let inIgst = zeroPaise();
  let inCess = zeroPaise();

  for (const entry of entries) {
    const { doc } = entry;
    const kind = transactionKind(doc, entry.side);
    const neg = isNegativeEffect(entry);
    const agg = aggregateLines(doc.lines);
    const totalTax = addPaise(agg.cgst, agg.sgst, agg.igst, agg.cess);

    const gstin = doc.party.gstin ?? '';
    if (!gstin && doc.isGstFormal) {
      warnings.add(
        'MISSING_PARTY_GSTIN',
        'GSTIN missing on formal invoice',
        doc.id,
      );
    }

    const place =
      doc.partyStateCode ?? doc.party.stateCode ?? businessStateCode ?? '';

    rows.push({
      document_id: doc.id,
      party_id: doc.party.id ?? '',
      date: doc.documentDate.toISOString(),
      document_no: doc.documentNumber ?? '',
      transaction_type: transactionLabel(kind),
      party_name: doc.party.name ?? '',
      gstin,
      place_of_supply: place,
      tax_rate: rateLabel(doc.lines),
      taxable_value: formatSigned(signed(agg.taxable, neg)),
      cgst: formatSigned(signed(agg.cgst, neg)),
      sgst: formatSigned(signed(agg.sgst, neg)),
      igst: formatSigned(signed(agg.igst, neg)),
      cess: formatSigned(signed(agg.cess, neg)),
      total_tax: formatSigned(signed(totalTax, neg)),
      document_total: formatSigned(
        signed(parseMoneyToPaise(doc.totalAmount), neg),
      ),
    });

    const taxableSigned = signed(agg.taxable, neg);
    const cgstSigned = signed(agg.cgst, neg);
    const sgstSigned = signed(agg.sgst, neg);
    const igstSigned = signed(agg.igst, neg);
    const cessSigned = signed(agg.cess, neg);

    if (isOutputSide(entry)) {
      outTaxable = addPaise(outTaxable, taxableSigned);
      outCgst = addPaise(outCgst, cgstSigned);
      outSgst = addPaise(outSgst, sgstSigned);
      outIgst = addPaise(outIgst, igstSigned);
      outCess = addPaise(outCess, cessSigned);
    } else {
      inTaxable = addPaise(inTaxable, taxableSigned);
      inCgst = addPaise(inCgst, cgstSigned);
      inSgst = addPaise(inSgst, sgstSigned);
      inIgst = addPaise(inIgst, igstSigned);
      inCess = addPaise(inCess, cessSigned);
    }
  }

  rows.sort((a, b) => (a.date ?? '').localeCompare(b.date ?? ''));

  const outTotalTax = addPaise(outCgst, outSgst, outIgst, outCess);
  const inTotalTax = addPaise(inCgst, inSgst, inIgst, inCess);
  const netTax = addPaise(outTotalTax, negatePaise(inTotalTax));

  const summary = {
    output_taxable: formatPaise(outTaxable),
    output_cgst: formatPaise(outCgst),
    output_sgst: formatPaise(outSgst),
    output_igst: formatPaise(outIgst),
    output_cess: formatPaise(outCess),
    output_total_tax: formatPaise(outTotalTax),
    input_taxable: formatPaise(inTaxable),
    input_cgst: formatPaise(inCgst),
    input_sgst: formatPaise(inSgst),
    input_igst: formatPaise(inIgst),
    input_cess: formatPaise(inCess),
    input_total_tax: formatPaise(inTotalTax),
    net_tax_payable: formatPaise(netTax),
  };

  return { rows, summary, warnings: warnings.toArray() };
}

export function registerSectionFromRows(
  rows: Record<string, string>[],
  summary: Record<string, string>,
): GstReportSection {
  return {
    key: 'register',
    title: 'GST Transaction Register',
    rows,
    totals: summary,
  };
}
