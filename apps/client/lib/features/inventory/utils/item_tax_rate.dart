import 'package:billing_baba/features/inventory/utils/gst_tax_slabs.dart';

/// Maps item GST labels used in forms to API numeric rates.
abstract final class ItemTaxRate {
  static List<String> get options => [
    'None',
    ...GstTaxSlabs.definitions().map((s) => s.itemFormLabel),
  ];

  static double? parsePercent(String label) {
    if (label.trim().isEmpty || label == 'None') return null;
    final slab = GstTaxSlabs.definitionForItemLabel(label);
    if (slab != null) return slab.percent;
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(label);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  static String labelForPercent(double? percent) {
    if (percent == null) return 'None';
    if (percent < 0) return 'None';
    final slab = GstTaxSlabs.definitionForPercent(percent);
    if (slab != null) return slab.itemFormLabel;
    if (GstTaxSlabs.samePercent(percent, 28)) return 'GST @ 28%';
    return GstTaxSlabs.itemFormLabelForPercent(percent);
  }

  static String? toApiValue(String label) {
    final percent = parsePercent(label);
    if (percent == null) return null;
    return percent.toStringAsFixed(4);
  }

  static double invoiceLinePercent(double? percent) => percent ?? 0;
}
