/** Shared inventory module utilities. */

export function normalizeMoney(value: string | number | undefined): string {
  if (value === undefined || value === '') {
    return '0';
  }
  return String(value).trim();
}

export function parseMoney(value: string | number | undefined): number {
  return Number(normalizeMoney(value));
}

/** Weighted moving average when stock is added; unchanged on stock-out. */
export function calculateMovingAverageCost(
  currentQuantity: string | number,
  currentAverageCost: string | number,
  quantityDelta: string | number,
  costPerUnit: string | number | null | undefined,
): string {
  const oldQty = parseMoney(currentQuantity);
  const oldAvg = parseMoney(currentAverageCost);
  const delta = parseMoney(quantityDelta);
  const newQty = oldQty + delta;

  if (newQty <= 0) {
    return '0';
  }

  if (delta <= 0 || costPerUnit === null || costPerUnit === undefined) {
    return normalizeMoney(oldAvg);
  }

  const cost = parseMoney(costPerUnit);
  const totalValue = oldQty * oldAvg + delta * cost;
  return (totalValue / newQty).toFixed(4);
}

export function formatConversionLabel(
  baseFullName: string,
  secondaryFullName: string,
  factor: number,
): string {
  const factorLabel =
    factor === Math.round(factor) ? String(Math.round(factor)) : String(factor);
  return `1 ${baseFullName} = ${factorLabel} ${secondaryFullName}`;
}
