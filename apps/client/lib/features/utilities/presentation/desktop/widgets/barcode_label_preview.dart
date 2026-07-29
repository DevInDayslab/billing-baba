import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Live Code128 preview for the barcode generator form.
class BarcodeLabelPreview extends StatelessWidget {
  const BarcodeLabelPreview({
    required this.header,
    required this.itemCode,
    required this.line1,
    required this.line2,
    required this.line3,
    required this.line4,
    this.showBarcode = true,
    super.key,
  });

  final String header;
  final String itemCode;
  final String line1;
  final String line2;
  final String line3;
  final String line4;
  final bool showBarcode;

  static final Barcode _barcode = Barcode.code128();

  @override
  Widget build(BuildContext context) {
    final code = itemCode.trim();
    final displayHeader = header.trim().isEmpty ? 'Header' : header.trim();
    final displayCode = code.isEmpty ? 'Item Code' : code;
    final displayLine1 = line1.trim().isEmpty ? 'Line 1' : line1.trim();
    final displayLine2 = line2.trim().isEmpty ? 'Line 2' : line2.trim();
    final displayLine3 = line3.trim().isEmpty ? 'Line 3' : line3.trim();
    final displayLine4 = line4.trim().isEmpty ? 'Line 4' : line4.trim();
    final isPlaceholder = code.isEmpty;

    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayHeader,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: isPlaceholder && header.trim().isEmpty
                  ? const Color(0xFF9E9E9E)
                  : const Color(0xFF424242),
            ),
          ),
          if (showBarcode) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: code.isEmpty
                  ? const _BarcodePlaceholder()
                  : SvgPicture.string(
                      _barcode.toSvg(
                        code,
                        width: 128,
                        height: 52,
                        drawText: false,
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              displayCode,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isPlaceholder
                    ? const Color(0xFF9E9E9E)
                    : const Color(0xFF212121),
              ),
            ),
          ],
          const SizedBox(height: 4),
          _PreviewLine(text: displayLine1, isPlaceholder: line1.trim().isEmpty),
          _PreviewLine(text: displayLine2, isPlaceholder: line2.trim().isEmpty),
          _PreviewLine(text: displayLine3, isPlaceholder: line3.trim().isEmpty),
          _PreviewLine(text: displayLine4, isPlaceholder: line4.trim().isEmpty),
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({
    required this.text,
    required this.isPlaceholder,
  });

  final String text;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          color: isPlaceholder
              ? const Color(0xFFBDBDBD)
              : const Color(0xFF616161),
        ),
      ),
    );
  }
}

class _BarcodePlaceholder extends StatelessWidget {
  const _BarcodePlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarcodePlaceholderPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _BarcodePlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE0E0E0);
    const barWidth = 2.0;
    var x = 8.0;
    final heights = [0.55, 0.75, 0.45, 0.9, 0.5, 0.8, 0.4, 0.7, 0.6, 0.85];
    for (final factor in heights) {
      final barHeight = size.height * factor;
      final top = (size.height - barHeight) / 2;
      canvas.drawRect(
        Rect.fromLTWH(x, top, barWidth, barHeight),
        paint,
      );
      x += barWidth + 2;
      if (x > size.width - 8) break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
