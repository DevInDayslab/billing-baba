/// Maps item GST labels used in forms to API numeric rates.
abstract final class ItemTaxRate {
  static const options = [
    'None',
    'GST @ 0%',
    'GST @ 5%',
    'GST @ 12%',
    'GST @ 18%',
    'GST @ 28%',
  ];

  static double? parsePercent(String label) {
    if (label.trim().isEmpty || label == 'None') return null;
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(label);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  static String labelForPercent(double? percent) {
    if (percent == null || percent <= 0) return 'None';
    for (final option in options) {
      if (parsePercent(option) == percent) return option;
    }
    if (percent == percent.roundToDouble()) {
      return 'GST @ ${percent.toInt()}%';
    }
    return 'GST @ $percent%';
  }

  static String? toApiValue(String label) {
    final percent = parsePercent(label);
    if (percent == null) return null;
    return percent.toStringAsFixed(4);
  }

  static double invoiceLinePercent(double? percent) => percent ?? 0;
}
