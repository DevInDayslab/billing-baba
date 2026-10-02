import 'package:flutter/material.dart';

/// One GST rate used in item forms, sales lines, and tax math.
class GstSlabDefinition {
  const GstSlabDefinition({
    required this.percent,
    required this.itemFormLabel,
    required this.badgeBackground,
    required this.badgeForeground,
  });

  final double percent;

  /// Canonical Add Item / API label (stored in form state).
  final String itemFormLabel;

  final Color badgeBackground;
  final Color badgeForeground;

  String get saleDropdownLabel {
    if (percent == 0) return '0%';
    if (percent == percent.roundToDouble()) {
      return '${percent.toInt()}%';
    }
    return '$percent%';
  }

  String badgeText() {
    if (percent == percent.roundToDouble()) {
      return percent.toInt().toString();
    }
    return percent.toString();
  }
}

/// Standard Indian GST slabs for Billing Baba.
abstract final class GstTaxSlabs {
  /// Standard item GST slabs (Nil/Exempt, 0.25% … 40%) per product reference.
  static const standardPercents = <double>[
    0,
    0.25,
    1.5,
    3,
    5,
    12,
    18,
    28,
    40,
  ];

  static const _badgeBackgrounds = <Color>[
    Color(0xFFEDE9FE),
    Color(0xFFF3E8FF),
    Color(0xFFE0E7FF),
    Color(0xFFDBEAFE),
    Color(0xFFDCFCE7),
    Color(0xFFD1FAE5),
    Color(0xFFFEF3C7),
    Color(0xFFDBEAFE),
    Color(0xFFFEE2E2),
  ];

  static const _badgeForegrounds = <Color>[
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
    Color(0xFF4F46E5),
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFF1D4ED8),
    Color(0xFFDC2626),
  ];

  static List<GstSlabDefinition> definitions() {
    return List.generate(standardPercents.length, (index) {
      final percent = standardPercents[index];
      return GstSlabDefinition(
        percent: percent,
        itemFormLabel: itemFormLabelForPercent(percent),
        badgeBackground: _badgeBackgrounds[index],
        badgeForeground: _badgeForegrounds[index],
      );
    });
  }

  static String itemFormLabelForPercent(double percent) {
    if (samePercent(percent, 0)) return 'Nil / Exempt (0%)';
    if (percent == percent.roundToDouble()) {
      return 'GST @ ${percent.toInt()}%';
    }
    return 'GST @ $percent%';
  }

  static bool samePercent(double a, double b) => (a - b).abs() < 0.00001;

  static GstSlabDefinition? definitionForPercent(double percent) {
    for (final slab in definitions()) {
      if (samePercent(slab.percent, percent)) return slab;
    }
    return null;
  }

  static GstSlabDefinition? definitionForItemLabel(String label) {
    for (final slab in definitions()) {
      if (slab.itemFormLabel == label) return slab;
    }
    return null;
  }

  /// Sale invoice line dropdown keys (includes NONE for zero tax).
  static List<String> saleDropdownLabels() {
    return ['NONE', ...definitions().map((s) => s.saleDropdownLabel)];
  }

  static Map<String, double> saleDropdownToPercent() {
    final map = <String, double>{'NONE': 0};
    for (final slab in definitions()) {
      map[slab.saleDropdownLabel] = slab.percent;
    }
    // Legacy invoices / items created before 40% slab replaced 28%.
    map['28%'] = 28;
    return map;
  }
}
