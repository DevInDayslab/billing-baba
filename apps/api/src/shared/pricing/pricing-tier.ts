/** Canonical API/storage tier keys. */
export const PRICING_TIER_VALUES = [
  'tier_1',
  'tier_2',
  'tier_3',
  'tier_4',
] as const;

export type PricingTier = (typeof PRICING_TIER_VALUES)[number];

/** Human-readable tier labels used by clients. */
export const PRICING_TIER_LABELS = [
  'retail',
  'wholesale',
  'dealer',
  'distributor',
] as const;

export type PricingTierLabel = (typeof PRICING_TIER_LABELS)[number];

export const PRICING_TIER_INPUT_VALUES = [
  ...PRICING_TIER_VALUES,
  ...PRICING_TIER_LABELS,
] as const;

const TIER_TO_LABEL: Record<PricingTier, PricingTierLabel> = {
  tier_1: 'retail',
  tier_2: 'wholesale',
  tier_3: 'dealer',
  tier_4: 'distributor',
};

const LABEL_TO_TIER: Record<PricingTierLabel, PricingTier> = {
  retail: 'tier_1',
  wholesale: 'tier_2',
  dealer: 'tier_3',
  distributor: 'tier_4',
};

export function isPricingTier(value: string): value is PricingTier {
  return (PRICING_TIER_VALUES as readonly string[]).includes(value);
}

export function pricingTierLabel(tier: PricingTier): PricingTierLabel {
  return TIER_TO_LABEL[tier];
}

export function normalizePricingTier(
  value: string | undefined,
  fallback: PricingTier = 'tier_1',
): PricingTier {
  if (!value) return fallback;

  const normalized = value.trim().toLowerCase();
  if (isPricingTier(normalized)) {
    return normalized;
  }

  if ((PRICING_TIER_LABELS as readonly string[]).includes(normalized)) {
    return LABEL_TO_TIER[normalized as PricingTierLabel];
  }

  return fallback;
}

export function resolvePartyPricingTier(input: {
  pricing_tier?: string;
  default_price_tier?: string;
}): PricingTier | undefined {
  const raw = input.default_price_tier ?? input.pricing_tier;
  if (raw === undefined) return undefined;
  return normalizePricingTier(raw);
}

export type TierPriceLike = {
  pricing_tier: PricingTier;
  price: string;
};

/**
 * Resolves a unit price for a party tier, falling back to the item sale price.
 */
export function resolveTierPrice(
  salePrice: string,
  tierPrices: readonly TierPriceLike[],
  partyTier: PricingTier | null | undefined,
): string {
  if (!partyTier) return salePrice;

  const match = tierPrices.find((tier) => tier.pricing_tier === partyTier);
  if (!match) return salePrice;

  const price = match.price;
  if (!price || Number(price) <= 0) return salePrice;
  return price;
}
