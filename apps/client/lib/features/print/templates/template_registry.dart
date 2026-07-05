import 'package:billing_baba/features/print/application/print_exception.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';
import 'package:billing_baba/features/print/templates/a4_gst_invoice_template.dart';
import 'package:billing_baba/features/print/templates/placeholder_print_template.dart';
import 'package:billing_baba/features/print/templates/print_template.dart';

class TemplateRegistry {
  TemplateRegistry({List<PrintTemplate>? templates})
    : _templates = templates ?? [A4GstInvoiceTemplate(), PlaceholderPrintTemplate()];

  final List<PrintTemplate> _templates;

  PrintTemplate resolve(PrintableDocumentKind kind) {
    for (final template in _templates) {
      if (template.supports(kind)) {
        return template;
      }
    }
    throw PrintException(
      'No print template registered for ${kind.label}',
    );
  }
}
