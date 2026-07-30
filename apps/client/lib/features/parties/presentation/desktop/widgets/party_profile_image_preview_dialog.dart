import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

/// Simple profile image preview with Replace / Remove / Close actions.
Future<void> showPartyProfileImagePreviewDialog({
  required BuildContext context,
  required String imageUrl,
  String? mediaAssetId,
  VoidCallback? onReplace,
  VoidCallback? onRemove,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _PartyProfileImagePreviewDialog(
      imageUrl: imageUrl,
      mediaAssetId: mediaAssetId,
      onReplace: onReplace,
      onRemove: onRemove,
    ),
  );
}

class _PartyProfileImagePreviewDialog extends StatelessWidget {
  const _PartyProfileImagePreviewDialog({
    required this.imageUrl,
    this.mediaAssetId,
    this.onReplace,
    this.onRemove,
  });

  final String imageUrl;
  final String? mediaAssetId;
  final VoidCallback? onReplace;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Close',
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: AppNetworkImage(
                  imageUrl: imageUrl,
                  sourceMediaAssetId: mediaAssetId,
                  displayContext: ImageDisplayContext.preview,
                  fit: BoxFit.contain,
                  loadWhenVisible: false,
                ),
              ),
            ),
            if (onReplace != null || onRemove != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    if (onReplace != null)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onReplace!();
                        },
                        child: const Text('Replace'),
                      ),
                    if (onRemove != null)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onRemove!();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                        child: const Text('Remove'),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
