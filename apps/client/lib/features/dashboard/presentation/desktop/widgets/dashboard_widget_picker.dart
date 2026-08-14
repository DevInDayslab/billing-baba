import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_widget_preferences_provider.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_side_widget.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/shared/layout/dashboard_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

const _rowEstimateHeight = 88.0;
const _footerEstimateHeight = 56.0;
const _maxVisibleRows = 4;
const _overlayTopPadding = 16.0;

class DashboardWidgetPicker extends ConsumerStatefulWidget {
  const DashboardWidgetPicker({
    required this.dashboard,
    this.dashed = false,
    super.key,
  });

  final DashboardModel dashboard;
  final bool dashed;

  @override
  ConsumerState<DashboardWidgetPicker> createState() =>
      _DashboardWidgetPickerState();
}

class _DashboardWidgetPickerState extends ConsumerState<DashboardWidgetPicker> {
  final _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  var _isOpen = false;

  @override
  void didUpdateWidget(covariant DashboardWidgetPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isOpen && !identical(oldWidget.dashboard, widget.dashboard)) {
      _scheduleOverlayRebuild();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _scheduleOverlayRebuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isOpen) return;
      _overlayEntry?.markNeedsBuild();
    });
  }

  void _open() {
    if (_isOpen) return;
    final container = ProviderScope.containerOf(context, listen: false);
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => UncontrolledProviderScope(
        container: container,
        child: _PickerOverlay(
          layerLink: _layerLink,
          triggerKey: _triggerKey,
          dashboard: widget.dashboard,
          horizontalPadding: DashboardLayout.pagePadding,
          onToggle: (sideWidget) {
            ref
                .read(dashboardWidgetPreferencesProvider.notifier)
                .toggle(sideWidget);
          },
          onDismiss: _close,
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _close() {
    if (!_isOpen) return;
    _removeOverlay();
    if (mounted) setState(() => _isOpen = false);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);

    final trigger = InkWell(
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

    final decoratedTrigger = widget.dashed
        ? CustomPaint(
            painter: _DashedBorderPainter(
              color: DashboardColors.border,
              radius: DashboardLayout.cardRadius,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: DashboardDecor.cardRadius,
              ),
              child: trigger,
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: DashboardDecor.cardRadius,
              border: Border.all(color: DashboardColors.border),
            ),
            child: trigger,
          );

    return CompositedTransformTarget(
      key: _triggerKey,
      link: _layerLink,
      child: decoratedTrigger,
    );
  }
}

class _PickerOverlay extends ConsumerWidget {
  const _PickerOverlay({
    required this.layerLink,
    required this.triggerKey,
    required this.dashboard,
    required this.horizontalPadding,
    required this.onToggle,
    required this.onDismiss,
  });

  final LayerLink layerLink;
  final GlobalKey triggerKey;
  final DashboardModel dashboard;
  final double horizontalPadding;
  final ValueChanged<DashboardSideWidget> onToggle;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(dashboardWidgetPreferencesProvider);
    final triggerBox =
        triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final triggerSize = triggerBox?.size ?? const Size(280, 40);
    final triggerOffset = triggerBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final triggerRect = triggerOffset & triggerSize;

    const preferredListHeight = _rowEstimateHeight * _maxVisibleRows;
    final spaceForPanel = math.max(
      triggerRect.bottom - _overlayTopPadding,
      _footerEstimateHeight + 120,
    );
    final maxListHeight = math.min(
      preferredListHeight,
      spaceForPanel - _footerEstimateHeight,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.translucent,
            child: const ColoredBox(color: Color(0x1A000000)),
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.bottomCenter,
          showWhenUnlinked: false,
          child: Material(
            elevation: 8,
            shadowColor: Colors.black26,
            color: AppColors.surface,
            borderRadius: DashboardDecor.cardRadius,
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: triggerSize.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxListHeight),
                    child: _PickerList(
                      dashboard: dashboard,
                      enabled: enabled,
                      horizontalPadding: horizontalPadding,
                      onToggle: onToggle,
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: DashboardColors.divider,
                  ),
                  _PickerFooter(
                    horizontalPadding: horizontalPadding,
                    onClose: onDismiss,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerList extends StatefulWidget {
  const _PickerList({
    required this.dashboard,
    required this.enabled,
    required this.horizontalPadding,
    required this.onToggle,
  });

  final DashboardModel dashboard;
  final List<DashboardSideWidget> enabled;
  final double horizontalPadding;
  final ValueChanged<DashboardSideWidget> onToggle;

  @override
  State<_PickerList> createState() => _PickerListState();
}

class _PickerListState extends State<_PickerList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const widgets = DashboardSideWidget.values;

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: widgets.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          thickness: 1,
          color: DashboardColors.divider,
        ),
        itemBuilder: (context, index) {
          final sideWidget = widgets[index];
          return _PickerRow(
            title: sideWidget.label,
            subtitle: _pickerSubtitle(sideWidget, widget.dashboard),
            isEnabled: widget.enabled.contains(sideWidget),
            horizontalPadding: widget.horizontalPadding,
            onToggle: () => widget.onToggle(sideWidget),
          );
        },
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.horizontalPadding,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
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
          vertical: AppSpacing.xl,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: DashboardTypography.metadata,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    style: DashboardTypography.supportingLabel.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isEnabled ? Icons.remove : Icons.add,
              size: 22,
              color: isEnabled ? AppColors.navInactive : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerFooter extends StatelessWidget {
  const _PickerFooter({
    required this.horizontalPadding,
    required this.onClose,
  });

  final double horizontalPadding;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppSpacing.lg,
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
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 16),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}

String _pickerSubtitle(DashboardSideWidget widget, DashboardModel dashboard) {
  return switch (widget) {
    DashboardSideWidget.purchases => _currencyFormat.format(
      dashboard.purchases.totalAmount,
    ),
    DashboardSideWidget.expenses => _currencyFormat.format(
      dashboard.finance.expenses,
    ),
    DashboardSideWidget.stockValue => _currencyFormat.format(
      dashboard.inventory.totalStockValue,
    ),
    DashboardSideWidget.cashInHand => _currencyFormat.format(
      dashboard.finance.cashIn,
    ),
    DashboardSideWidget.bankBalance => '—',
    DashboardSideWidget.lowStock => 'View Items Low on Stock',
  };
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
