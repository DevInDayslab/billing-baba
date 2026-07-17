import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_side_widget.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/dashboard/providers/dashboard_widget_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardWidgetPicker extends ConsumerStatefulWidget {
  const DashboardWidgetPicker({this.dashed = false, super.key});

  final bool dashed;

  @override
  ConsumerState<DashboardWidgetPicker> createState() =>
      _DashboardWidgetPickerState();
}

class _DashboardWidgetPickerState extends ConsumerState<DashboardWidgetPicker> {
  var _isOpen = false;

  void _open() => setState(() => _isOpen = true);

  void _close() {
    if (_isOpen) setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);
    final enabled = ref.watch(dashboardWidgetPreferencesProvider);

    final pickerBody = _isOpen
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final sideWidget in DashboardSideWidget.values)
                _PickerRow(
                  label: sideWidget.label,
                  isEnabled: enabled.contains(sideWidget),
                  horizontalPadding: metrics.padding,
                  onToggle: () => ref
                      .read(dashboardWidgetPreferencesProvider.notifier)
                      .toggle(sideWidget),
                ),
              InkWell(
                onTap: _close,
                hoverColor: AppColors.background,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: metrics.padding,
                    vertical: metrics.padding * 0.65,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Add Widget of Your Choice',
                          style: DashboardTypography.metadata,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: _close,
                        icon: const Icon(Icons.close, size: 16),
                        color: AppColors.textSecondary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : InkWell(
            onTap: _open,
            hoverColor: AppColors.background,
            borderRadius: DashboardDecor.cardRadius,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.padding,
                vertical: metrics.padding * 0.65,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 16, color: AppColors.primary),
                  SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      'Add Widget of Your Choice',
                      style: DashboardTypography.metadata,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );

    if (widget.dashed && !_isOpen) {
      return TapRegion(
        onTapOutside: (_) => _close(),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: DashboardColors.border,
            radius: DashboardLayout.cardRadius,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: DashboardDecor.cardRadius,
            ),
            child: pickerBody,
          ),
        ),
      );
    }

    return TapRegion(
      onTapOutside: (_) => _close(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: DashboardDecor.cardRadius,
          border: Border.all(color: DashboardColors.border),
          boxShadow: _isOpen ? DashboardDecor.cardShadow : null,
        ),
        child: pickerBody,
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.isEnabled,
    required this.horizontalPadding,
    required this.onToggle,
  });

  final String label;
  final bool isEnabled;
  final double horizontalPadding;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onToggle,
      hoverColor: AppColors.background,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: DashboardTypography.metadata.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              isEnabled ? Icons.remove : Icons.add,
              size: 16,
              color: isEnabled ? AppColors.error : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
