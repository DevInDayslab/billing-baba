import 'dart:typed_data';

import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/invoice_preview_widget.dart';
import 'package:billing_baba/features/settings/services/invoice_pdf_builder.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;

typedef PrintSettingsUpdater = PrintSettings Function(PrintSettings current);

/// Builds invoice PDF bytes using the app-wide [PrintSettings].
abstract final class InvoicePrintDocumentService {
  static Future<pw.Document> buildDocument({
    required PrintSettings settings,
    required BusinessProfileModel business,
    required InvoicePreviewData preview,
    Uint8List? logoBytes,
  }) {
    final invoice = InvoiceData(
      invoiceNo: preview.invoiceNumber,
      date: preview.date,
      customerName: preview.customerName,
      items: preview.items
          .map(
            (item) => InvoiceLineData(
              name: item.name,
              qty: item.qty,
              rate: item.rate,
              amount: item.amount,
            ),
          )
          .toList(),
      subtotal: preview.subtotal,
      tax: preview.tax,
      total: preview.total,
      logoBytes: logoBytes,
    );

    return InvoicePdfBuilder(
      settings: settings,
      business: business,
      invoice: invoice,
    ).build();
  }

  static Future<Uint8List> buildBytesFromPrintableDocument({
    required PrintSettings settings,
    required PrintableDocument document,
  }) async {
    final invoice = invoiceDataFromDocument(document, settings);
    final doc = await InvoicePdfBuilder(
      settings: settings,
      business: document.company.profile,
      invoice: invoice,
    ).build();
    return doc.save();
  }

  static InvoiceData invoiceDataFromDocument(
    PrintableDocument document,
    PrintSettings settings,
  ) {
    final date =
        DateTime.tryParse(document.metadata.documentDate) ?? DateTime.now();

    return InvoiceData(
      invoiceNo: document.metadata.displayNumber,
      date: date,
      customerName: document.party?.dto.name,
      items: [
        for (final line in document.lines)
          InvoiceLineData(
            name: line.displayName,
            qty: double.tryParse(line.line.quantity) ?? 0,
            rate: double.tryParse(line.line.unitPrice) ?? 0,
            amount: double.tryParse(line.line.lineTotal) ?? 0,
          ),
      ],
      subtotal: double.tryParse(document.totals.subtotal) ?? 0,
      tax: double.tryParse(document.totals.taxAmount) ?? 0,
      total: double.tryParse(document.totals.totalAmount) ?? 0,
      logoBytes: settings.printCompanyLogo ? document.assets.logoBytes : null,
    );
  }

  static Future<Uint8List> buildBytesFromPosSale({
    required PrintSettings settings,
    required BusinessProfileModel business,
    required PosSale sale,
    required WidgetRef ref,
  }) async {
    final preview = InvoicePreviewData.fromSources(
      profile: business,
      sale: sale,
    );
    final logoBytes = await _resolveLogoBytes(
      settings: settings,
      logoUrl: preview.logoUrl,
      ref: ref,
    );

    final doc = await buildDocument(
      settings: settings.copyWith(printerType: PrinterType.thermal),
      business: business,
      preview: preview,
      logoBytes: logoBytes,
    );
    return doc.save();
  }

  static Future<Uint8List?> _resolveLogoBytes({
    required PrintSettings settings,
    required String? logoUrl,
    required WidgetRef ref,
  }) async {
    if (!settings.printCompanyLogo || logoUrl == null) return null;

    try {
      final imageService = ref.read(imageServiceProvider);
      return imageService.getBytes(logoUrl);
    } on Object {
      return null;
    }
  }
}
