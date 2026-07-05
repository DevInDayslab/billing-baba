import 'dart:typed_data';

/// Binary assets embedded in printable documents.
class PrintableAssets {
  const PrintableAssets({
    this.logoBytes,
    this.signatureBytes,
  });

  final Uint8List? logoBytes;
  final Uint8List? signatureBytes;
}
