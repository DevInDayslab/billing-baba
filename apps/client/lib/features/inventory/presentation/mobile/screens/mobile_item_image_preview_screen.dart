import 'dart:typed_data';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_item_image_editor_screen.dart';
import 'package:flutter/material.dart';

/// Result of the mobile item image preview flow.
sealed class MobileItemImagePreviewOutcome {}

/// User removed the photo from the add-item form.
final class MobileItemImagePreviewDeleted
    extends MobileItemImagePreviewOutcome {}

/// User cropped or otherwise updated the photo.
final class MobileItemImagePreviewUpdated
    extends MobileItemImagePreviewOutcome {
  MobileItemImagePreviewUpdated(this.bytes);

  final Uint8List bytes;
}

/// Full-screen preview with delete and edit actions for a pending item photo.
class MobileItemImagePreviewScreen extends StatelessWidget {
  const MobileItemImagePreviewScreen({
    required this.imageBytes,
    super.key,
  });

  final Uint8List imageBytes;

  void _popWithOutcome(
    BuildContext context,
    MobileItemImagePreviewOutcome outcome,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(outcome);
    });
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Photo'),
          content: const Text(
            'Remove this photo from the item? You can add a new one later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    _popWithOutcome(context, MobileItemImagePreviewDeleted());
  }

  Future<void> _edit(BuildContext context) async {
    final cropped = await Navigator.of(context, rootNavigator: true)
        .push<Uint8List>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => MobileItemImageEditorScreen(imageBytes: imageBytes),
          ),
        );
    if (cropped == null || !context.mounted) return;
    _popWithOutcome(context, MobileItemImagePreviewUpdated(cropped));
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
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        title: const Text('Photo'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
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
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _delete(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _edit(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      icon: const Icon(Icons.crop_rounded),
                      label: const Text('Edit'),
                    ),
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

/// Opens the item photo preview. Returns `null` when dismissed without changes.
Future<MobileItemImagePreviewOutcome?> openMobileItemImagePreview(
  BuildContext context, {
  required Uint8List imageBytes,
}) {
  return Navigator.of(
    context,
    rootNavigator: true,
  ).push<MobileItemImagePreviewOutcome>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => MobileItemImagePreviewScreen(imageBytes: imageBytes),
    ),
  );
}
