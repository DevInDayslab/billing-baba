import 'dart:typed_data';

import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_item_image_editor_screen.dart';
import 'package:billing_baba/features/inventory/presentation/shared/item_image_pick_crop.dart';
import 'package:flutter/material.dart';

/// Picks an item photo from the gallery (no camera), then opens the crop editor.
Future<Uint8List?> pickMobileItemImage(BuildContext context) async {
  final bytes = await pickRawItemImageBytes(context);
  if (bytes == null || !context.mounted) return null;

  return openMobileItemImageEditor(context, imageBytes: bytes);
}

/// Opens the crop editor for an existing item photo.
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
