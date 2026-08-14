import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Rotates image bytes clockwise by [quarterTurns] (1 = 90°).
Uint8List rotateImageQuarterTurns(Uint8List bytes, int quarterTurns) {
  if (quarterTurns == 0) return bytes;

  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  final rotated = img.copyRotate(
    decoded,
    angle: quarterTurns * 90,
  );
  return Uint8List.fromList(img.encodeJpg(rotated, quality: 92));
}
