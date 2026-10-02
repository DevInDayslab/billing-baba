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
    if (q == 'nil') return percent == 0;
    if (q == 'exempt') return title == 'Exempt' || percent == 0;
    return false;
  }
}

abstract final class GstTaxRateCatalog {
  static const none = GstTaxRateOption(
    value: 'None',
    title: 'None',
  );

  static const exempt = GstTaxRateOption(
    value: 'Exempt',
    title: 'Exempt',
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

  /// GST-only slabs not shown as IGST/GST pairs (e.g. 1.5%).
  static List<GstTaxRateOption> get gstOnlySlabs {
    const gstOnlyPercents = <double>[1.5];
    return gstOnlyPercents
        .map((percent) {
          final slab = GstTaxSlabs.definitionForPercent(percent);
          if (slab == null) return null;
          return GstTaxRateOption(
            value: slab.itemFormLabel,
            title: slab.itemFormLabel,
            percent: slab.percent,
            badgeBackground: slab.badgeBackground,
            badgeForeground: slab.badgeForeground,
          );
        })
        .whereType<GstTaxRateOption>()
        .toList();
  }

  static String _igstLabel(double percent) {
    if (GstTaxSlabs.samePercent(percent, 0)) return 'IGST @ 0%';
    if (percent == percent.roundToDouble()) {
      return 'IGST @ ${percent.toInt()}%';
    }
    return 'IGST @ $percent%';
  }

  static String _gstLabel(double percent) {
    if (percent == percent.roundToDouble()) {
      return 'GST @ ${percent.toInt()}%';
    }
    return 'GST @ $percent%';
  }

  static List<GstTaxRateOption> allOptions() {
    const pairedPercents = <double>[0, 0.25, 3, 5, 12, 18, 28, 40];
    final options = <GstTaxRateOption>[none];
    for (final percent in pairedPercents) {
      final slab = GstTaxSlabs.definitionForPercent(percent);
      if (slab == null) continue;
      options.add(
        GstTaxRateOption(
          value: _igstLabel(percent),
          title: _igstLabel(percent),
          percent: percent,
          badgeBackground: slab.badgeBackground,
          badgeForeground: slab.badgeForeground,
        ),
      );
      final gstLabel = percent == 0
          ? GstTaxSlabs.itemFormLabelForPercent(0)
          : _gstLabel(percent);
      options.add(
        GstTaxRateOption(
          value: gstLabel,
          title: gstLabel,
          percent: percent,
          badgeBackground: slab.badgeBackground,
          badgeForeground: slab.badgeForeground,
        ),
      );
      if (GstTaxSlabs.samePercent(percent, 0.25)) {
        options.addAll(gstOnlySlabs);
      }
    }
    options.add(exempt);
    return options;
  }

  static GstTaxRateOption? findByValue(String value) {
    for (final option in allOptions()) {
      if (option.value == value) return option;
    }
    return null;
  }
}
