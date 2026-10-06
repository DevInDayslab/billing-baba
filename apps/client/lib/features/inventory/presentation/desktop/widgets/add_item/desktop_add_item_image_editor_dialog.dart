import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_item_image_utils.dart';
import 'package:billing_baba/shared/media/pick_media_image.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _dialogWidth = 920.0;
const _dialogHeight = 580.0;
const _sidebarWidth = 88.0;
const _thumbSize = 64.0;

sealed class ItemImageEditorDialogResult {
  const ItemImageEditorDialogResult();
}

final class ItemImageEditorSaved extends ItemImageEditorDialogResult {
  const ItemImageEditorSaved(this.images);

  final List<Uint8List> images;
}

final class ItemImageEditorRemoved extends ItemImageEditorDialogResult {
  const ItemImageEditorRemoved();
}

/// Vyapar-style crop dialog — thumbnail rail, free crop, rotate/zoom, backend-ready output.
Future<ItemImageEditorDialogResult?> showDesktopAddItemImageEditorDialog(
  BuildContext context, {
  required Uint8List initialBytes,
  required int maxNewImages,
}) {
  return showDialog<ItemImageEditorDialogResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => DesktopAddItemImageEditorDialog(
      initialBytes: initialBytes,
      maxNewImages: maxNewImages,
    ),
  );
}

class DesktopAddItemImageEditorDialog extends StatefulWidget {
  const DesktopAddItemImageEditorDialog({
    required this.initialBytes,
    required this.maxNewImages,
    super.key,
  });

  final Uint8List initialBytes;
  final int maxNewImages;

  @override
  State<DesktopAddItemImageEditorDialog> createState() =>
      _DesktopAddItemImageEditorDialogState();
}

class _DesktopAddItemImageEditorDialogState
    extends State<DesktopAddItemImageEditorDialog> {
  final _cropController = CropController();
  final _completed = <Uint8List>[];
  late Uint8List _currentBytes;
  var _isCropping = false;
  Completer<Uint8List?>? _pendingCropCompleter;
  var _cropKey = 0;

  @override
  void initState() {
    super.initState();
    _currentBytes = widget.initialBytes;
  }

  int get _totalQueued => _completed.length + 1;

  bool get _canAddMore => _totalQueued < widget.maxNewImages;

  Future<Uint8List?> _cropCurrent() async {
    if (_isCropping) return null;
    setState(() => _isCropping = true);

    final completer = Completer<Uint8List?>();
    _pendingCropCompleter = completer;
    _cropController.crop();

    final cropped = await completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () => null,
    );
    _pendingCropCompleter = null;

    if (mounted) {
      setState(() => _isCropping = false);
    }
    return cropped;
  }

  void _handleCropped(CropResult result) {
    final completer = _pendingCropCompleter;
    if (completer == null || completer.isCompleted) return;

    switch (result) {
      case CropSuccess(:final croppedImage):
        completer.complete(croppedImage);
      case CropFailure():
        completer.complete(null);
    }
  }

  void _reloadCropSurface(Uint8List bytes) {
    setState(() {
      _currentBytes = bytes;
      _cropKey++;
    });
    _cropController.image = bytes;
  }

  void _rotateLeft() {
    _reloadCropSurface(rotateImageQuarterTurns(_currentBytes, -1));
  }

  void _rotateRight() {
    _reloadCropSurface(rotateImageQuarterTurns(_currentBytes, 1));
  }

  void _zoomIn() {
    _reloadCropSurface(scaleImageBytes(_currentBytes, 1.12));
  }

  void _zoomOut() {
    _reloadCropSurface(scaleImageBytes(_currentBytes, 0.88));
  }

  Future<void> _replaceImage() async {
    if (_isCropping) return;
    final picked = await pickMediaImageBytes(context: context);
    if (picked == null || !mounted) return;
    _reloadCropSurface(picked.bytes);
  }

  Future<void> _addAnotherImage() async {
    if (!_canAddMore || _isCropping) return;

    final cropped = await _cropCurrent();
    if (!mounted) return;
    if (cropped == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not crop image. Try again.')),
      );
      return;
    }

    setState(() => _completed.add(cropped));

    final picked = await pickMediaImageBytes(context: context);
    if (!mounted) return;
    if (picked == null) return;
    _reloadCropSurface(picked.bytes);
  }

  Future<void> _saveAndClose() async {
    if (_isCropping) return;

    final cropped = await _cropCurrent();
    if (!mounted) return;
    if (cropped == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not crop image. Try again.')),
      );
      return;
    }

    final results = [..._completed, cropped];
    Navigator.of(context).pop(ItemImageEditorSaved(results));
  }

  Future<void> _removeImage() async {
    if (_isCropping) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Image'),
        content: const Text(
          'Remove this image? It will not be added to the item.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    if (_completed.isEmpty) {
      Navigator.of(context).pop(const ItemImageEditorRemoved());
      return;
    }

    Navigator.of(
      context,
    ).pop(ItemImageEditorSaved(List<Uint8List>.from(_completed)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: _dialogWidth,
        height: _dialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSidebar(),
                  Expanded(child: _buildCropCanvas()),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildToolbar(),
            const Divider(height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Add Item Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: _isCropping ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 22),
            color: AppColors.textSecondary,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return SizedBox(
      width: _sidebarWidth,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Color(0xFFE8E8E8))),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          children: [
            for (var i = 0; i < _completed.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SidebarThumb(bytes: _completed[i], selected: false),
              ),
            _SidebarThumb(bytes: _currentBytes, selected: true),
            if (_canAddMore) ...[
              const SizedBox(height: 6),
              Material(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: InkWell(
                  onTap: _isCropping
                      ? null
                      : () => unawaited(_addAnotherImage()),
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: _thumbSize,
                    height: _thumbSize,
                    child: Icon(
                      Icons.add,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCropCanvas() {
    return ColoredBox(
      color: const Color(0xFFF0F0F0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Crop(
            key: ValueKey(_cropKey),
            image: _currentBytes,
            controller: _cropController,
            initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
              size: 0.85,
            ),
            baseColor: const Color(0xFFD8D8D8),
            maskColor: Colors.black.withValues(alpha: 0.45),
            onCropped: _handleCropped,
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ToolButton(
            icon: Icons.rotate_left,
            label: 'Rotate Left',
            onPressed: _isCropping ? null : _rotateLeft,
          ),
          const SizedBox(width: 28),
          _ToolButton(
            icon: Icons.rotate_right,
            label: 'Rotate Right',
            onPressed: _isCropping ? null : _rotateRight,
          ),
          const SizedBox(width: 28),
          _ToolButton(
            icon: LucideIcons.zoomIn,
            label: 'Zoom In',
            onPressed: _isCropping ? null : _zoomIn,
          ),
          const SizedBox(width: 28),
          _ToolButton(
            icon: LucideIcons.zoomOut,
            label: 'Zoom Out',
            onPressed: _isCropping ? null : _zoomOut,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _isCropping ? null : () => unawaited(_removeImage()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Remove Image',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: _isCropping ? null : () => unawaited(_replaceImage()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Replace Image',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _isCropping ? null : () => unawaited(_saveAndClose()),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            child: _isCropping
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save & Close',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SidebarThumb extends StatelessWidget {
  const _SidebarThumb({
    required this.bytes,
    required this.selected,
  });

  final Uint8List bytes;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
          width: selected ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.memory(
          bytes,
          width: _thumbSize,
          height: _thumbSize,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.textPrimary),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
