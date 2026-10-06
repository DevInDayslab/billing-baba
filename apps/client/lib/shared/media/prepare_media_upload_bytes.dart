import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

/// Downscales large images before upload so PUT requests stay small/fast.
///
/// Rack/item photos are normalized to JPEG when re-encoded. Keeps original bytes
/// when already small, or when encoding would grow size.
Future<({Uint8List bytes, String mimeType})> prepareMediaUploadBytes({
  required Uint8List bytes,
  required String mimeType,
  int maxSide = 1280,
  int skipBelowBytes = 350 * 1024,
  int jpegQuality = 88,
}) async {
  final preferJpeg =
      mimeType.toLowerCase().contains('jpeg') ||
      mimeType.toLowerCase().contains('jpg');

  if (bytes.lengthInBytes <= skipBelowBytes && !preferJpeg) {
    return (bytes: bytes, mimeType: mimeType);
  }

  try {
    final probe = await ui.instantiateImageCodec(bytes);
    final probeFrame = await probe.getNextFrame();
    final original = probeFrame.image;
    final width = original.width;
    final height = original.height;
    original.dispose();

    final needsResize = width > maxSide || height > maxSide;
    if (!needsResize && bytes.lengthInBytes <= skipBelowBytes) {
      if (preferJpeg && mimeType != 'image/jpeg') {
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final jpg = Uint8List.fromList(
            img.encodeJpg(decoded, quality: jpegQuality),
          );
          if (jpg.lengthInBytes <= bytes.lengthInBytes) {
            return (bytes: jpg, mimeType: 'image/jpeg');
          }
        }
      }
      return (bytes: bytes, mimeType: preferJpeg ? 'image/jpeg' : mimeType);
    }

    final targetWidth = width >= height ? maxSide : null;
    final targetHeight = height > width ? maxSide : null;
    final scaled = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
    final frame = await scaled.getNextFrame();
    final image = frame.image;
    final pngEncoded = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (pngEncoded == null) {
      return (bytes: bytes, mimeType: mimeType);
    }

    final pngBytes = pngEncoded.buffer.asUint8List();
    final decoded = img.decodeImage(pngBytes);
    if (decoded == null) {
      return (bytes: bytes, mimeType: mimeType);
    }

    if (preferJpeg) {
      final jpg = Uint8List.fromList(
        img.encodeJpg(decoded, quality: jpegQuality),
      );
      if (jpg.lengthInBytes >= bytes.lengthInBytes &&
          bytes.lengthInBytes <= skipBelowBytes) {
        return (bytes: bytes, mimeType: 'image/jpeg');
      }
      return (bytes: jpg, mimeType: 'image/jpeg');
    }

    if (pngBytes.lengthInBytes >= bytes.lengthInBytes) {
      return (bytes: bytes, mimeType: mimeType);
    }
    return (bytes: pngBytes, mimeType: 'image/png');
  } on Object {
    return (bytes: bytes, mimeType: preferJpeg ? 'image/jpeg' : mimeType);
  }
}
