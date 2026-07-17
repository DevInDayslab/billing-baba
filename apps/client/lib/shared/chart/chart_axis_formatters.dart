import 'dart:math' as math;

import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:intl/intl.dart';

/// Reusable axis + currency helpers for dashboard trend charts.
abstract final class ChartAxisFormatters {
  static final _tooltipCurrency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _dayMonth = DateFormat('d MMM');
  static final _weekday = DateFormat('EEE');
  static final _month = DateFormat('MMM');

  /// Full currency for tooltips, e.g. `₹10,560`.
  static String formatCurrency(double value) =>
      _tooltipCurrency.format(value);

  /// Compact currency for the Y axis, e.g. `₹10k`.
  static String formatYAxis(double value) {
    if (value == 0) return '₹0';
    final abs = value.abs();
    if (abs >= 10000000) {
      final scaled = value / 10000000;
      return '₹${scaled == scaled.roundToDouble() ? scaled.toInt() : scaled.toStringAsFixed(1)}Cr';
    }
    if (abs >= 100000) {
      final scaled = value / 100000;
      return '₹${scaled == scaled.roundToDouble() ? scaled.toInt() : scaled.toStringAsFixed(1)}L';
    }
    if (abs >= 1000) {
      final scaled = value / 1000;
      return '₹${scaled == scaled.roundToDouble() ? scaled.toInt() : scaled.toStringAsFixed(1)}k';
    }
    return '₹${value.toInt()}';
  }

  /// X-axis label text based on the active dashboard period.
  static String formatXAxis(DateTime date, DashboardPeriod period) {
    return switch (period) {
      DashboardPeriod.today || DashboardPeriod.thisWeek => _weekday.format(date),
      DashboardPeriod.thisYear || DashboardPeriod.allTime => _month.format(date),
      DashboardPeriod.thisMonth ||
      DashboardPeriod.custom =>
        _dayMonth.format(date),
    };
  }

  /// Computes `minY`, `maxY`, and grid `interval` with headroom (~15%).
  /// Targets at most 5 horizontal grid lines.
  static ChartYAxisScale calculateYAxis(Iterable<double> values) {
    if (values.isEmpty) {
      return const ChartYAxisScale(minY: 0, maxY: 10000, interval: 2500);
    }

    final maxValue = values.fold<double>(0, math.max);
    if (maxValue <= 0) {
      return const ChartYAxisScale(minY: 0, maxY: 1000, interval: 250);
    }

    const targetLines = 4;
    final roughInterval = (maxValue * 1.15) / targetLines;
    final interval = _niceInterval(roughInterval);
    final maxY = interval * ((maxValue * 1.15) / interval).ceil();

    return ChartYAxisScale(minY: 0, maxY: maxY, interval: interval);
  }

  /// Returns the X-axis label interval (in index units) to avoid overlap.
  static double xLabelInterval({
    required int pointCount,
    required double chartWidth,
    required DashboardPeriod period,
  }) {
    if (pointCount <= 1) return 1;

    final minLabelWidth = switch (period) {
      DashboardPeriod.thisYear || DashboardPeriod.allTime => 36.0,
      DashboardPeriod.thisWeek || DashboardPeriod.today => 28.0,
      _ => 44.0,
    };

    final maxLabels = (chartWidth / minLabelWidth).floor().clamp(3, 8);
    return math.max(1, (pointCount / maxLabels).ceil()).toDouble();
  }

  static double _niceInterval(double rough) {
    if (rough <= 0) return 1;
    final exponent = (math.log(rough) / math.ln10).floor();
    final fraction = rough / math.pow(10, exponent);
    final niceFraction = switch (fraction) {
      <= 1 => 1.0,
      <= 2 => 2.0,
      <= 2.5 => 2.5,
      <= 5 => 5.0,
      _ => 10.0,
    };
    return niceFraction * math.pow(10, exponent);
  }
}

class ChartYAxisScale {
  const ChartYAxisScale({
    required this.minY,
    required this.maxY,
    required this.interval,
  });

  final double minY;
  final double maxY;
  final double interval;
}
