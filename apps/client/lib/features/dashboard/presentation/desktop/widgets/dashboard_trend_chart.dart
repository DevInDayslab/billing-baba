import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/shared/chart/chart_axis_formatters.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardTrendChart extends StatefulWidget {
  const DashboardTrendChart({
    required this.points,
    required this.lineColor,
    required this.period,
    this.minimal = false,
    this.emptyMessage = 'No sales available',
    super.key,
  });

  final List<DashboardTrendPointModel> points;
  final Color lineColor;
  final DashboardPeriod period;
  final bool minimal;
  final String emptyMessage;

  @override
  State<DashboardTrendChart> createState() => _DashboardTrendChartState();
}

class _DashboardTrendChartState extends State<DashboardTrendChart> {
  static final _tooltipDate = DateFormat('d MMM');

  late _ChartConfig _config;

  @override
  void initState() {
    super.initState();
    _config = _ChartConfig.from(points: widget.points);
  }

  @override
  void didUpdateWidget(covariant DashboardTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points || oldWidget.period != widget.period) {
      _config = _ChartConfig.from(points: widget.points);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.minimal
        ? const EdgeInsets.only(top: AppSpacing.xs)
        : const EdgeInsets.only(
            top: AppSpacing.sm,
            right: AppSpacing.xs,
            left: AppSpacing.xs,
          );

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final xInterval = ChartAxisFormatters.xLabelInterval(
            pointCount: widget.points.length,
            chartWidth: constraints.maxWidth,
            period: widget.period,
          );

          return Stack(
            clipBehavior: Clip.none,
            children: [
              LineChart(
                _buildChartData(xInterval),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              ),
              if (!_config.hasPlottableData && !widget.minimal)
                Positioned.fill(
                  child: Center(
                    child: Text(
                      widget.emptyMessage,
                      style: TextStyle(
                        fontSize: widget.minimal ? 11 : 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  LineChartData _buildChartData(double xInterval) {
    final yScale = _config.yScale;
    final isSinglePoint = widget.points.length == 1 && _config.hasPlottableData;

    return LineChartData(
      minX: _config.minX,
      maxX: _config.maxX,
      minY: yScale.minY,
      maxY: yScale.maxY,
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: yScale.interval,
        getDrawingHorizontalLine: (_) => FlLine(
          color: const Color(0xFFE8E8E8).withValues(alpha: 0.8),
          strokeWidth: widget.minimal ? 0.5 : 0.75,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: widget.minimal
            ? const AxisTitles()
            : AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: yScale.interval,
                  getTitlesWidget: (value, meta) {
                    if (value < 0 || value > yScale.maxY) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: Text(
                        ChartAxisFormatters.formatYAxis(value),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: widget.minimal ? 20 : 26,
            interval: xInterval,
            getTitlesWidget: (value, meta) {
              final index = value.round();
              if (index < 0 || index >= widget.points.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(
                  top: widget.minimal ? 2 : AppSpacing.sm,
                ),
                child: Text(
                  ChartAxisFormatters.formatXAxis(
                    widget.points[index].date,
                    widget.period,
                  ),
                  style: TextStyle(
                    fontSize: widget.minimal ? 9 : 10,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        enabled: _config.hasPlottableData,
        touchSpotThreshold: 22,
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((_) {
            return TouchedSpotIndicatorData(
              const FlLine(color: Colors.transparent, strokeWidth: 0),
              FlDotData(
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 5.5,
                      color: Colors.white,
                      strokeColor: widget.lineColor,
                      strokeWidth: 2.5,
                    ),
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          tooltipBorderRadius: BorderRadius.circular(8),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          tooltipMargin: 10,
          maxContentWidth: 140,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipColor: (_) => AppColors.surface,
          tooltipBorder: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
          ),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.spotIndex;
              if (index < 0 || index >= widget.points.length) {
                return null;
              }
              final point = widget.points[index];
              return LineTooltipItem(
                '${_tooltipDate.format(point.date)}\n',
                const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '● ',
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.lineColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ChartAxisFormatters.formatCurrency(point.amount),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _config.spots,
          isCurved: _config.hasPlottableData && !isSinglePoint,
          curveSmoothness: 0.25,
          preventCurveOverShooting: true,
          color: _config.hasPlottableData
              ? widget.lineColor
              : widget.lineColor.withValues(alpha: 0),
          barWidth: widget.minimal ? 2 : 2.5,
          dotData: FlDotData(
            show: isSinglePoint,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 5.5,
              color: Colors.white,
              strokeColor: widget.lineColor,
              strokeWidth: 2.5,
            ),
          ),
          belowBarData: BarAreaData(
            show: _config.hasPlottableData,
            gradient: widget.minimal
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.lineColor.withValues(alpha: 0.1),
                      widget.lineColor.withValues(alpha: 0.01),
                    ],
                  ),
            color: widget.minimal
                ? widget.lineColor.withValues(alpha: 0.06)
                : null,
          ),
        ),
      ],
    );
  }
}

class _ChartConfig {
  const _ChartConfig({
    required this.spots,
    required this.yScale,
    required this.minX,
    required this.maxX,
    required this.hasPlottableData,
  });

  factory _ChartConfig.from({
    required List<DashboardTrendPointModel> points,
  }) {
    final hasPositiveAmount =
        points.isNotEmpty && points.any((point) => point.amount > 0);
    final hasPlottableData =
        hasPositiveAmount || points.length >= 2;
    final amounts = points.map((point) => point.amount);
    final yScale = ChartAxisFormatters.calculateYAxis(
      hasPlottableData ? amounts : const [0],
    );

    if (points.isEmpty) {
      return _ChartConfig(
        spots: const [FlSpot.zero],
        yScale: yScale,
        minX: 0,
        maxX: 4,
        hasPlottableData: false,
      );
    }

    if (points.length == 1) {
      return _ChartConfig(
        spots: [FlSpot(0, points.first.amount)],
        yScale: yScale,
        minX: -1,
        maxX: 1,
        hasPlottableData: hasPlottableData,
      );
    }

    final spots = points
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.amount))
        .toList();

    return _ChartConfig(
      spots: spots,
      yScale: yScale,
      minX: -0.5,
      maxX: points.length - 0.5,
      hasPlottableData: hasPlottableData,
    );
  }

  final List<FlSpot> spots;
  final ChartYAxisScale yScale;
  final double minX;
  final double maxX;
  final bool hasPlottableData;
}
