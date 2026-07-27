import 'dart:typed_data';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_item_image_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
enum _ItemImageSource { gallery, camera }

/// Picks an item photo from gallery or camera, then opens the 1:1 crop editor.
Future<Uint8List?> pickMobileItemImage(BuildContext context) async {
  final source = await showMobileBottomSheet<_ItemImageSource>(
    context: context,
    useRootNavigator: false,
    title: 'Add Photo',
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SourceTile(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            subtitle: 'Select an existing photo',
            onTap: () =>
                Navigator.of(sheetContext).pop(_ItemImageSource.gallery),
          ),
          _SourceTile(
            icon: Icons.photo_camera_outlined,
            label: 'Take Photo',
            subtitle: 'Use your device camera',
            onTap: () =>
                Navigator.of(sheetContext).pop(_ItemImageSource.camera),
          ),
        ],
      );
    },
  );
  if (source == null || !context.mounted) return null;

  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: switch (source) {
      _ItemImageSource.gallery => ImageSource.gallery,
      _ItemImageSource.camera => ImageSource.camera,
    },
    imageQuality: 92,
  );
  if (picked == null || !context.mounted) return null;

  final bytes = await picked.readAsBytes();
  if (!context.mounted) return null;

  return openMobileItemImageEditor(context, imageBytes: bytes);
}

/// Opens the 1:1 crop editor for an existing item photo.
Future<Uint8List?> openMobileItemImageEditor(
  BuildContext context, {
  required Uint8List imageBytes,
}) {
  return Navigator.of(context, rootNavigator: true).push<Uint8List>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => MobileItemImageEditorScreen(imageBytes: imageBytes),
    ),
  );
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
