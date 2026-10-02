import 'package:billing_baba/features/inventory/utils/gst_tax_slabs.dart';
import 'package:flutter/material.dart';

/// Display metadata for standard item GST slabs (Add Item, etc.).
class GstTaxRateOption {
  const GstTaxRateOption({
    required this.value,
    required this.title,
    this.percent,
    this.badgeBackground,
    this.badgeForeground,
  });

  /// Canonical form value — matches [ItemTaxRate.options].
  final String value;
  final String title;

  /// `null` for the "None" option (no badge).
  final double? percent;
  final Color? badgeBackground;
  final Color? badgeForeground;

  String badgeLabel() {
    if (percent == null) return '';
    final slab = GstTaxSlabs.definitionForPercent(percent!);
    if (slab != null) return slab.badgeText();
    if (percent == percent!.roundToDouble()) {
      return percent!.toInt().toString();
    }
    return percent!.toString();
  }

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (title.toLowerCase().contains(q)) return true;
    if (value.toLowerCase().contains(q)) return true;
    if (percent != null) {
      final p = percent!.toString();
      if (p.contains(q) || p.replaceAll('.0', '').contains(q)) return true;
      if (percent == percent!.roundToDouble() &&
          '${percent!.toInt()}'.contains(q)) {
        return true;
      }
    }
    if (q == 'nil' || q == 'exempt') return percent == 0;
    return false;
  }
}

abstract final class GstTaxRateCatalog {
  static const none = GstTaxRateOption(
    value: 'None',
    title: 'None',
  );

  static List<GstTaxRateOption> get standardSlabs =>
      GstTaxSlabs.definitions()
          .map(
            (slab) => GstTaxRateOption(
              value: slab.itemFormLabel,
              title: slab.itemFormLabel,
              percent: slab.percent,
              badgeBackground: slab.badgeBackground,
              badgeForeground: slab.badgeForeground,
            ),
          )
          .toList();

  static List<GstTaxRateOption> allOptions() => [none, ...standardSlabs];

  static GstTaxRateOption? findByValue(String value) {
    for (final option in allOptions()) {
      if (option.value == value) return option;
    }
    return null;
  }
}
