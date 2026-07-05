/// Document metadata for printable output.
class PrintableMetadata {
  const PrintableMetadata({
    required this.documentNumber,
    required this.documentSeries,
    required this.documentDate,
    required this.status,
    this.apiDocumentType,
    this.notes,
    this.dueDate,
    this.supplierInvoiceNumber,
    this.isGstFormal = false,
    this.paymentMode,
    this.paymentReference,
    this.paymentDirection,
  });

  final String? documentNumber;
  final String? documentSeries;
  final String documentDate;
  final String status;
  final String? apiDocumentType;
  final String? notes;
  final String? dueDate;
  final String? supplierInvoiceNumber;
  final bool isGstFormal;
  final String? paymentMode;
  final String? paymentReference;
  final String? paymentDirection;

  String get displayNumber => documentNumber ?? 'Draft';
}
