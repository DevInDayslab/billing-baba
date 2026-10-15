import type { GstBusinessContext } from './models';

export function resolvePlaceOfSupplyState(
  business: GstBusinessContext,
  partyStateCode: string | null,
): string {
  const code = partyStateCode?.trim();
  if (code && code.length > 0) {
    return code.padStart(2, '0').slice(-2);
  }
  return business.stateCode.padStart(2, '0').slice(-2);
}

export function isInterStateSupply(
  business: GstBusinessContext,
  partyStateCode: string | null,
  hasIgst: boolean,
): boolean {
  if (hasIgst) return true;
  const pos = resolvePlaceOfSupplyState(business, partyStateCode);
  const businessState = business.stateCode.padStart(2, '0').slice(-2);
  return pos !== businessState;
}
