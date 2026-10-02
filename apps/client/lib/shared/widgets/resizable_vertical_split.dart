import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _splitBorderColor = Color(0xFFE0E0E0);

/// Vertical split with a draggable divider between [topChild] and [bottomChild].
///
/// [ratio] is the fraction of available height (excluding the divider) allocated
/// to the top pane. Dragging updates [onRatioChanged].
class ResizableVerticalSplit extends StatefulWidget {
  const ResizableVerticalSplit({
    required this.topChild,
    required this.bottomChild,
    required this.ratio,
    required this.onRatioChanged,
    this.minTopHeight = 180,
    this.minBottomHeight = 200,
    super.key,
  });

  final Widget topChild;
  final Widget bottomChild;
  final double ratio;
  final ValueChanged<double> onRatioChanged;
  final double minTopHeight;
  final double minBottomHeight;

  static const dividerHeight = 9.0;

  @override
  State<ResizableVerticalSplit> createState() => _ResizableVerticalSplitState();
}

class _ResizableVerticalSplitState extends State<ResizableVerticalSplit> {
  bool _isDragging = false;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available =
            constraints.maxHeight - ResizableVerticalSplit.dividerHeight;
        if (available <= 0) {
          return const SizedBox.shrink();
        }

        final maxTop = available - widget.minBottomHeight;
        final minTop = widget.minTopHeight.clamp(0, maxTop).toDouble();
        final topHeight = (available * widget.ratio)
            .clamp(minTop, maxTop)
            .toDouble();
        final bottomHeight = available - topHeight;
        final isActive = _isDragging || _isHovering;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: topHeight,
              child: ClipRect(child: widget.topChild),
            ),
            _VerticalSplitDivider(
              isActive: isActive,
              onHover: (hovering) => setState(() => _isHovering = hovering),
              onDragStart: () => setState(() => _isDragging = true),
              onDragUpdate: (delta) {
                final newTop = (topHeight + delta)
                    .clamp(minTop, maxTop)
                    .toDouble();
                widget.onRatioChanged(newTop / available);
              },
              onDragEnd: () => setState(() {
                _isDragging = false;
                _isHovering = false;
              }),
            ),
            SizedBox(
              height: bottomHeight,
              child: widget.bottomChild,
            ),
          ],
        );
      },
    );
  }
}

class _VerticalSplitDivider extends StatelessWidget {
  const _VerticalSplitDivider({
    required this.isActive,
    required this.onHover,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final bool isActive;
  final ValueChanged<bool> onHover;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (_) => onDragStart(),
        onVerticalDragUpdate: (details) => onDragUpdate(details.delta.dy),
        onVerticalDragEnd: (_) => onDragEnd(),
        onVerticalDragCancel: onDragEnd,
        child: SizedBox(
          height: ResizableVerticalSplit.dividerHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : Colors.transparent,
                  ),
                ),
              ),
              if (isActive)
                Icon(
                  Icons.drag_handle,
                  size: 18,
                  color: AppColors.primary.withValues(alpha: 0.85),
                ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: 0,
                child: Container(
                  height: isActive ? 2 : 1,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : _splitBorderColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
