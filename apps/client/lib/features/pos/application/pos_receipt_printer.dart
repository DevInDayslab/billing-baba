import 'dart:typed_data';

import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/print/application/print_output_service.dart';
import 'package:billing_baba/features/print/application/print_providers.dart';
import 'package:billing_baba/features/settings/application/print_settings_provider.dart';
import 'package:billing_baba/features/settings/services/invoice_print_document_service.dart';
import 'package:billing_baba/features/settings/utils/thermal_pdf_page_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_receipt_printer.g.dart';

/// Draft bill PDF for print/share before checkout.
PosSale posPreviewSaleFromCart(PosCartState cart) {
  return PosSale(
    id: 'PREVIEW',
    docNumber: 'Bill Preview',
    completedAt: DateTime.now(),
    totalAmount: cart.subtotal,
    taxAmount: cart.totalTax,
    finalAmount: cart.totalPayable,
    itemCount: cart.totalQty,
    customerName: cart.customerName,
    payments: cart.payments,
    items: [
      for (final line in cart.items)
        PosSaleLineItem(
          name: line.item.name,
          quantity: line.quantity,
          lineTotal: line.lineTotal,
          itemId: line.item.id,
          unit: line.item.unit,
          unitPrice: line.unitPrice,
        ),
    ],
  );
}

@Riverpod(keepAlive: true)
PosReceiptPrinter posReceiptPrinter(Ref ref) {
  return PosReceiptPrinter(
    outputService: ref.watch(printOutputServiceProvider),
  );
}

/// Prints POS receipts using the app-wide print settings.
class PosReceiptPrinter {
  PosReceiptPrinter({
    required this._outputService,
  });

  final PrintOutputService _outputService;

  Future<Uint8List> generatePdf({
    required PosSale sale,
    required WidgetRef ref,
  }) async {
    final business = ref.read(currentBusinessProvider);
    if (business == null) {
      throw StateError('Business profile is not available');
    }

    final settings = await ref.read(printSettingsProvider.future);
    return InvoicePrintDocumentService.buildBytesFromPosSale(
      settings: settings,
      business: business,
      sale: sale,
      ref: ref,
    );
  }

  Future<void> print({
    required BuildContext context,
    required PosSale sale,
    required WidgetRef ref,
  }) async {
    final settings = await ref.read(printSettingsProvider.future);
    final bytes = await generatePdf(sale: sale, ref: ref);
    final name = 'pos_${sale.docNumber}';
    final format = posReceiptPdfFormat(settings: settings, sale: sale);

    for (var copy = 0; copy < settings.numberOfCopies; copy++) {
      await _outputService.print(
        context: context,
        bytes: bytes,
        name: name,
        format: format,
      );
    }
  }

  Future<void> preview({
    required BuildContext context,
    required PosSale sale,
    required WidgetRef ref,
  }) async {
    await print(context: context, sale: sale, ref: ref);
  }

  String pdfBasename(PosSale sale) {
    return 'pos_${sale.docNumber.replaceAll(RegExp(r'\s+'), '_')}';
  }

  Future<String?> savePdf({
    required PosSale sale,
    required WidgetRef ref,
  }) async {
    final bytes = await generatePdf(sale: sale, ref: ref);
    return _outputService.save(
      bytes: bytes,
      filename: pdfBasename(sale),
    );
  }

  Future<void> share({
    required PosSale sale,
    required WidgetRef ref,
    String? filename,
  }) async {
    final bytes = await generatePdf(sale: sale, ref: ref);
    final name = filename ?? pdfBasename(sale);
    await _outputService.share(bytes: bytes, filename: name);
  }
}
