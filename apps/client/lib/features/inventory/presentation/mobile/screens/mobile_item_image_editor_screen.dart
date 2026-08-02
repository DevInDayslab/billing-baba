import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_item_image_utils.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

/// Full-screen 1:1 crop editor with rotate controls.
class MobileItemImageEditorScreen extends StatefulWidget {
  const MobileItemImageEditorScreen({
    required this.imageBytes,
    super.key,
  });

  final Uint8List imageBytes;

  @override
  State<MobileItemImageEditorScreen> createState() =>
      _MobileItemImageEditorScreenState();
}

class _MobileItemImageEditorScreenState
    extends State<MobileItemImageEditorScreen> {
  final _cropController = CropController();
  late Uint8List _imageBytes;
  var _isCropping = false;
  Completer<Uint8List?>? _pendingCropCompleter;

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.imageBytes;
  }

  void _rotate() {
    setState(() {
      _imageBytes = rotateImageQuarterTurns(_imageBytes, 1);
    });
    _cropController.image = _imageBytes;
  }

  Future<void> _applyCrop() async {
    if (_isCropping) return;
    setState(() => _isCropping = true);

    final completer = Completer<Uint8List?>();
    _pendingCropCompleter = completer;
    _cropController.crop();

    final cropped = await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
    _pendingCropCompleter = null;

    if (!mounted) return;

    if (cropped != null) {
      Navigator.of(context, rootNavigator: true).pop(cropped);
      return;
    }

    setState(() => _isCropping = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _isCropping
              ? null
              : () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        title: const Text('Edit Photo'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isCropping ? null : _applyCrop,
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
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: _imageBytes,
              controller: _cropController,
              aspectRatio: 1,
              initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                size: 0.9,
                aspectRatio: 1,
              ),
              baseColor: Colors.black,
              maskColor: Colors.black.withValues(alpha: 0.55),
              onCropped: _handleCropped,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _EditorActionButton(
                    icon: Icons.rotate_right_rounded,
                    label: 'Rotate',
                    onPressed: _isCropping ? null : _rotate,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _EditorActionButton(
                    icon: Icons.crop_rounded,
                    label: 'Crop 1:1',
                    onPressed: _isCropping ? null : _applyCrop,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorActionButton extends StatelessWidget {
  const _EditorActionButton({
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
      borderRadius: AppRadius.mdBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
