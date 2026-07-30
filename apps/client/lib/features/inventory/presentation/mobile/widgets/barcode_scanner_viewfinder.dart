import 'package:flutter/material.dart';

const _cornerGreen = Color(0xFF2E7D32);
const _scanLineRed = Color(0xFFE53935);

/// Viewfinder overlay with green corner brackets and a red scan line.
class BarcodeScannerViewfinder extends StatelessWidget {
  const BarcodeScannerViewfinder({
    required this.scanWindow,
    super.key,
  });

  final Rect scanWindow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarcodeScannerViewfinderPainter(scanWindow: scanWindow),
      child: const SizedBox.expand(),
    );
  }
}

class _BarcodeScannerViewfinderPainter extends CustomPainter {
  const _BarcodeScannerViewfinderPainter({required this.scanWindow});

  final Rect scanWindow;

  static const _cornerLength = 28.0;
  static const _cornerStroke = 4.0;
  static const _frameStroke = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
    final fullRect = Offset.zero & size;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(fullRect),
        Path()..addRect(scanWindow),
      ),
      dimPaint,
    );

    final framePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _frameStroke;
    canvas.drawRect(scanWindow, framePaint);

    final cornerPaint = Paint()
      ..color = _cornerGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = _cornerStroke
      ..strokeCap = StrokeCap.round;

    final left = scanWindow.left;
    final top = scanWindow.top;
    final right = scanWindow.right;
    final bottom = scanWindow.bottom;

    _drawCorner(canvas, cornerPaint, Offset(left, top), true, true);
    _drawCorner(canvas, cornerPaint, Offset(right, top), false, true);
    _drawCorner(canvas, cornerPaint, Offset(left, bottom), true, false);
    _drawCorner(canvas, cornerPaint, Offset(right, bottom), false, false);

    final scanLineY = scanWindow.center.dy;
    final scanLinePaint = Paint()
      ..color = _scanLineRed
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(left + 8, scanLineY),
      Offset(right - 8, scanLineY),
      scanLinePaint,
    );
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint,
    Offset corner,
    bool isLeft,
    bool isTop,
  ) {
    final horizontalEnd = corner.dx + (isLeft ? _cornerLength : -_cornerLength);
    final verticalEnd = corner.dy + (isTop ? _cornerLength : -_cornerLength);

    canvas
      ..drawLine(corner, Offset(horizontalEnd, corner.dy), paint)
      ..drawLine(corner, Offset(corner.dx, verticalEnd), paint);
  }

  @override
  bool shouldRepaint(covariant _BarcodeScannerViewfinderPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow;
  }
}
