import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

ui.Paragraph _buildStampLine({
  required String text,
  required double maxWidth,
  required double fontSize,
}) {
  final builder = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      textAlign: ui.TextAlign.left,
      fontSize: fontSize,
      fontWeight: ui.FontWeight.w500,
      maxLines: 2,
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
    ..addText(text);
  final paragraph = builder.build()
    ..layout(ui.ParagraphConstraints(width: maxWidth));
  return paragraph;
}

/// Burns audit metadata into a rack/shelf photo before upload (device-side).
///
/// Compact bottom-right label: date/time, rack/shelf, and employee.
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
      lines.add('Rack: $rack');
    }
    final employee = employeeLabel?.trim() ?? '';
    if (employee.isNotEmpty) {
      lines.add('Updated by: $employee');
    }

    final baseFont = (width * 0.02).clamp(9.0, 13.0);
    final paddingH = baseFont * 0.5;
    final paddingV = baseFont * 0.35;
    final lineHeight = baseFont * 1.22;
    final maxTextWidth = (width * 0.5).clamp(120.0, width * 0.55);

    var contentWidth = 0.0;
    final laidOut = <ui.Paragraph>[];
    for (final line in lines) {
      final paragraph = _buildStampLine(
        text: line,
        maxWidth: maxTextWidth,
        fontSize: baseFont,
      );
      laidOut.add(paragraph);
      contentWidth = contentWidth < paragraph.maxIntrinsicWidth
          ? paragraph.maxIntrinsicWidth
          : contentWidth;
    }
    contentWidth = contentWidth.clamp(0.0, maxTextWidth);

    final panelWidth = contentWidth + paddingH * 2;
    final panelHeight = paddingV * 2 + lineHeight * lines.length;
    final margin = (width * 0.015).clamp(6.0, 12.0);
    final panelLeft = width - panelWidth - margin;
    final panelTop = height - panelHeight - margin;

    final panelRect = ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(panelLeft, panelTop, panelWidth, panelHeight),
      ui.Radius.circular(baseFont * 0.35),
    );
    canvas.drawRRect(
      panelRect,
      ui.Paint()..color = const ui.Color(0x99000000),
    );

    var y = panelTop + paddingV;
    for (final paragraph in laidOut) {
      canvas.drawParagraph(paragraph, ui.Offset(panelLeft + paddingH, y));
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
    const maxBytes = 2 * 1024 * 1024;

    final decoded = img.decodeImage(pngBytes);
    if (decoded != null) {
      final jpg = Uint8List.fromList(img.encodeJpg(decoded, quality: 88));
      if (jpg.lengthInBytes <= maxBytes) {
        return (bytes: jpg, mimeType: 'image/jpeg');
      }
    }

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
