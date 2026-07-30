import 'package:intl/intl.dart';

/// Filename helpers for export output.
abstract final class ExportFilename {
  static final _dateSuffix = DateFormat('yyyy-MM-dd');

  /// Sanitize a base name for use in filenames.
  static String sanitize(String name) {
    final safe = name
        .trim()
        .replaceAll(RegExp(r'[^\w\-]+'), '_')
        .replaceAll(RegExp('_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return safe.isEmpty ? 'export' : safe;
  }

  /// Build filename with optional date suffix: `Sales_2026-07-05`.
  static String build({
    required String baseName,
    required String extension,
    DateTime? date,
    bool includeDate = true,
  }) {
    final safe = sanitize(baseName);
    final ext = extension.startsWith('.') ? extension.substring(1) : extension;
    if (!includeDate) return '$safe.$ext';

    final suffix = _dateSuffix.format(date ?? DateTime.now());
    return '${safe}_$suffix.$ext';
  }
}
