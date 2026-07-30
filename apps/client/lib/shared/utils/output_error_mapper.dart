import 'dart:io';

import 'package:billing_baba/features/export/application/export_exception.dart';
import 'package:billing_baba/features/print/application/print_exception.dart';
import 'package:flutter/foundation.dart';

/// Maps internal failures to user-facing print/export messages.
abstract final class OutputErrorMapper {
  static String printMessage(Object error) {
    if (error is PrintException) return error.message;
    if (_isPermissionError(error)) {
      return 'Permission denied. Please choose another save location.';
    }
    if (_isPdfGenerationError(error)) {
      return 'Unable to generate the PDF. Please try again.';
    }
    debugPrint('Print error: $error');
    return 'Print failed.';
  }

  static String exportMessage(Object error) {
    if (error is ExportException) return error.message;
    if (_isPermissionError(error)) {
      return 'Permission denied. Please choose another save location.';
    }
    if (_isExportWriteError(error)) {
      return 'Unable to save the exported file.';
    }
    debugPrint('Export error: $error');
    return 'Export failed.';
  }

  static bool _isPermissionError(Object error) {
    return error is PathAccessException ||
        error is FileSystemException ||
        error.toString().contains('Operation not permitted') ||
        error.toString().contains('Permission denied');
  }

  static bool _isPdfGenerationError(Object error) {
    final text = error.toString();
    return text.contains('package:pdf') || text.contains('Failed assertion');
  }

  static bool _isExportWriteError(Object error) {
    final text = error.toString();
    return text.contains('encode') ||
        text.contains('workbook') ||
        error is FileSystemException ||
        error is PathAccessException;
  }
}
