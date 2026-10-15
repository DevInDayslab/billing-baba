import { addPaise, formatPaise, parseMoneyToPaise } from '../core/gst-money';
import { isNilOrExemptDocument } from '../core/invoice-classifier';
import { lineTaxablePaise } from '../core/line-taxable';
import { resolvePlaceOfSupplyState } from '../core/place-of-supply';
import type { GstDataset } from '../core/models';
import type { GstReportEnvelope } from '../gst-reports.types';
import { WarningCollector } from '../core/warning-collector';
import { isValid as isValidGstin } from '../../../shared/utils/gstin-validator';
import {
  formatTaxPools,
  utiliseItc,
  type TaxPools,
} from './itc-utilisation';

export type Gstr3bOptions = { nonTaxAsExempt: boolean };

function accumulateSalesTax(
  dataset: GstDataset,
  options: Gstr3bOptions,
): {
  taxable: TaxPools & { taxableValue: bigint };
  zeroRated: bigint;
  nilExempt: bigint;
  nonGst: bigint;
} {
  let taxableValue = BigInt(0);
  const tax: TaxPools = { igst: BigInt(0), cgst: BigInt(0), sgst: BigInt(0) };
  let zeroRated = BigInt(0);
  let nilExempt = BigInt(0);
  let nonGst = BigInt(0);

  for (const doc of dataset.sales) {
    const sign = doc.isCreditNote ? BigInt(-1) : BigInt(1);
    for (const line of doc.lines) {
      const taxableLine = lineTaxablePaise(line) * sign;
      const igst = parseMoneyToPaise(line.igstAmount) * sign;
      const cgst = parseMoneyToPaise(line.cgstAmount) * sign;
      const sgst = parseMoneyToPaise(line.sgstAmount) * sign;

      const zeroTax =
        line.taxType === 'none' ||
        (igst === BigInt(0) && cgst === BigInt(0) && sgst === BigInt(0));

      if (isNilOrExemptDocument(doc) || zeroTax) {
        if (options.nonTaxAsExempt) nilExempt += taxableLine;
        else nonGst += taxableLine;
        continue;
      }

      taxableValue += taxableLine;
      tax.igst += igst;
      tax.cgst += cgst;
      tax.sgst += sgst;
    }
  }

  return { taxable: { ...tax, taxableValue }, zeroRated, nilExempt, nonGst };
}

function accumulatePurchaseItc(
  dataset: GstDataset,
  warnings: WarningCollector,
): TaxPools {
  const itc: TaxPools = { igst: BigInt(0), cgst: BigInt(0), sgst: BigInt(0) };
  for (const doc of dataset.purchases) {
    const sign = doc.isDebitNote ? BigInt(-1) : BigInt(1);
    const supplierGstin = doc.party.gstin;
    const eligible =
      supplierGstin && isValidGstin(supplierGstin) ? true : false;
    if (!eligible) {
      warnings.add(
        'ITC_INELIGIBLE_SUPPLIER',
        'Purchase from unregistered/invalid GSTIN supplier — ITC not claimed.',
        doc.id,
      );
      continue;
    }
    for (const line of doc.lines) {
      itc.igst += parseMoneyToPaise(line.igstAmount) * sign;
      itc.cgst += parseMoneyToPaise(line.cgstAmount) * sign;
      itc.sgst += parseMoneyToPaise(line.sgstAmount) * sign;
    }
  }
  return itc;
}

export function buildGstr3bReport(
  dataset: GstDataset,
  options: Gstr3bOptions,
): GstReportEnvelope {
  const warnings = new WarningCollector();
  const outward = accumulateSalesTax(dataset, options);
  const itcAvailable = accumulatePurchaseItc(dataset, warnings);
  const outputTax: TaxPools = {
    igst: outward.taxable.igst,
    cgst: outward.taxable.cgst,
    sgst: outward.taxable.sgst,
  };
  const utilisation = utiliseItc(outputTax, itcAvailable);

  const b2csUnreg = new Map<string, bigint>();
  for (const doc of dataset.sales.filter((d) => !d.isCreditNote)) {
    const pos = resolvePlaceOfSupplyState(
      dataset.business,
      doc.partyStateCode,
    );
    const taxable = doc.lines.reduce(
      (s, l) => addPaise(s, lineTaxablePaise(l)),
      BigInt(0),
    );
    b2csUnreg.set(pos, (b2csUnreg.get(pos) ?? BigInt(0)) + taxable);
  }

  const sections = [
    {
      key: 'table_3_1',
      title: '3.1 Outward supplies',
      rows: [
        {
          nature: 'Taxable outward supplies',
          taxable_value: formatPaise(outward.taxable.taxableValue),
          ...formatTaxPools({
            igst: outward.taxable.igst,
            cgst: outward.taxable.cgst,
            sgst: outward.taxable.sgst,
          }),
          cess: '0.00',
        },
        {
          nature: 'Zero rated',
          taxable_value: formatPaise(outward.zeroRated),
          igst: '0.00',
          cgst: '0.00',
          sgst: '0.00',
          cess: '0.00',
        },
        {
          nature: options.nonTaxAsExempt
            ? 'Nil / exempted'
            : 'Nil rated / exempt',
          taxable_value: formatPaise(outward.nilExempt),
          igst: '0.00',
          cgst: '0.00',
          sgst: '0.00',
          cess: '0.00',
        },
        {
          nature: 'Non-GST',
          taxable_value: formatPaise(outward.nonGst),
          igst: '0.00',
          cgst: '0.00',
          sgst: '0.00',
          cess: '0.00',
        },
      ],
    },
    {
      key: 'table_3_2',
      title: '3.2 Inter-state supplies to unregistered',
      rows: [...b2csUnreg.entries()].map(([pos, value]) => ({
        place_of_supply: pos,
        taxable_value: formatPaise(value),
      })),
    },
    {
      key: 'table_4',
      title: '4 ITC',
      rows: [
        {
          description: 'Eligible ITC',
          ...formatTaxPools(itcAvailable),
        },
        {
          description: 'ITC utilised',
          ...formatTaxPools(utilisation.itc_used),
        },
      ],
    },
    {
      key: 'table_6_1',
      title: '6.1 Tax payable',
      rows: [
        {
          description: 'Net tax payable',
          ...formatTaxPools(utilisation.net_payable),
        },
        {
          description: 'ITC carry forward',
          ...formatTaxPools(utilisation.carry_forward),
        },
      ],
    },
  ];

  return {
    meta: {
      period: '',
      from: '',
      to: '',
      business_id: dataset.business.id,
      generated_at: new Date().toISOString(),
      flags: { non_tax_as_exempt: options.nonTaxAsExempt },
    },
    sections,
    totals: {
      output_igst: formatPaise(outputTax.igst),
      net_igst: formatPaise(utilisation.net_payable.igst),
    },
    warnings: warnings.toArray(),
  };
}
