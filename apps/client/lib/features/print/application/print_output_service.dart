import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Native print, preview, share, and save for generated PDF bytes.
class PrintOutputService {
  Future<void> preview({
    required BuildContext context,
    required Uint8List bytes,
    String name = 'document',
  }) async {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: name,
    );
  }

  Future<void> print({
    required Uint8List bytes,
    String name = 'document',
  }) async {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: name,
    );
  }

  Future<void> share({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: filename);
      return;
    }

    final directory = await getTemporaryDirectory();
    final safeName = filename.endsWith('.pdf') ? filename : '$filename.pdf';
    final file = File('${directory.path}/$safeName');
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
      ),
    );
  }

  Future<String?> save({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: filename);
      return null;
    }

    final directory = await _resolveSaveDirectory();
    final safeName = filename.endsWith('.pdf') ? filename : '$filename.pdf';
    final file = File('${directory.path}/$safeName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<Directory> _resolveSaveDirectory() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    }
    return getApplicationDocumentsDirectory();
  }
}
