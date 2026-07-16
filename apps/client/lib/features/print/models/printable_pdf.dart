import 'dart:typed_data';

/// Pre-rendered PDF bytes shared by preview and print actions.
class PrintablePdf {
  const PrintablePdf({
    required this.bytes,
    this.name = 'document',
  });

  final Uint8List bytes;
  final String name;

  String get filename => name.endsWith('.pdf') ? name : '$name.pdf';
}
