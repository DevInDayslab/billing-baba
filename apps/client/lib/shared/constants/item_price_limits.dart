/// Upper bound for item MRP / sale / wholesale / purchase amounts (Indian UI: 99,99,99,999).
abstract final class ItemPriceLimits {
  static const int maxWholeRupees = 999999999;

  /// Includes up to four decimal places (paise).
  static const double maxAmount = maxWholeRupees + 0.9999;

  static const String maxAmountIndianLabel = '99,99,99,999';

  static double clamp(double value) {
    if (value <= 0) return 0;
    if (value > maxAmount) return maxWholeRupees.toDouble();
    return value;
  }
}
