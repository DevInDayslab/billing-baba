import 'dart:typed_data';
import 'dart:ui' as ui;

/// Downscales large images before upload so PUT requests stay small/fast.
///
/// Keeps the original bytes when already small, or when encoding would grow size.
Future<({Uint8List bytes, String mimeType})> prepareMediaUploadBytes({
  required Uint8List bytes,
  required String mimeType,
  int maxSide = 1280,
  int skipBelowBytes = 350 * 1024,
}) async {
  if (bytes.lengthInBytes <= skipBelowBytes) {
    return (bytes: bytes, mimeType: mimeType);
  }

  try {
    final probe = await ui.instantiateImageCodec(bytes);
    final probeFrame = await probe.getNextFrame();
    final original = probeFrame.image;
    final width = original.width;
    final height = original.height;
    original.dispose();

    if (width <= maxSide && height <= maxSide) {
      return (bytes: bytes, mimeType: mimeType);
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
    final encoded = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (encoded == null) {
      return (bytes: bytes, mimeType: mimeType);
    }

    final prepared = encoded.buffer.asUint8List();
    if (prepared.lengthInBytes >= bytes.lengthInBytes) {
      return (bytes: bytes, mimeType: mimeType);
    }

    return (bytes: prepared, mimeType: 'image/png');
  } on Object {
    return (bytes: bytes, mimeType: mimeType);
  }
}
