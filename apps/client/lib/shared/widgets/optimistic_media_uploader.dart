import 'dart:typed_data';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

enum OptimisticMediaShape { circle, roundedRect }

/// Reusable media preview with optimistic local bytes and edit menu.
class OptimisticMediaUploader extends StatelessWidget {
  const OptimisticMediaUploader({
    required this.label,
    required this.onReplace,
    this.isUploading = false,
    this.width,
    this.height,
    this.size = 120,
    this.imageUrl,
    this.optimisticBytes,
    this.onRemove,
    this.placeholder,
    this.shape = OptimisticMediaShape.circle,
    this.replaceLabel = 'Replace',
    this.removeLabel = 'Remove',
    this.emptyLabel,
    this.fit = BoxFit.contain,
    super.key,
  });

  final String label;

  /// Square size used when [width]/[height] are omitted.
  final double size;
  final double? width;
  final double? height;

  /// Kept for API compatibility; progress UI is intentionally not shown.
  final bool isUploading;
  final VoidCallback onReplace;
  final VoidCallback? onRemove;
  final String? imageUrl;
  final Uint8List? optimisticBytes;
  final Widget? placeholder;
  final OptimisticMediaShape shape;
  final String replaceLabel;
  final String removeLabel;
  final String? emptyLabel;
  final BoxFit fit;

  double get _w => width ?? size;
  double get _h => height ?? size;

  bool get _hasOptimistic =>
      optimisticBytes != null && optimisticBytes!.isNotEmpty;

  bool get _hasRemote => imageUrl != null && imageUrl!.trim().isNotEmpty;

  bool get _hasImage => _hasOptimistic || _hasRemote;

  @override
  Widget build(BuildContext context) {
    final borderRadius = shape == OptimisticMediaShape.circle
        ? BorderRadius.circular(_w / 2)
        : AppRadius.smBorder;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = (_w * dpr).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: _w + 8,
          height: _h + 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 4,
                top: 4,
                child: Container(
                  width: _w,
                  height: _h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: borderRadius,
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: _buildPreview(
                      borderRadius,
                      cacheWidth: cacheW,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: PopupMenuButton<_MediaMenuAction>(
                  tooltip: 'Edit $label',
                  offset: const Offset(0, 8),
                  onSelected: (action) {
                    switch (action) {
                      case _MediaMenuAction.replace:
                        onReplace();
                      case _MediaMenuAction.remove:
                        onRemove?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _MediaMenuAction.replace,
                      child: Text(replaceLabel),
                    ),
                    if (_hasImage && onRemove != null)
                      PopupMenuItem(
                        value: _MediaMenuAction.remove,
                        child: Text(removeLabel),
                      ),
                  ],
                  child: const Material(
                    color: Colors.white,
                    shape: CircleBorder(
                      side: BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                    elevation: 1,
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(
    BorderRadius borderRadius, {
    required int cacheWidth,
  }) {
    // Prefer local bytes so the preview never flashes back to a network load.
    if (_hasOptimistic) {
      return Image.memory(
        optimisticBytes!,
        fit: fit,
        gaplessPlayback: true,
        cacheWidth: cacheWidth,
      );
    }

    if (_hasRemote) {
      return AppNetworkImage(
        imageUrl: imageUrl!,
        width: _w,
        height: _h,
        fit: fit,
        borderRadius: borderRadius,
        memCacheWidth: cacheWidth,
        placeholder: placeholder ?? _emptyState(),
        errorWidget: placeholder ?? _emptyState(),
      );
    }

    return placeholder ?? _emptyState();
  }

  Widget _emptyState() {
    return SizedBox(
      width: _w,
      height: _h,
      child: ColoredBox(
        color: const Color(0xFFF7F7F7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                shape == OptimisticMediaShape.circle
                    ? Icons.storefront_outlined
                    : Icons.draw_outlined,
                size: 22,
                color: AppColors.textSecondary,
              ),
              if (emptyLabel != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  emptyLabel!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _MediaMenuAction { replace, remove }
