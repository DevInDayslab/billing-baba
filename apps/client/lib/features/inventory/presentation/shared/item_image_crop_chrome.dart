import 'dart:math' as math;
import 'dart:typed_data';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Vyapar-style crop accent (dashed frame + square handles).
const itemImageCropAccent = Color(0xFF1A73E8);

const itemImageCropHandleHitSize = 32.0;

/// Larger hit target at corners so diagonal resize cursors show on the whole
/// corner zone (not only on the small blue square).
const itemImageCropCornerHitSize = 48.0;

const _handleVisibleCorner = 14.0;
const _handleVisibleEdge = 10.0;
const _dashLength = 6.0;
const _dashGap = 4.0;
const _minCropSide = 40.0;
double _cornerHitInsetFor(double hitSize) => hitSize / 2;

/// Confirmation before closing the crop editor without saving.
Future<bool> showDiscardItemImageChangesDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Discard Changes?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      icon: const Icon(Icons.close, size: 20),
                      color: AppColors.textSecondary,
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE8E8E8)),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Text(
                  'Are you sure you want to discard the changes?',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        backgroundColor: const Color(0xFFF0F0F0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Yes, Discard',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'No, Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// Hide default white dots; custom handles are drawn in [_ItemImageCropResizeOverlay].
Widget itemImageCropHiddenCornerBuilder(double size, EdgeAlignment alignment) {
  return SizedBox(width: size, height: size);
}

Widget itemImageCropOverlayBuilder(BuildContext context, Rect rect) {
  return CustomPaint(
    painter: _ItemImageCropFramePainter(),
    child: const SizedBox.expand(),
  );
}

class _ItemImageCropFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = itemImageCropAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    _drawDashedRect(canvas, Offset.zero & size, paint);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    _drawDashedLine(canvas, rect.topLeft, rect.topRight, paint);
    _drawDashedLine(canvas, rect.topRight, rect.bottomRight, paint);
    _drawDashedLine(canvas, rect.bottomRight, rect.bottomLeft, paint);
    _drawDashedLine(canvas, rect.bottomLeft, rect.topLeft, paint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    final total = (end - start).distance;
    if (total <= 0) return;

    final direction = (end - start) / total;
    var distance = 0.0;
    while (distance < total) {
      final dashEnd = distance + _dashLength;
      final segmentEnd = dashEnd.clamp(0.0, total);
      canvas.drawLine(
        start + direction * distance,
        start + direction * segmentEnd,
        paint,
      );
      distance += _dashLength + _dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _ItemCropResizeHandle {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}

MouseCursor _cursorForHandle(_ItemCropResizeHandle handle) {
  return switch (handle) {
    _ItemCropResizeHandle.topLeft || _ItemCropResizeHandle.bottomRight =>
      SystemMouseCursors.resizeUpLeftDownRight,
    _ItemCropResizeHandle.topRight || _ItemCropResizeHandle.bottomLeft =>
      SystemMouseCursors.resizeUpRightDownLeft,
    _ItemCropResizeHandle.top || _ItemCropResizeHandle.bottom =>
      SystemMouseCursors.resizeUpDown,
    _ItemCropResizeHandle.left || _ItemCropResizeHandle.right =>
      SystemMouseCursors.resizeLeftRight,
  };
}

Rect _resizeCropRect({
  required Rect from,
  required Offset delta,
  required _ItemCropResizeHandle handle,
  double? aspectRatio,
}) {
  if (aspectRatio == null || aspectRatio <= 0) {
    return _enforceMinSize(_resizeFree(from, delta, handle));
  }
  return _enforceMinSize(
    _resizeWithAspectRatio(from, delta, handle, aspectRatio),
  );
}

Rect _enforceMinSize(Rect rect) {
  var width = rect.width;
  var height = rect.height;
  if (width < _minCropSide) {
    width = _minCropSide;
  }
  if (height < _minCropSide) {
    height = _minCropSide;
  }
  return Rect.fromLTWH(rect.left, rect.top, width, height);
}

Rect _resizeFree(Rect from, Offset delta, _ItemCropResizeHandle handle) {
  return switch (handle) {
    _ItemCropResizeHandle.topLeft => Rect.fromLTRB(
      from.left + delta.dx,
      from.top + delta.dy,
      from.right,
      from.bottom,
    ),
    _ItemCropResizeHandle.top => Rect.fromLTRB(
      from.left,
      from.top + delta.dy,
      from.right,
      from.bottom,
    ),
    _ItemCropResizeHandle.topRight => Rect.fromLTRB(
      from.left,
      from.top + delta.dy,
      from.right + delta.dx,
      from.bottom,
    ),
    _ItemCropResizeHandle.right => Rect.fromLTRB(
      from.left,
      from.top,
      from.right + delta.dx,
      from.bottom,
    ),
    _ItemCropResizeHandle.bottomRight => Rect.fromLTRB(
      from.left,
      from.top,
      from.right + delta.dx,
      from.bottom + delta.dy,
    ),
    _ItemCropResizeHandle.bottom => Rect.fromLTRB(
      from.left,
      from.top,
      from.right,
      from.bottom + delta.dy,
    ),
    _ItemCropResizeHandle.bottomLeft => Rect.fromLTRB(
      from.left + delta.dx,
      from.top,
      from.right,
      from.bottom + delta.dy,
    ),
    _ItemCropResizeHandle.left => Rect.fromLTRB(
      from.left + delta.dx,
      from.top,
      from.right,
      from.bottom,
    ),
  };
}

Rect _resizeWithAspectRatio(
  Rect from,
  Offset delta,
  _ItemCropResizeHandle handle,
  double aspectRatio,
) {
  return switch (handle) {
    _ItemCropResizeHandle.bottomRight => _aspectFromAnchors(
      anchorLeft: from.left,
      anchorTop: from.top,
      movingRight: from.right + delta.dx,
      movingBottom: from.bottom + delta.dy,
      aspectRatio: aspectRatio,
    ),
    _ItemCropResizeHandle.bottomLeft => _aspectFromAnchors(
      anchorRight: from.right,
      anchorTop: from.top,
      movingLeft: from.left + delta.dx,
      movingBottom: from.bottom + delta.dy,
      aspectRatio: aspectRatio,
    ),
    _ItemCropResizeHandle.topRight => _aspectFromAnchors(
      anchorLeft: from.left,
      anchorBottom: from.bottom,
      movingRight: from.right + delta.dx,
      movingTop: from.top + delta.dy,
      aspectRatio: aspectRatio,
    ),
    _ItemCropResizeHandle.topLeft => _aspectFromAnchors(
      anchorRight: from.right,
      anchorBottom: from.bottom,
      movingLeft: from.left + delta.dx,
      movingTop: from.top + delta.dy,
      aspectRatio: aspectRatio,
    ),
    _ItemCropResizeHandle.top => _edgeAspectVertical(
      from: from,
      delta: delta.dy,
      aspectRatio: aspectRatio,
      anchorBottom: from.bottom,
    ),
    _ItemCropResizeHandle.bottom => _edgeAspectVertical(
      from: from,
      delta: delta.dy,
      aspectRatio: aspectRatio,
      anchorTop: from.top,
    ),
    _ItemCropResizeHandle.left => _edgeAspectHorizontal(
      from: from,
      delta: delta.dx,
      aspectRatio: aspectRatio,
      anchorRight: from.right,
    ),
    _ItemCropResizeHandle.right => _edgeAspectHorizontal(
      from: from,
      delta: delta.dx,
      aspectRatio: aspectRatio,
      anchorLeft: from.left,
    ),
  };
}

Rect _aspectFromAnchors({
  double? anchorLeft,
  double? anchorTop,
  double? anchorRight,
  double? anchorBottom,
  double? movingLeft,
  double? movingTop,
  double? movingRight,
  double? movingBottom,
  required double aspectRatio,
}) {
  final left = movingLeft ?? anchorLeft!;
  final top = movingTop ?? anchorTop!;
  final right = movingRight ?? anchorRight!;
  final bottom = movingBottom ?? anchorBottom!;

  var width = right - left;
  var height = bottom - top;
  if (width <= 0 || height <= 0) {
    return Rect.fromLTWH(left, top, _minCropSide, _minCropSide / aspectRatio);
  }

  if (width / height > aspectRatio) {
    width = height * aspectRatio;
  } else {
    height = width / aspectRatio;
  }

  width = math.max(width, _minCropSide);
  height = math.max(height, _minCropSide / aspectRatio);

  if (anchorLeft != null && anchorTop != null) {
    return Rect.fromLTWH(anchorLeft, anchorTop, width, height);
  }
  if (anchorRight != null && anchorTop != null) {
    return Rect.fromLTWH(anchorRight - width, anchorTop, width, height);
  }
  if (anchorLeft != null && anchorBottom != null) {
    return Rect.fromLTWH(anchorLeft, anchorBottom - height, width, height);
  }
  return Rect.fromLTWH(
    anchorRight! - width,
    anchorBottom! - height,
    width,
    height,
  );
}

Rect _edgeAspectVertical({
  required Rect from,
  required double delta,
  required double aspectRatio,
  double? anchorTop,
  double? anchorBottom,
}) {
  final cx = from.center.dx;
  if (anchorBottom != null) {
    final newTop = from.top + delta;
    var height = anchorBottom - newTop;
    height = math.max(height, _minCropSide);
    final width = height * aspectRatio;
    return Rect.fromLTWH(cx - width / 2, anchorBottom - height, width, height);
  }
  final newBottom = from.bottom + delta;
  var height = newBottom - anchorTop!;
  height = math.max(height, _minCropSide);
  final width = height * aspectRatio;
  return Rect.fromLTWH(cx - width / 2, anchorTop, width, height);
}

Rect _edgeAspectHorizontal({
  required Rect from,
  required double delta,
  required double aspectRatio,
  double? anchorLeft,
  double? anchorRight,
}) {
  final cy = from.center.dy;
  if (anchorRight != null) {
    final newLeft = from.left + delta;
    var width = anchorRight - newLeft;
    width = math.max(width, _minCropSide);
    final height = width / aspectRatio;
    return Rect.fromLTWH(anchorRight - width, cy - height / 2, width, height);
  }
  final newRight = from.right + delta;
  var width = newRight - anchorLeft!;
  width = math.max(width, _minCropSide);
  final height = width / aspectRatio;
  return Rect.fromLTWH(anchorLeft, cy - height / 2, width, height);
}

class ItemImageCropSurface extends StatefulWidget {
  const ItemImageCropSurface({
    required this.image,
    required this.controller,
    required this.onCropped,
    this.cropKey,
    this.aspectRatio,
    this.initialRectBuilder,
    this.baseColor = const Color(0xFFD8D8D8),
    this.maskColor,
    this.filterQuality = FilterQuality.medium,
    super.key,
  });

  final Uint8List image;
  final CropController controller;
  final ValueChanged<CropResult> onCropped;
  final Key? cropKey;
  final double? aspectRatio;
  final InitialRectBuilder? initialRectBuilder;
  final Color baseColor;
  final Color? maskColor;
  final FilterQuality filterQuality;

  @override
  State<ItemImageCropSurface> createState() => _ItemImageCropSurfaceState();
}

class _ItemImageCropSurfaceState extends State<ItemImageCropSurface> {
  Rect? _cropRect;
  Rect? _dragStartRect;
  Offset _dragAccumulated = Offset.zero;
  _ItemCropResizeHandle? _activeResizeHandle;

  void _onCropRectChanged(Rect viewportRect) {
    final previous = _cropRect;
    if (previous != null &&
        (previous.left - viewportRect.left).abs() < 0.5 &&
        (previous.top - viewportRect.top).abs() < 0.5 &&
        (previous.width - viewportRect.width).abs() < 0.5 &&
        (previous.height - viewportRect.height).abs() < 0.5) {
      return;
    }
    setState(() => _cropRect = viewportRect);
  }

  void _onResizeDragStart(_ItemCropResizeHandle handle) {
    _activeResizeHandle = handle;
    _dragStartRect = _cropRect;
    _dragAccumulated = Offset.zero;
  }

  void _onResizeDrag(
    _ItemCropResizeHandle handle,
    DragUpdateDetails details,
  ) {
    if (_activeResizeHandle != handle) return;
    final start = _dragStartRect;
    if (start == null) return;

    _dragAccumulated += details.delta;
    final next = _resizeCropRect(
      from: start,
      delta: _dragAccumulated,
      handle: handle,
      aspectRatio: widget.aspectRatio,
    );
    widget.controller.cropRect = next;
  }

  void _onResizeDragEnd() {
    _dragStartRect = null;
    _dragAccumulated = Offset.zero;
    _activeResizeHandle = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Crop(
              key: widget.cropKey,
              image: widget.image,
              controller: widget.controller,
              aspectRatio: widget.aspectRatio,
              initialRectBuilder: widget.initialRectBuilder,
              baseColor: widget.baseColor,
              maskColor: widget.maskColor,
              filterQuality: widget.filterQuality,
              cornerDotBuilder: itemImageCropHiddenCornerBuilder,
              overlayBuilder: itemImageCropOverlayBuilder,
              onMoved: (viewportRect, _) => _onCropRectChanged(viewportRect),
              onCropped: widget.onCropped,
            ),
            if (_cropRect != null)
              Positioned.fill(
                child: _ItemImageCropResizeOverlay(
                  cropRect: _cropRect!,
                  aspectRatio: widget.aspectRatio,
                  onPanStart: _onResizeDragStart,
                  onPanEnd: _onResizeDragEnd,
                  onResizeDrag: _onResizeDrag,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ItemImageCropResizeOverlay extends StatelessWidget {
  const _ItemImageCropResizeOverlay({
    required this.cropRect,
    required this.aspectRatio,
    required this.onPanStart,
    required this.onPanEnd,
    required this.onResizeDrag,
  });

  final Rect cropRect;
  final double? aspectRatio;
  final void Function(_ItemCropResizeHandle handle) onPanStart;
  final VoidCallback onPanEnd;
  final void Function(_ItemCropResizeHandle handle, DragUpdateDetails details)
  onResizeDrag;

  @override
  Widget build(BuildContext context) {
    final cornerInset = _cornerHitInsetFor(itemImageCropCornerHitSize);
    final edgeInset = _cornerHitInsetFor(itemImageCropHandleHitSize);
    final edgeSpanH = math.max(
      0.0,
      cropRect.width - itemImageCropCornerHitSize,
    );
    final edgeSpanV = math.max(
      0.0,
      cropRect.height - itemImageCropCornerHitSize,
    );

    // Edges first, corners on top so diagonal cursors win at corner overlap.
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        if (edgeSpanH > 0)
          _edgeHandle(
            handle: _ItemCropResizeHandle.top,
            left: cropRect.left + cornerInset,
            top: cropRect.top - edgeInset,
            width: edgeSpanH,
            height: itemImageCropHandleHitSize,
          ),
        if (edgeSpanH > 0)
          _edgeHandle(
            handle: _ItemCropResizeHandle.bottom,
            left: cropRect.left + cornerInset,
            top: cropRect.bottom - edgeInset,
            width: edgeSpanH,
            height: itemImageCropHandleHitSize,
          ),
        if (edgeSpanV > 0)
          _edgeHandle(
            handle: _ItemCropResizeHandle.left,
            left: cropRect.left - edgeInset,
            top: cropRect.top + cornerInset,
            width: itemImageCropHandleHitSize,
            height: edgeSpanV,
          ),
        if (edgeSpanV > 0)
          _edgeHandle(
            handle: _ItemCropResizeHandle.right,
            left: cropRect.right - edgeInset,
            top: cropRect.top + cornerInset,
            width: itemImageCropHandleHitSize,
            height: edgeSpanV,
          ),
        _cornerHandle(_ItemCropResizeHandle.topLeft),
        _cornerHandle(_ItemCropResizeHandle.topRight),
        _cornerHandle(_ItemCropResizeHandle.bottomLeft),
        _cornerHandle(_ItemCropResizeHandle.bottomRight),
      ],
    );
  }

  Widget _cornerHandle(_ItemCropResizeHandle handle) {
    final offset = switch (handle) {
      _ItemCropResizeHandle.topLeft => Offset(cropRect.left, cropRect.top),
      _ItemCropResizeHandle.topRight => Offset(cropRect.right, cropRect.top),
      _ItemCropResizeHandle.bottomLeft => Offset(
        cropRect.left,
        cropRect.bottom,
      ),
      _ItemCropResizeHandle.bottomRight => Offset(
        cropRect.right,
        cropRect.bottom,
      ),
      _ => Offset.zero,
    };

    final inset = _cornerHitInsetFor(itemImageCropCornerHitSize);
    return _resizeTarget(
      handle: handle,
      left: offset.dx - inset,
      top: offset.dy - inset,
      width: itemImageCropCornerHitSize,
      height: itemImageCropCornerHitSize,
      child: const _HandleVisual(isCorner: true),
    );
  }

  Widget _edgeHandle({
    required _ItemCropResizeHandle handle,
    required double left,
    required double top,
    required double width,
    required double height,
  }) {
    return _resizeTarget(
      handle: handle,
      left: left,
      top: top,
      width: width,
      height: height,
      child: const _HandleVisual(isCorner: false),
    );
  }

  Widget _resizeTarget({
    required _ItemCropResizeHandle handle,
    required double left,
    required double top,
    required double width,
    required double height,
    required Widget child,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: MouseRegion(
        cursor: _cursorForHandle(handle),
        hitTestBehavior: HitTestBehavior.opaque,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          dragStartBehavior: DragStartBehavior.down,
          onPanStart: (_) => onPanStart(handle),
          onPanUpdate: (details) => onResizeDrag(handle, details),
          onPanEnd: (_) => onPanEnd(),
          onPanCancel: onPanEnd,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: SizedBox.expand()),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _HandleVisual extends StatelessWidget {
  const _HandleVisual({required this.isCorner});

  final bool isCorner;

  @override
  Widget build(BuildContext context) {
    final size = isCorner ? _handleVisibleCorner : _handleVisibleEdge;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: itemImageCropAccent,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SizedBox(width: size, height: size),
    );
  }
}
