import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/image/app_image_placeholder.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

enum BrandingImageShape { circle, rectangle }

class BrandingImageUploader extends StatelessWidget {
  const BrandingImageUploader({
    required this.label,
    required this.imageUrl,
    required this.isUploading,
    required this.onUpload,
    required this.onDelete,
    this.placeholder,
    this.shape = BrandingImageShape.rectangle,
    this.width,
    this.height = 100,
    super.key,
  });

  final String label;
  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onUpload;
  final VoidCallback? onDelete;
  final Widget? placeholder;
  final BrandingImageShape shape;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CustomPaint(
          painter: _DashedBorderPainter(
            shape: shape == BrandingImageShape.circle
                ? _DashedBorderShape.circle
                : _DashedBorderShape.rectangle,
            color: const Color(0xFFBDBDBD),
            borderRadius: AppRadius.sm,
          ),
          child: SizedBox(
            width: width ?? double.infinity,
            height: height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (hasImage)
                  ClipRRect(
                    borderRadius: shape == BrandingImageShape.circle
                        ? BorderRadius.circular(height / 2)
                        : AppRadius.smBorder,
                    child: AppNetworkImage(
                      imageUrl: imageUrl!,
                      width: width ?? double.infinity,
                      height: height,
                      fit: BoxFit.contain,
                      placeholder: AppImagePlaceholder(
                        width: width,
                        height: height,
                        borderRadius: shape == BrandingImageShape.circle
                            ? BorderRadius.circular(height / 2)
                            : AppRadius.smBorder,
                      ),
                      errorWidget:
                          placeholder ??
                          const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textSecondary,
                          ),
                    ),
                  )
                else
                  placeholder ??
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Upload $label',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                if (isUploading)
                  ColoredBox(
                    color: Colors.white.withValues(alpha: 0.7),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            OutlinedButton.icon(
              onPressed: isUploading ? null : onUpload,
              icon: const Icon(Icons.upload_file, size: 18),
              label: Text(hasImage ? 'Replace' : 'Upload'),
            ),
            if (hasImage && onDelete != null)
              TextButton.icon(
                onPressed: isUploading ? null : onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
          ],
        ),
      ],
    );
  }
}

enum _DashedBorderShape { circle, rectangle }

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.shape,
    required this.color,
    this.borderRadius = 0,
  });

  final _DashedBorderShape shape;
  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    if (shape == _DashedBorderShape.circle) {
      _drawDashedCircle(canvas, size, paint, dashWidth, dashSpace);
    } else {
      _drawDashedRect(canvas, size, paint, dashWidth, dashSpace);
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Size size,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final radius = size.shortestSide / 2 - paint.strokeWidth;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * 3.141592653589793 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (var i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashWidth + dashSpace)) / radius;
      final sweepAngle = dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  void _drawDashedRect(
    Canvas canvas,
    Size size,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        paint.strokeWidth / 2,
        paint.strokeWidth / 2,
        size.width - paint.strokeWidth,
        size.height - paint.strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
