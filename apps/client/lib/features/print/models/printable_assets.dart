import 'dart:typed_data';

/// Binary assets embedded in printable documents.
class PrintableAssets {
  const PrintableAssets({
    this.logoBytes,
    this.signatureBytes,
    this.stampBytes,
  });

  final Uint8List? logoBytes;
  final Uint8List? signatureBytes;
  final Uint8List? stampBytes;
}
