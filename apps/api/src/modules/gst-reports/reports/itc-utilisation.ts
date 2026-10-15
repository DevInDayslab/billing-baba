import { addPaise, formatPaise, subtractPaise } from '../core/gst-money';

export type TaxPools = {
  igst: bigint;
  cgst: bigint;
  sgst: bigint;
};

export type ItcUtilisationResult = {
  itc_used: TaxPools;
  net_payable: TaxPools;
  carry_forward: TaxPools;
};

/** Standard GST credit utilisation order (simplified). */
export function utiliseItc(
  outputTax: TaxPools,
  itcAvailable: TaxPools,
): ItcUtilisationResult {
  let remIgst = itcAvailable.igst;
  let remCgst = itcAvailable.cgst;
  let remSgst = itcAvailable.sgst;

  const used: TaxPools = { igst: BigInt(0), cgst: BigInt(0), sgst: BigInt(0) };

  // IGST liability: IGST ITC, then CGST, then SGST
  let igstPay = outputTax.igst;
  const igstFromIgst = min(remIgst, igstPay);
  remIgst -= igstFromIgst;
  igstPay -= igstFromIgst;
  used.igst += igstFromIgst;

  const igstFromCgst = min(remCgst, igstPay);
  remCgst -= igstFromCgst;
  igstPay -= igstFromCgst;
  used.cgst += igstFromCgst;

  const igstFromSgst = min(remSgst, igstPay);
  remSgst -= igstFromSgst;
  igstPay -= igstFromSgst;
  used.sgst += igstFromSgst;

  // CGST liability
  let cgstPay = outputTax.cgst;
  const cgstFromCgst = min(remCgst, cgstPay);
  remCgst -= cgstFromCgst;
  cgstPay -= cgstFromCgst;
  used.cgst += cgstFromCgst;

  const cgstFromIgst = min(remIgst, cgstPay);
  remIgst -= cgstFromIgst;
  cgstPay -= cgstFromIgst;
  used.igst += cgstFromIgst;

  // SGST liability
  let sgstPay = outputTax.sgst;
  const sgstFromSgst = min(remSgst, sgstPay);
  remSgst -= sgstFromSgst;
  sgstPay -= sgstFromSgst;
  used.sgst += sgstFromSgst;

  const sgstFromIgst = min(remIgst, sgstPay);
  remIgst -= sgstFromIgst;
  sgstPay -= sgstFromIgst;
  used.igst += sgstFromIgst;

  const netPayable: TaxPools = {
    igst: igstPay,
    cgst: cgstPay,
    sgst: sgstPay,
  };

  return {
    itc_used: used,
    net_payable: netPayable,
    carry_forward: { igst: remIgst, cgst: remCgst, sgst: remSgst },
  };
}

function min(a: bigint, b: bigint): bigint {
  return a < b ? a : b;
}

export function formatTaxPools(pools: TaxPools): Record<string, string> {
  return {
    igst: formatPaise(pools.igst),
    cgst: formatPaise(pools.cgst),
    sgst: formatPaise(pools.sgst),
  };
}

export function sumTaxPools(a: TaxPools, b: TaxPools): TaxPools {
  return {
    igst: addPaise(a.igst, b.igst),
    cgst: addPaise(a.cgst, b.cgst),
    sgst: addPaise(a.sgst, b.sgst),
  };
}

export function subtractTaxPools(a: TaxPools, b: TaxPools): TaxPools {
  return {
    igst: subtractPaise(a.igst, b.igst),
    cgst: subtractPaise(a.cgst, b.cgst),
    sgst: subtractPaise(a.sgst, b.sgst),
  };
}
