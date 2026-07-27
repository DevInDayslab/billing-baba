import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/shared/image/app_image_placeholder.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

Future<void> showItemImagePreviewDialog({
  required BuildContext context,
  required List<ItemImageModel> images,
  required int initialIndex,
  required Future<void> Function(ItemImageModel image) onSetPrimary,
  required Future<bool> Function(ItemImageModel image) onReplace,
  required Future<bool> Function(ItemImageModel image) onDelete,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _ItemImagePreviewDialog(
      images: images,
      initialIndex: initialIndex,
      onSetPrimary: onSetPrimary,
      onReplace: onReplace,
      onDelete: onDelete,
    ),
  );
}

class _ItemImagePreviewDialog extends StatefulWidget {
  const _ItemImagePreviewDialog({
    required this.images,
    required this.initialIndex,
    required this.onSetPrimary,
    required this.onReplace,
    required this.onDelete,
  });

  final List<ItemImageModel> images;
  final int initialIndex;
  final Future<void> Function(ItemImageModel image) onSetPrimary;
  final Future<bool> Function(ItemImageModel image) onReplace;
  final Future<bool> Function(ItemImageModel image) onDelete;

  @override
  State<_ItemImagePreviewDialog> createState() =>
      _ItemImagePreviewDialogState();
}

class _ItemImagePreviewDialogState extends State<_ItemImagePreviewDialog> {
  late int _index;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
  }

  ItemImageModel get _current => widget.images[_index];

  void _prev() {
    if (_index <= 0) return;
    setState(() => _index -= 1);
  }

  void _next() {
    if (_index >= widget.images.length - 1) return;
    setState(() => _index += 1);
  }

  Future<void> _setPrimary() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onSetPrimary(_current);
      if (mounted) Navigator.of(context).pop();
    } on Exception {
      // Caller shows snackbar.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _replace() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final ok = await widget.onReplace(_current);
      if (ok && mounted) Navigator.of(context).pop();
    } on Exception {
      // Caller shows snackbar.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final ok = await widget.onDelete(_current);
      if (ok && mounted) Navigator.of(context).pop();
    } on Exception {
      // Caller shows snackbar.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _current;
    final hasPrev = _index > 0;
    final hasNext = _index < widget.images.length - 1;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Image Preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_index + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: AppRadius.mdBorder,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: AppNetworkImage(
                            imageUrl: image.urlForDetail(),
                            sourceMediaAssetId: image.mediaAssetId,
                            displayContext: ImageDisplayContext.detail,
                            fit: BoxFit.contain,
                            placeholder: const AppImagePlaceholder(),
                            errorWidget: const Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      if (hasPrev)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: _busy ? null : _prev,
                            icon: const Icon(Icons.chevron_left),
                            tooltip: 'Previous',
                          ),
                        ),
                      if (hasNext)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: _busy ? null : _next,
                            icon: const Icon(Icons.chevron_right),
                            tooltip: 'Next',
                          ),
                        ),
                      if (image.isPrimary)
                        Positioned(
                          top: AppSpacing.sm,
                          left: AppSpacing.sm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Primary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (_busy)
                        const ColoredBox(
                          color: Color(0x66FFFFFF),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.end,
                children: [
                  if (!image.isPrimary)
                    OutlinedButton(
                      onPressed: _busy ? null : _setPrimary,
                      child: const Text('Set as Primary'),
                    ),
                  OutlinedButton(
                    onPressed: _busy ? null : _replace,
                    child: const Text('Replace Image'),
                  ),
                  OutlinedButton(
                    onPressed: _busy ? null : _delete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Delete Image'),
                  ),
                  FilledButton(
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
