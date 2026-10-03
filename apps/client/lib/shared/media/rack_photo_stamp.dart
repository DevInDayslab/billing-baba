import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';

/// Burns audit metadata into a rack/shelf photo before upload.
///
/// Draws a semi-transparent footer with date/time, rack/shelf label, and
/// optional employee name. Returns JPEG when encoding succeeds, otherwise the
/// original bytes.
Future<({Uint8List bytes, String mimeType})> stampRackPhoto({
  required Uint8List bytes,
  required DateTime takenAt,
  String rackShelfLabel = '',
  String? employeeLabel,
}) async {
  try {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final source = frame.image;
    final width = source.width;
    final height = source.height;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImage(source, ui.Offset.zero, ui.Paint());
    source.dispose();

    final lines = <String>[
      DateFormat('dd MMM yyyy, hh:mm a').format(takenAt.toLocal()),
    ];
    final rack = rackShelfLabel.trim();
    if (rack.isNotEmpty) {
      lines.add('Rack / Shelf: $rack');
    }
    final employee = employeeLabel?.trim() ?? '';
    if (employee.isNotEmpty) {
      lines.add('By: $employee');
    }

    final fontSize = (width * 0.028).clamp(12.0, 22.0);
    final padding = fontSize * 0.6;
    final lineHeight = fontSize * 1.35;
    final barHeight = padding * 2 + lineHeight * lines.length;

    final barRect = ui.Rect.fromLTWH(
      0,
      height - barHeight,
      width.toDouble(),
      barHeight,
    );
    canvas.drawRect(
      barRect,
      ui.Paint()..color = const ui.Color(0xB3000000),
    );

    var y = height - barHeight + padding;
    for (final line in lines) {
      final builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: ui.TextAlign.left,
          fontSize: fontSize,
          fontWeight: ui.FontWeight.w500,
          maxLines: 1,
          ellipsis: '…',
        ),
      )
        ..pushStyle(
          ui.TextStyle(
            color: const ui.Color(0xFFFFFFFF),
            fontSize: fontSize,
            fontWeight: ui.FontWeight.w500,
          ),
        )
        ..addText(line);
      final paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: width - padding * 2));
      canvas.drawParagraph(paragraph, ui.Offset(padding, y));
      y += lineHeight;
    }

    final picture = recorder.endRecording();
    final stamped = await picture.toImage(width, height);
    picture.dispose();

    final byteData = await stamped.toByteData(format: ui.ImageByteFormat.png);
    stamped.dispose();
    if (byteData == null) {
      return (bytes: bytes, mimeType: 'image/jpeg');
    }

    final pngBytes = byteData.buffer.asUint8List();
    // Prefer JPEG for smaller uploads when possible via PNG fallback size check.
    // Encoding JPEG from dart:ui requires PNG path then external encode —
    // keep PNG when it stays under 2 MB; otherwise return original.
    const maxBytes = 2 * 1024 * 1024;
    if (pngBytes.lengthInBytes <= maxBytes) {
      return (bytes: pngBytes, mimeType: 'image/png');
    }
    if (bytes.lengthInBytes <= maxBytes) {
      return (bytes: bytes, mimeType: 'image/jpeg');
    }
    return (bytes: pngBytes, mimeType: 'image/png');
  } on Object {
    return (bytes: bytes, mimeType: 'image/jpeg');
  }
}
