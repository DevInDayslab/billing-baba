import 'dart:typed_data';

import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/print/application/print_output_service.dart';
import 'package:billing_baba/features/print/presentation/providers/print_providers.dart';
import 'package:billing_baba/features/settings/providers/print_settings_provider.dart';
import 'package:billing_baba/features/settings/services/invoice_print_document_service.dart';
import 'package:billing_baba/features/settings/utils/thermal_pdf_page_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_receipt_printer.g.dart';

@Riverpod(keepAlive: true)
PosReceiptPrinter posReceiptPrinter(Ref ref) {
  return PosReceiptPrinter(
    outputService: ref.watch(printOutputServiceProvider),
  );
}

/// Prints POS receipts using the app-wide print settings.
class PosReceiptPrinter {
  PosReceiptPrinter({
    required PrintOutputService outputService,
  }) : _outputService = outputService;

  final PrintOutputService _outputService;

  Future<Uint8List> generatePdf({
    required PosSale sale,
    required WidgetRef ref,
  }) async {
    final business = ref.read(currentBusinessProvider);
    if (business == null) {
      throw StateError('Business profile is not available');
    }

    final settings = await ref.read(printSettingsNotifierProvider.future);
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
    final settings = await ref.read(printSettingsNotifierProvider.future);
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
}
