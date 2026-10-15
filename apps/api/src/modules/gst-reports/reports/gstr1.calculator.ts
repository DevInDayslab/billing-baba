import {
  addPaise,
  formatPaise,
  parseMoneyToPaise,
} from '../core/gst-money';
import { classifyOutwardSale } from '../core/invoice-classifier';
import { lineTaxablePaise } from '../core/line-taxable';
import { resolvePlaceOfSupplyState } from '../core/place-of-supply';
import type { GstDataset, GstSalesDocumentModel } from '../core/models';
import type { GstReportEnvelope, GstReportSection } from '../gst-reports.types';
import { WarningCollector } from '../core/warning-collector';
import { buildHsnSummary } from './hsn-summary.calculator';

export type Gstr1Options = { nonTaxAsExempt: boolean };

function docRow(
  doc: GstSalesDocumentModel,
  businessState: string,
): Record<string, unknown> {
  const taxable = doc.lines.reduce(
    (sum, line) => addPaise(sum, lineTaxablePaise(line)),
    BigInt(0),
  );
  const igst = doc.lines.reduce(
    (sum, line) => addPaise(sum, parseMoneyToPaise(line.igstAmount)),
    BigInt(0),
  );
  const cgst = doc.lines.reduce(
    (sum, line) => addPaise(sum, parseMoneyToPaise(line.cgstAmount)),
    BigInt(0),
  );
  const sgst = doc.lines.reduce(
    (sum, line) => addPaise(sum, parseMoneyToPaise(line.sgstAmount)),
    BigInt(0),
  );
  const sign = doc.isCreditNote ? BigInt(-1) : BigInt(1);

  return {
    document_id: doc.id,
    gstin: doc.party.gstin ?? '',
    party_name: doc.party.name ?? '',
    invoice_no: doc.documentNumber ?? '',
    invoice_date: doc.documentDate.toISOString(),
    place_of_supply: resolvePlaceOfSupplyState(
      { id: '', gstin: null, stateCode: businessState },
      doc.partyStateCode,
    ),
    value: formatPaise(parseMoneyToPaise(doc.totalAmount) * sign),
    taxable_value: formatPaise(taxable * sign),
    igst: formatPaise(igst * sign),
    cgst: formatPaise(cgst * sign),
    sgst: formatPaise(sgst * sign),
    tax_rate: doc.lines[0]?.taxRate ?? '0',
    original_invoice_no:
      doc.originalDocumentNumber ?? doc.originalDocumentNumber ?? '',
    original_invoice_date: doc.originalDocumentDate?.toISOString() ?? '',
  };
}

