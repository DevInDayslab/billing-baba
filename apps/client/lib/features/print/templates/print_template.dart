import 'dart:typed_data';

import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';

/// Renders a [PrintableDocument] into PDF bytes.
abstract class PrintTemplate {
  String get id;

  bool supports(PrintableDocumentKind kind);

  Future<Uint8List> render(PrintableDocument document);
}
