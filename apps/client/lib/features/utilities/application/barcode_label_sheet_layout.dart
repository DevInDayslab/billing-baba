import 'dart:math' as math;

import 'package:pdf/pdf.dart';

/// Computes how many fixed-size labels fit on a page with minimal margins.
class BarcodeLabelSheetLayout {
  const BarcodeLabelSheetLayout({
    required this.pageFormat,
    required this.labelWidthMm,
    required this.labelHeightMm,
    this.marginMm = 2,
    this.gapMm = 1,
  });

  final PdfPageFormat pageFormat;
  final double labelWidthMm;
  final double labelHeightMm;
  final double marginMm;
  final double gapMm;

  double get pageWidthMm => pageFormat.width / PdfPageFormat.mm;
  double get pageHeightMm => pageFormat.height / PdfPageFormat.mm;

  double get _usableWidthMm => pageWidthMm - (marginMm * 2);
  double get _usableHeightMm => pageHeightMm - (marginMm * 2);

  int get columns => math.max(
    1,
    ((_usableWidthMm + gapMm) / (labelWidthMm + gapMm)).floor(),
  );

  int get rows => math.max(
    1,
    ((_usableHeightMm + gapMm) / (labelHeightMm + gapMm)).floor(),
  );

  int get labelsPerPage => columns * rows;

  double get gridWidthMm =>
      (columns * labelWidthMm) + (math.max(0, columns - 1) * gapMm);

  double get gridHeightMm =>
      (rows * labelHeightMm) + (math.max(0, rows - 1) * gapMm);

  double get startXMm =>
      marginMm + math.max(0, (_usableWidthMm - gridWidthMm) / 2);

  double get startYMm =>
      marginMm + math.max(0, (_usableHeightMm - gridHeightMm) / 2);

  double labelLeftMm(int column) => startXMm + column * (labelWidthMm + gapMm);

  double labelTopMm(int row) => startYMm + row * (labelHeightMm + gapMm);
}
