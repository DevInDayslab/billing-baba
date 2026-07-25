import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Simple line-art illustration for collaboration empty states.
class CollaborationEmptyIllustration extends StatelessWidget {
  const CollaborationEmptyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 100,
      child: CustomPaint(
        painter: _IllustrationPainter(),
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final backRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.12,
        size.width * 0.62,
        size.height * 0.62,
      ),
      const Radius.circular(6),
    );
    final frontRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.28,
        size.height * 0.24,
        size.width * 0.62,
        size.height * 0.62,
      ),
      const Radius.circular(6),
    );

    canvas.drawRRect(backRect, stroke);
    canvas.drawRRect(frontRect, stroke);

    final linePaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;

    for (var i = 0; i < 3; i++) {
      final y = frontRect.top + 18 + (i * 14);
      canvas.drawLine(
        Offset(frontRect.left + 12, y),
        Offset(frontRect.right - 12, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
