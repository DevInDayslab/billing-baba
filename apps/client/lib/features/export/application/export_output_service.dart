import 'package:billing_baba/features/export/application/export_exception.dart';
import 'package:billing_baba/features/export/models/export_file.dart';
import 'package:billing_baba/shared/utils/platform_file_output.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Save and share generated export files.
class ExportOutputService {
  Future<String?> save(ExportFile file) async {
    if (kIsWeb) {
      await _copyToClipboard(file);
      return null;
    }

    if (PlatformFileOutput.isMobile) {
      await share(file);
      return null;
    }

    try {
      final path = await PlatformFileOutput.saveViaDialog(
        filename: file.filename,
        bytes: file.bytes,
      );
      if (path != null) return path;
      return null;
    } on Object {
      await share(file);
      return null;
    }
  }

  Future<void> share(ExportFile file) async {
    if (kIsWeb) {
      await _copyToClipboard(file);
      return;
    }

    try {
      await PlatformFileOutput.shareFromTemp(
        filename: file.filename,
        bytes: file.bytes,
        mimeType: file.mimeType,
      );
    } on Object catch (error) {
      throw ExportException(
        error.toString().contains('Operation not permitted') ||
                error.toString().contains('Permission denied')
            ? 'Permission denied. Please choose another save location.'
            : 'Unable to save the exported file.',
      );
    }
  }

  Future<void> _copyToClipboard(ExportFile file) async {
    final text = String.fromCharCodes(file.bytes);
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Desktop: save dialog. Mobile/web: share sheet or clipboard.
  Future<String?> exportAndNotify({
    required ExportFile file,
    bool preferSaveOnDesktop = true,
  }) async {
    if (kIsWeb) {
      await _copyToClipboard(file);
      return null;
    }

    if (preferSaveOnDesktop && PlatformFileOutput.isDesktop) {
      try {
        final path = await PlatformFileOutput.saveViaDialog(
          filename: file.filename,
          bytes: file.bytes,
        );
        if (path != null) return path;
        return null;
      } on Object {
        await share(file);
        return null;
      }
    }

    await share(file);
    return null;
  }
}
