import {
  addPaise,
  formatPaise,
  negatePaise,
  parseMoneyToPaise,
} from '../core/gst-money';
import { lineTaxablePaise } from '../core/line-taxable';
import type { GstDataset, GstSalesDocumentModel } from '../core/models';
import { mapUnitToUqc } from '../core/uqc-mapper';
import type { GstReportSection } from '../gst-reports.types';
import { WarningCollector } from '../core/warning-collector';
import { isValid as isValidGstin } from '../../../shared/utils/gstin-validator';

type HsnKey = string;

function lineSignMultiplier(doc: GstSalesDocumentModel): bigint {
  return doc.isCreditNote ? BigInt(-1) : BigInt(1);
}

export type HsnSummaryOptions = {
  itemType: 'product' | 'service';
  codeField: 'hsn' | 'sac';
};

export function buildHsnSummary(
  dataset: GstDataset,
  options: HsnSummaryOptions,
): { section: GstReportSection; warnings: WarningCollector } {
  const warnings = new WarningCollector();
  const groups = new Map<
    HsnKey,
    {
      code: string;
      description: string;
      uqc: string;
      taxRate: string;
      quantityPaise: bigint;
      totalPaise: bigint;
      taxablePaise: bigint;
      igstPaise: bigint;
      cgstPaise: bigint;
      sgstPaise: bigint;
      cessPaise: bigint;
    }
  >();

  for (const doc of dataset.sales) {
    if (!doc.partyStateCode) {
      warnings.add(
        'MISSING_PARTY_STATE',
        'Party state / place of supply missing; assumed intra-state.',
        doc.id,
      );
    }
    if (doc.party.gstin && !isValidGstin(doc.party.gstin)) {
      warnings.add('INVALID_PARTY_GSTIN', 'Invalid party GSTIN format.', doc.id);
    }

    const sign = lineSignMultiplier(doc);

    for (const line of doc.lines) {
      if (line.item.itemType !== options.itemType) continue;

      const rawCode = line.item.hsnCode?.trim() || '';
      const code = rawCode.length > 0 ? rawCode : 'NA';
      if (code === 'NA') {
        warnings.add(
          'MISSING_HSN_SAC',
          `Missing ${options.codeField.toUpperCase()} on line item.`,
          doc.id,
        );
      }

      const uqc = mapUnitToUqc(line.unit);
      const taxRate = line.taxRate;
      const key = `${code}|${uqc}|${taxRate}`;
      const existing = groups.get(key) ?? {
        code,
        description: line.item.name,
        uqc,
        taxRate,
        quantityPaise: BigInt(0),
        totalPaise: BigInt(0),
        taxablePaise: BigInt(0),
        igstPaise: BigInt(0),
        cgstPaise: BigInt(0),
        sgstPaise: BigInt(0),
        cessPaise: BigInt(0),
      };

      const qty = parseMoneyToPaise(line.quantity) * sign;
      existing.quantityPaise += qty;
      existing.totalPaise += parseMoneyToPaise(line.lineTotal) * sign;
      existing.taxablePaise += lineTaxablePaise(line) * sign;
      existing.igstPaise += parseMoneyToPaise(line.igstAmount) * sign;
      existing.cgstPaise += parseMoneyToPaise(line.cgstAmount) * sign;
      existing.sgstPaise += parseMoneyToPaise(line.sgstAmount) * sign;
      existing.cessPaise += parseMoneyToPaise(line.cessAmount) * sign;

      groups.set(key, existing);
    }
  }

  const rows = [...groups.values()]
    .sort((a, b) => (a.code > b.code ? 1 : -1))
    .map((g) => ({
      [options.codeField]: g.code,
      description: g.description,
      uqc: g.uqc,
      tax_rate: g.taxRate,
      quantity: formatPaise(g.quantityPaise),
      total_value: formatPaise(g.totalPaise),
      taxable_value: formatPaise(g.taxablePaise),
      igst: formatPaise(g.igstPaise),
      cgst: formatPaise(g.cgstPaise),
      sgst: formatPaise(g.sgstPaise),
      cess: formatPaise(g.cessPaise),
    }));

  const totals = rows.reduce(
    (acc, row) => ({
      taxable_value: formatPaise(
        addPaise(
          parseMoneyToPaise(acc.taxable_value),
          parseMoneyToPaise(row.taxable_value as string),
        ),
      ),
      total_value: formatPaise(
        addPaise(
          parseMoneyToPaise(acc.total_value),
          parseMoneyToPaise(row.total_value as string),
        ),
      ),
      igst: formatPaise(
        addPaise(
          parseMoneyToPaise(acc.igst),
          parseMoneyToPaise(row.igst as string),
        ),
      ),
      cgst: formatPaise(
        addPaise(
          parseMoneyToPaise(acc.cgst),
          parseMoneyToPaise(row.cgst as string),
        ),
      ),
      sgst: formatPaise(
        addPaise(
          parseMoneyToPaise(acc.sgst),
          parseMoneyToPaise(row.sgst as string),
        ),
      ),
    }),
    {
      taxable_value: '0.00',
      total_value: '0.00',
      igst: '0.00',
      cgst: '0.00',
      sgst: '0.00',
    },
  );

  return {
    section: {
      key: options.itemType === 'product' ? 'hsn_summary' : 'sac_summary',
      title:
        options.itemType === 'product'
          ? 'Sale Summary By HSN'
          : 'SAC Report',
      rows,
      totals,
    },
    warnings,
  };
}
