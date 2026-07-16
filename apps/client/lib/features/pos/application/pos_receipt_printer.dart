import 'dart:typed_data';

import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/print/application/print_output_service.dart';
import 'package:billing_baba/features/print/models/printable_pdf.dart';
import 'package:billing_baba/features/print/templates/pos_receipt_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:billing_baba/features/print/presentation/providers/print_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_receipt_printer.g.dart';

@Riverpod(keepAlive: true)
PosReceiptPrinter posReceiptPrinter(Ref ref) {
  return PosReceiptPrinter(
    outputService: ref.watch(printOutputServiceProvider),
    template: PosReceiptTemplate(),
  );
}

/// Prints POS receipts from local [PosSale] data without an API call.
class PosReceiptPrinter {
  PosReceiptPrinter({
    required PrintOutputService outputService,
    required PosReceiptTemplate template,
  })  : _outputService = outputService,
        _template = template;

  final PrintOutputService _outputService;
  final PosReceiptTemplate _template;

  Future<Uint8List> generatePdf({
    required PosSale sale,
    required WidgetRef ref,
  }) {
    final business = ref.read(currentBusinessProvider);
    final sidebar = ref.read(sidebarBusinessProvider);
    return _template.renderSale(
      sale: sale,
      businessName: sidebar.name,
      address: business?.address,
      gstin: business?.gstin,
    );
  }

  Future<void> print({
    required PosSale sale,
    required WidgetRef ref,
  }) async {
    final document = PrintablePdf(
      bytes: await generatePdf(sale: sale, ref: ref),
      name: 'pos_${sale.docNumber}',
    );
    await _outputService.printDocument(document);
  }

  Future<void> preview({
    required BuildContext context,
    required PosSale sale,
    required WidgetRef ref,
  }) async {
    final document = PrintablePdf(
      bytes: await generatePdf(sale: sale, ref: ref),
      name: 'pos_${sale.docNumber}',
    );
    if (!context.mounted) return;
    await _outputService.previewDocument(document);
  }
}
