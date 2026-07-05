import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Bundled Inter fonts for PDF rendering (no runtime GoogleFonts).
abstract final class InvoicePdfFonts {
  static pw.Font? regular;
  static pw.Font? medium;
  static pw.Font? semiBold;
  static pw.Font? bold;
  /// Fallback for glyphs missing from Inter (e.g. ₹ U+20B9).
  static pw.Font? symbols;
  static bool _loaded = false;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;

    regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-Regular.ttf'),
    );
    medium = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-Medium.ttf'),
    );
    semiBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'),
    );
    bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Bold.ttf'));
    symbols = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    _loaded = true;
  }

  static pw.TextStyle style({
    double fontSize = 10,
    pw.FontWeight fontWeight = pw.FontWeight.normal,
    PdfColor? color,
  }) {
    final resolved = switch (fontWeight) {
      pw.FontWeight.bold => bold ?? regular,
      _ => semiBold ?? medium ?? regular,
    };

    return pw.TextStyle(
      font: resolved,
      fontSize: fontSize,
      color: color ?? PdfColors.black,
      fontFallback: symbols != null ? [symbols!] : const [],
    );
  }
}
