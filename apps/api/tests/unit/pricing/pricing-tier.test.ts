import { describe, expect, test } from 'bun:test';
import {
  normalizePricingTier,
  pricingTierLabel,
  resolvePartyPricingTier,
  resolveTierPrice,
} from '../../../src/shared/pricing/pricing-tier';

describe('pricing-tier', () => {
  test('normalizes human-readable tier labels', () => {
    expect(normalizePricingTier('retail')).toBe('tier_1');
    expect(normalizePricingTier('wholesale')).toBe('tier_2');
    expect(normalizePricingTier('dealer')).toBe('tier_3');
    expect(normalizePricingTier('distributor')).toBe('tier_4');
  });

  test('prefers default_price_tier over pricing_tier for parties', () => {
    expect(
      resolvePartyPricingTier({
        pricing_tier: 'tier_1',
        default_price_tier: 'wholesale',
      }),
    ).toBe('tier_2');
  });

  test('maps tier keys to labels', () => {
    expect(pricingTierLabel('tier_4')).toBe('distributor');
  });

  test('falls back to sale price when tier price is missing', () => {
    expect(
      resolveTierPrice(
        '100',
        [{ pricing_tier: 'tier_2', price: '90' }],
        'tier_3',
      ),
    ).toBe('100');
  });

  test('uses tier price when available', () => {
    expect(
      resolveTierPrice(
        '100',
        [{ pricing_tier: 'tier_2', price: '90' }],
        'tier_2',
      ),
    ).toBe('90');
  });
});
