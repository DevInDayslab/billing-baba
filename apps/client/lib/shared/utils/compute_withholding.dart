/// Round withholding tax to nearest whole rupee (matches API computeTds/Tcs).
String computeWithholdingTax(String baseAmount, String ratePercent) {
  final base = double.tryParse(baseAmount) ?? 0;
  final rate = double.tryParse(ratePercent) ?? 0;
  if (base == 0 || rate == 0) return '0.00';
  final tax = base * rate / 100;
  final rounded = tax.roundToDouble();
  return rounded.toStringAsFixed(2);
}
