import 'dart:typed_data';

import 'package:billing_baba/features/export/models/export_format.dart';

/// Generated export file ready for save or share.
class ExportFile {
  const ExportFile({
    required this.bytes,
    required this.filename,
    required this.format,
  });

  final Uint8List bytes;
  final String filename;
  final ExportFormat format;

  String get mimeType => format.mimeType;
}
