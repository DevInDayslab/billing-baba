/// Frontend price tier definitions for tier-based pricing (dummy/local data).
abstract final class PriceTier {
  static const retail = 'retail';
  static const wholesale = 'wholesale';
  static const dealer = 'dealer';
  static const distributor = 'distributor';

  static const String defaultTier = retail;

  static const List<String> all = [retail, wholesale, dealer, distributor];

  static const Map<String, String> labels = {
    retail: 'Retail',
    wholesale: 'Wholesale',
    dealer: 'Dealer',
    distributor: 'Distributor',
  };

  static const dropdownOptions = [
    'Retail',
    'Wholesale',
    'Dealer',
    'Distributor',
  ];

  static String labelFor(
    String tierKey, {
    Map<String, String>? apiTierLabels,
  }) {
    final apiLabel = _apiLabelForTierKey(tierKey, apiTierLabels);
    if (apiLabel != null) return apiLabel;
    return labels[tierKey] ?? labels[retail]!;
  }

  static String? _apiLabelForTierKey(
    String tierKey,
    Map<String, String>? apiTierLabels,
  ) {
    if (apiTierLabels == null || apiTierLabels.isEmpty) return null;
    final apiTier = toApiTier(tierKey);
    return apiTierLabels[apiTier];
  }

  static List<String> dropdownOptionsFor({
    Map<String, String>? apiTierLabels,
  }) =>
      all.map((tier) => labelFor(tier, apiTierLabels: apiTierLabels)).toList();

  static String keyFromLabel(
    String label, {
    Map<String, String>? apiTierLabels,
  }) {
    if (apiTierLabels != null) {
      for (final entry in apiTierLabels.entries) {
        if (entry.value == label) {
          return fromApiTier(entry.key);
        }
      }
    }
    for (final entry in labels.entries) {
      if (entry.value == label) return entry.key;
    }
    return retail;
  }

  /// Maps legacy API tier keys to frontend tier keys.
  static String fromApiTier(String? apiTier) => switch (apiTier) {
    'tier_2' => wholesale,
    'tier_3' => dealer,
    'tier_4' => distributor,
    _ => retail,
  };

  /// Accepts API tier keys (`tier_1`) or labels (`wholesale`).
  static String normalizeTierKey(String? value) {
    if (value == null || value.isEmpty) return retail;
    final normalized = value.trim().toLowerCase();
    if (all.contains(normalized)) return normalized;
    return fromApiTier(normalized);
  }

  static Map<String, double> mapFromApiTierPrices(
    Iterable<({String pricingTier, double price})> tiers,
  ) {
    final map = <String, double>{};
    for (final tier in tiers) {
      if (tier.price <= 0) continue;
      map[fromApiTier(tier.pricingTier)] = tier.price;
    }
    return map;
  }

  static Map<String, double> mergeTierPriceMaps(
    Map<String, double> apiTiers,
    Map<String, double> localTiers,
  ) => {...apiTiers, ...localTiers};

  /// Maps frontend tier keys to legacy API tier keys for request payloads.
  static String toApiTier(String tierKey) => switch (tierKey) {
    wholesale => 'tier_2',
    dealer => 'tier_3',
    distributor => 'tier_4',
    _ => 'tier_1',
  };

  static List<String> availableTiersExcept(Set<String> used) =>
      all.where((tier) => !used.contains(tier)).toList();
}

/// Resolves the unit price for a party tier, falling back to the sale price.
double resolveTierPrice({
  required double salePrice,
  required Map<String, double> tierPrices,
  String? partyTier,
}) {
  if (partyTier != null && partyTier.isNotEmpty) {
    final tierPrice = tierPrices[partyTier];
    if (tierPrice != null && tierPrice > 0) return tierPrice;
  }
  return salePrice;
}
