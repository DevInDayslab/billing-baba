import 'package:billing_baba/features/inventory/utils/gst_tax_rate_catalog.dart';
import 'package:billing_baba/features/inventory/utils/gst_tax_slabs.dart';

/// Maps item GST labels used in forms to API numeric rates.
abstract final class ItemTaxRate {
  static List<String> get options =>
      GstTaxRateCatalog.allOptions().map((option) => option.value).toList();

  static double? parsePercent(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty || trimmed == 'None') return null;
    if (trimmed == 'Exempt') return 0;
    final slab = GstTaxSlabs.definitionForItemLabel(trimmed);
    if (slab != null) return slab.percent;
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(trimmed);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  static String labelForPercent(double? percent) {
    if (percent == null) return 'None';
    if (percent < 0) return 'None';
    final slab = GstTaxSlabs.definitionForPercent(percent);
    if (slab != null) return slab.itemFormLabel;
    return GstTaxSlabs.itemFormLabelForPercent(percent);
  }

  static String? toApiValue(String label) {
    final percent = parsePercent(label);
    if (percent == null) return null;
    return percent.toStringAsFixed(4);
  }

  static double invoiceLinePercent(double? percent) => percent ?? 0;
}
