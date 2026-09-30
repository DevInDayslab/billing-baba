import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Rotates image bytes clockwise by [quarterTurns] (1 = 90°).
Uint8List rotateImageQuarterTurns(Uint8List bytes, int quarterTurns) {
  if (quarterTurns == 0) return bytes;

  final normalized = quarterTurns % 4;
  final turns = normalized < 0 ? normalized + 4 : normalized;
  if (turns == 0) return bytes;

  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  final rotated = img.copyRotate(
    decoded,
    angle: turns * 90,
  );
  return Uint8List.fromList(img.encodeJpg(rotated, quality: 92));
}

/// Scales image dimensions by [factor] (values > 1 zoom in).
Uint8List scaleImageBytes(Uint8List bytes, double factor) {
  if (factor == 1) return bytes;

  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  final width = (decoded.width * factor).round().clamp(32, 12000);
  final height = (decoded.height * factor).round().clamp(32, 12000);
  final resized = img.copyResize(decoded, width: width, height: height);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 92));
}
