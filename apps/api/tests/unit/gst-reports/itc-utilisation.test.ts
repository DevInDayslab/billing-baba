import { describe, expect, test } from 'bun:test';
import { utiliseItc } from '../../../src/modules/gst-reports/reports/itc-utilisation';

describe('itc-utilisation', () => {
  test('uses IGST ITC against IGST liability first', () => {
    const result = utiliseItc(
      { igst: BigInt(1000), cgst: BigInt(0), sgst: BigInt(0) },
      { igst: BigInt(400), cgst: BigInt(0), sgst: BigInt(0) },
    );
    expect(result.net_payable.igst).toBe(BigInt(600));
    expect(result.itc_used.igst).toBe(BigInt(400));
    expect(result.carry_forward.igst).toBe(BigInt(0));
  });
});
