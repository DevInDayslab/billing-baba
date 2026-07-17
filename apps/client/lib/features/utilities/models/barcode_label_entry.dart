import 'package:pdf/pdf.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// A queued row in the barcode generator table.
class BarcodeLabelEntry {
  BarcodeLabelEntry({
    String? id,
    required this.itemName,
    this.itemId,
    required this.itemCode,
    required this.labelCount,
    this.header = '',
    this.line1 = '',
    this.line2 = '',
    this.line3 = '',
    this.line4 = '',
  }) : id = id ?? _uuid.v4();

  final String id;
  final String itemName;
  final String? itemId;
  final String itemCode;
  final int labelCount;
  final String header;
  final String line1;
  final String line2;
  final String line3;
  final String line4;

  BarcodeLabelEntry copyWith({
    String? itemName,
    String? itemId,
    String? itemCode,
    int? labelCount,
    String? header,
    String? line1,
    String? line2,
    String? line3,
    String? line4,
  }) {
    return BarcodeLabelEntry(
      id: id,
      itemName: itemName ?? this.itemName,
      itemId: itemId ?? this.itemId,
      itemCode: itemCode ?? this.itemCode,
      labelCount: labelCount ?? this.labelCount,
      header: header ?? this.header,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      line3: line3 ?? this.line3,
      line4: line4 ?? this.line4,
    );
  }
}

enum BarcodeLabelLayout {
  label50x25A4(
    'A4 · 50×25mm',
    widthMm: 50,
    heightMm: 25,
    pageFormat: PdfPageFormat.a4,
  );

  const BarcodeLabelLayout(
    this.label, {
    required this.widthMm,
    required this.heightMm,
    required this.pageFormat,
  });

  final String label;
  final double widthMm;
  final double heightMm;
  final PdfPageFormat pageFormat;

  /// Backward-compatible alias for the default sheet layout.
  static const BarcodeLabelLayout twoLabels50x25 = label50x25A4;
}

enum BarcodePrinterOption {
  labelPrinter('Label Printer');

  const BarcodePrinterOption(this.label);

  final String label;
}