export function buildGstr1Report(
  dataset: GstDataset,
  _options: Gstr1Options,
): GstReportEnvelope {
  const warnings = new WarningCollector();
  const sections: GstReportSection[] = [];

  const buckets = {
    b2b: [] as GstSalesDocumentModel[],
    b2cl: [] as GstSalesDocumentModel[],
    b2cs: [] as GstSalesDocumentModel[],
    cdnr: [] as GstSalesDocumentModel[],
    cdnur: [] as GstSalesDocumentModel[],
    exports: [] as GstSalesDocumentModel[],
    nil_exempt: [] as GstSalesDocumentModel[],
  };

  for (const doc of dataset.sales) {
    const cls = classifyOutwardSale(dataset.business, doc);
    if (cls === 'credit_registered') {
      if (!doc.originalDocumentNumber && !doc.originalDocumentId) {
        warnings.add(
          'CREDIT_NOTE_MISSING_ORIGINAL',
          'Credit note missing link to original invoice.',
          doc.id,
        );
      }
      buckets.cdnr.push(doc);
      continue;
    }
    if (cls === 'credit_unregistered') {
      buckets.cdnur.push(doc);
      continue;
    }
    if (cls === 'export') buckets.exports.push(doc);
    else if (cls === 'nil_exempt') buckets.nil_exempt.push(doc);
    else if (cls === 'b2b') buckets.b2b.push(doc);
    else if (cls === 'b2cl') buckets.b2cl.push(doc);
    else buckets.b2cs.push(doc);

    if (!doc.partyStateCode) {
      warnings.add(
        'MISSING_PARTY_STATE',
        'Missing party state; assumed intra-state.',
        doc.id,
      );
    }
  }

  const businessState = dataset.business.stateCode;
  sections.push({
    key: 'b2b',
    title: 'B2B',
    rows: buckets.b2b.map((d) => docRow(d, businessState)),
  });
  sections.push({
    key: 'b2cl',
    title: 'B2C Large',
    rows: buckets.b2cl.map((d) => docRow(d, businessState)),
  });

  // B2CS grouped by place + rate
  const b2csGroups = new Map<string, Record<string, unknown>>();
  for (const doc of buckets.b2cs) {
    const pos = resolvePlaceOfSupplyState(dataset.business, doc.partyStateCode);
    const rate = doc.lines[0]?.taxRate ?? '0';
    const key = `${pos}|${rate}`;
    const taxable = doc.lines.reduce(
      (sum, line) => addPaise(sum, lineTaxablePaise(line)),
      BigInt(0),
    );
    const existing = b2csGroups.get(key);
    if (!existing) {
      b2csGroups.set(key, {
        place_of_supply: pos,
        tax_rate: rate,
        taxable_value: formatPaise(taxable),
        igst: formatPaise(
          doc.lines.reduce(
            (s, l) => addPaise(s, parseMoneyToPaise(l.igstAmount)),
            BigInt(0),
          ),
        ),
      });
    } else {
      existing.taxable_value = formatPaise(
        addPaise(
          parseMoneyToPaise(existing.taxable_value as string),
          taxable,
        ),
      );
    }
  }
  sections.push({
    key: 'b2cs',
    title: 'B2C Small',
    rows: [...b2csGroups.values()],
  });

  sections.push({
    key: 'cdnr',
    title: 'CDNR',
    rows: buckets.cdnr.map((d) => docRow(d, businessState)),
  });
  sections.push({
    key: 'cdnur',
    title: 'CDNUR',
    rows: buckets.cdnur.map((d) => docRow(d, businessState)),
  });
  sections.push({
    key: 'exports',
    title: 'Exports',
    rows: buckets.exports.map((d) => docRow(d, businessState)),
  });
  sections.push({
    key: 'nil_exempt',
    title: 'Nil / Exempt / Non-GST',
    rows: buckets.nil_exempt.map((d) => docRow(d, businessState)),
  });

  const hsn = buildHsnSummary(dataset, {
    itemType: 'product',
    codeField: 'hsn',
  });
  for (const w of hsn.warnings.toArray()) {
    for (const id of w.document_ids ?? []) {
      warnings.add(w.code, w.message, id);
    }
    if (!w.document_ids?.length) {
      warnings.add(w.code, w.message);
    }
  }
  sections.push(hsn.section);

  const issuedBySeries = new Map<string, { from: string; to: string; count: number }>();
  for (const doc of dataset.sales.filter((d) => !d.isCreditNote)) {
    const series = doc.documentSeries;
    const num = doc.documentNumber ?? '';
    const entry = issuedBySeries.get(series) ?? {
      from: num,
      to: num,
      count: 0,
    };
    entry.count += 1;
    if (num && num < entry.from) entry.from = num;
    if (num && num > entry.to) entry.to = num;
    issuedBySeries.set(series, entry);
  }
  const docRows = [...issuedBySeries.entries()].map(([series, stats]) => {
    const cancelled =
      dataset.cancelledBySeries.find((c) => c.documentSeries === series)
        ?.count ?? 0;
    return {
      series,
      from_no: stats.from,
      to_no: stats.to,
      issued: stats.count,
      cancelled,
    };
  });
  sections.push({
    key: 'doc_issue',
    title: 'Document Summary',
    rows: docRows,
  });

  return {
    meta: {
      period: '',
      from: '',
      to: '',
      business_id: dataset.business.id,
      generated_at: new Date().toISOString(),
      flags: {},
    },
    sections,
    totals: {
      b2b_count: String(buckets.b2b.length),
      b2cl_count: String(buckets.b2cl.length),
      b2cs_count: String(buckets.b2cs.length),
    },
    warnings: warnings.toArray(),
  };
}
