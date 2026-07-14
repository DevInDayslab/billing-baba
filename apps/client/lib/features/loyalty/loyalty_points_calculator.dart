/// Client-side loyalty earn math — mirrors `apps/api/src/modules/loyalty/loyalty.utils.ts`.
abstract final class LoyaltyPointsCalculator {
  static const double defaultRupeesPerPoint = 100;

  static int earnedForSpend(
    double spendAmount, {
    double rupeesPerPoint = defaultRupeesPerPoint,
  }) {
    if (spendAmount <= 0 || rupeesPerPoint <= 0) return 0;
    return (spendAmount / rupeesPerPoint).floor();
  }
}
