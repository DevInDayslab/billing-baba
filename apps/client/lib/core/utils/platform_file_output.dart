import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Platform-aware save and share for generated file bytes.
abstract final class PlatformFileOutput {
  static bool get isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Desktop: native save dialog. Returns path or null if cancelled.
  static Future<String?> saveViaDialog({
    required String filename,
    required Uint8List bytes,
  }) async {
    if (!isDesktop) return null;

    return FilePicker.saveFile(
      fileName: filename,
      bytes: bytes,
    );
  }

  /// Mobile: write to temp and open the native share sheet.
  ///
  /// Desktop sandboxes block sharing temp files, so we use the save dialog
  /// instead (user-selected path entitlement).
  static Future<void> shareFromTemp({
    required String filename,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    if (kIsWeb) return;

    final safeName = _basename(filename);

    if (isDesktop) {
      await saveViaDialog(filename: safeName, bytes: bytes);
      return;
    }

    final directory = await getTemporaryDirectory();
    final output = File('${directory.path}/$safeName');
    await output.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(output.path, mimeType: mimeType)],
      ),
    );
  }

  static String _basename(String filename) =>
      filename.split(RegExp(r'[/\\]')).last;
}
