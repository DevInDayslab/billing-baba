import 'dart:typed_data';

import 'package:billing_baba/features/print/models/pdf_page_profile.dart';

/// Pre-rendered PDF bytes shared by preview and print actions.
class PrintablePdf {
  const PrintablePdf({
    required this.bytes,
    this.name = 'document',
    this.profile = PdfPageProfile.transaction,
  });

  final Uint8List bytes;
  final String name;
  final PdfPageProfile profile;

  String get filename => name.endsWith('.pdf') ? name : '$name.pdf';
}
