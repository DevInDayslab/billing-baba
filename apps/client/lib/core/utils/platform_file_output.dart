import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Platform-aware save and share for generated file bytes.
abstract final class PlatformFileOutput {
  static bool get isDesktop =>
      !kIsWeb &&
      (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  static bool get isMobile =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

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

  /// Write to temp directory and open the native share sheet.
  static Future<void> shareFromTemp({
    required String filename,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    if (kIsWeb) return;

    final directory = await getTemporaryDirectory();
    final output = File('${directory.path}/$filename');
    await output.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(output.path, mimeType: mimeType)],
      ),
    );
  }
}
