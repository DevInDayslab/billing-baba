import { formatPaise, parseMoneyToPaise } from '../core/gst-money';
import { lineTaxablePaise } from '../core/line-taxable';
import type { GstDataset } from '../core/models';
import type { GstReportEnvelope } from '../gst-reports.types';
import { WarningCollector } from '../core/warning-collector';
import { isValid as isValidGstin } from '../../../shared/utils/gstin-validator';
import { addPaise } from '../core/gst-money';
import { mapUnitToUqc } from '../core/uqc-mapper';

export function buildGstr2Report(dataset: GstDataset): GstReportEnvelope {
  const warnings = new WarningCollector();

  const b2b = dataset.purchases.filter(
    (p) => !p.isDebitNote && isValidGstin(p.party.gstin ?? ''),
  );
  const unreg = dataset.purchases.filter(
    (p) => !p.isDebitNote && !isValidGstin(p.party.gstin ?? ''),
  );
  const debitNotes = dataset.purchases.filter((p) => p.isDebitNote);

  const mapDoc = (doc: (typeof dataset.purchases)[0]) => ({
    document_id: doc.id,
    gstin: doc.party.gstin ?? '',
    party_name: doc.party.name ?? '',
    bill_no: doc.documentNumber ?? '',
    bill_date: doc.documentDate.toISOString(),
    value: doc.totalAmount,
    taxable_value: formatPaise(
      doc.lines.reduce(
        (s, l) => addPaise(s, lineTaxablePaise(l)),
        BigInt(0),
      ),
    ),
    original_bill_no: doc.originalDocumentNumber ?? '',
    original_bill_date: doc.originalDocumentDate?.toISOString() ?? '',
  });

  let eligibleIgst = BigInt(0);
  let eligibleCgst = BigInt(0);
  let eligibleSgst = BigInt(0);
  let ineligibleTaxable = BigInt(0);

  for (const doc of dataset.purchases) {
    const sign = doc.isDebitNote ? BigInt(-1) : BigInt(1);
    const eligible = isValidGstin(doc.party.gstin ?? '');
    for (const line of doc.lines) {
      const taxable = lineTaxablePaise(line) * sign;
      if (eligible) {
        eligibleIgst += parseMoneyToPaise(line.igstAmount) * sign;
        eligibleCgst += parseMoneyToPaise(line.cgstAmount) * sign;
        eligibleSgst += parseMoneyToPaise(line.sgstAmount) * sign;
      } else {
        ineligibleTaxable += taxable;
        warnings.add(
          'ITC_INELIGIBLE_SUPPLIER',
          'Purchase not eligible for ITC (supplier GSTIN missing/invalid).',
          doc.id,
        );
      }
    }
  }

  const inwardHsnRows: Record<string, unknown>[] = [];
  for (const doc of dataset.purchases) {
    const sign = doc.isDebitNote ? BigInt(-1) : BigInt(1);
    for (const line of doc.lines) {
      if (line.item.itemType !== 'product') continue;
      inwardHsnRows.push({
        hsn: line.item.hsnCode ?? 'NA',
        uqc: mapUnitToUqc(line.unit),
        tax_rate: line.taxRate,
        taxable_value: formatPaise(lineTaxablePaise(line) * sign),
      });
    }
  }

  return {
    meta: {
      period: '',
      from: '',
      to: '',
      business_id: dataset.business.id,
      generated_at: new Date().toISOString(),
      flags: { discontinued_filing: true },
    },
    sections: [
      {
        key: 'b2b',
        title: 'B2B Purchases',
        rows: b2b.map(mapDoc),
      },
      {
        key: 'b2b_unregistered',
        title: 'B2B Unregistered',
        rows: unreg.map(mapDoc),
      },
      {
        key: 'debit_notes',
        title: 'Debit Notes',
        rows: debitNotes.map(mapDoc),
      },
      {
        key: 'inward_hsn',
        title: 'Inward HSN Summary',
        rows: inwardHsnRows,
      },
      {
        key: 'itc_summary',
        title: 'ITC Summary',
        rows: [
          {
            eligible_igst: formatPaise(eligibleIgst),
            eligible_cgst: formatPaise(eligibleCgst),
            eligible_sgst: formatPaise(eligibleSgst),
            ineligible_taxable: formatPaise(ineligibleTaxable),
          },
        ],
      },
    ],
    totals: {
      purchase_count: String(dataset.purchases.length),
    },
    warnings: warnings.toArray(),
  };
}
