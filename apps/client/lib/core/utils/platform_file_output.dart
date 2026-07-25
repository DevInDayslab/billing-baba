import 'dart:io';

import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/features/print/application/print_exception.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Platform-aware save, share, and open for generated file bytes.
abstract final class PlatformFileOutput {
  static bool get isDesktop => !kIsWeb && AppPlatform.current.isDesktop;

  static bool get isMobile => !kIsWeb && AppPlatform.current.isMobile;

  /// Desktop: native save dialog. Returns path or null if cancelled.
  ///
  /// Pass [extension] (e.g. `pdf`, `png`) so Windows shows the correct
  /// "Save as type" filter and the saved file always has an extension.
  static Future<String?> saveViaDialog({
    required String filename,
    required Uint8List bytes,
    String? extension,
  }) async {
    if (!isDesktop) return null;

    final normalizedExt = _normalizeExtension(extension);
    final safeName = _ensureExtension(_basename(filename), normalizedExt);

    final path = await FilePicker.saveFile(
      fileName: safeName,
      bytes: bytes,
      type: normalizedExt != null ? FileType.custom : FileType.any,
      allowedExtensions: normalizedExt != null ? [normalizedExt] : null,
    );

    if (path == null) return null;

    final outputPath = _ensureExtension(path, normalizedExt);
    if (outputPath != path) {
      await File(outputPath).writeAsBytes(bytes, flush: true);
      try {
        final wrongFile = File(path);
        if (await wrongFile.exists()) {
          await wrongFile.delete();
        }
      } on Object {
        // Best-effort cleanup when the dialog saved without an extension.
      }
    }
    return outputPath;
  }

  /// Opens [bytes] with the platform default application for PDFs.
  ///
  /// On web, falls back to [Printing.sharePdf] because there is no local viewer.
  static Future<void> openInDefaultViewer({
    required Uint8List bytes,
    required String filename,
  }) async {
    final safeName = _basename(
      filename.endsWith('.pdf') ? filename : '$filename.pdf',
    );

    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: safeName);
      return;
    }

    final directory = await getTemporaryDirectory();
    final output = File('${directory.path}/$safeName');
    await output.writeAsBytes(bytes, flush: true);

    final result = await OpenFilex.open(output.path);
    if (result.type != ResultType.done) {
      throw PrintException(
        result.message.isNotEmpty
            ? result.message
            : 'Could not open the PDF preview.',
      );
    }
  }

  /// Mobile: write to temp and open the native share sheet.
  ///
  /// Desktop sandboxes block sharing temp files, so we use the save dialog
  /// instead (user-selected path entitlement).
  static Future<void> shareFromTemp({
    required String filename,
    required Uint8List bytes,
    required String mimeType,
    String? extension,
  }) async {
    if (kIsWeb) return;

    final safeName = _ensureExtension(
      _basename(filename),
      _normalizeExtension(extension) ??
          _extensionFromMimeType(mimeType),
    );

    if (isDesktop) {
      await saveViaDialog(
        filename: safeName,
        bytes: bytes,
        extension: _normalizeExtension(extension) ??
            _extensionFromMimeType(mimeType),
      );
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

  static String? _normalizeExtension(String? extension) {
    if (extension == null || extension.isEmpty) return null;
    return extension.replaceFirst('.', '').toLowerCase();
  }

  static String? _extensionFromMimeType(String mimeType) => switch (mimeType) {
        'application/pdf' => 'pdf',
        'image/png' => 'png',
        'image/jpeg' => 'jpg',
        _ => null,
      };

  static String _ensureExtension(String filename, String? extension) {
    if (extension == null) return filename;

    final lower = filename.toLowerCase();
    final suffix = '.$extension';
    if (lower.endsWith(suffix)) return filename;

    final dotIndex = filename.lastIndexOf('.');
    final stem = dotIndex > 0 ? filename.substring(0, dotIndex) : filename;
    return '$stem$suffix';
  }
}
