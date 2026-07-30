import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Lightweight shimmer placeholder that preserves layout while images load.
class AppImagePlaceholder extends StatelessWidget {
  const AppImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final child = Shimmer.fromColors(
      baseColor: AppColors.background,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        color: AppColors.background,
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    return child;
  }
}

/// Tap-to-retry error surface used by the shared network image widget.
class AppImageErrorPlaceholder extends StatelessWidget {
  const AppImageErrorPlaceholder({
    required this.onRetry,
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final VoidCallback onRetry;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: onRetry,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: height,
        color: AppColors.background,
        alignment: Alignment.center,
        child: Icon(
          Icons.refresh,
          size: 20,
          color: AppColors.textSecondary.withValues(alpha: 0.8),
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    return child;
  }
}
