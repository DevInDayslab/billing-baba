import 'dart:typed_data';

import 'package:billing_baba/features/print/application/print_data_service.dart';
import 'package:billing_baba/features/print/application/print_output_service.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/templates/template_registry.dart';
import 'package:flutter/material.dart';

export 'package:billing_baba/features/print/application/print_exception.dart'
    show PrintException;

/// Orchestrates data loading, template rendering, and PDF output.
class PrintService {
  PrintService({
    required this._dataService,
    required this._outputService,
    required this._templateRegistry,
  });

  final PrintDataService _dataService;
  final PrintOutputService _outputService;
  final TemplateRegistry _templateRegistry;

  Future<Uint8List> generatePdf(PrintRequest request) => _renderPdf(request);

  Future<Uint8List> _renderPdf(PrintRequest request) async {
    final document = await _dataService.load(request);
    final template = _templateRegistry.resolve(document.kind);
    return template.render(document);
  }

  Future<void> preview({
    required BuildContext context,
    required PrintRequest request,
    String? name,
  }) async {
    final bytes = await _renderPdf(request);
    if (!context.mounted) return;
    await _outputService.preview(
      context: context,
      bytes: bytes,
      name: name ?? _defaultFilename(request),
    );
  }

  Future<void> print(PrintRequest request, {String? name}) async {
    final bytes = await _renderPdf(request);
    await _outputService.print(
      bytes: bytes,
      name: name ?? _defaultFilename(request),
    );
  }

  Future<void> share(PrintRequest request, {String? filename}) async {
    final bytes = await _renderPdf(request);
    await _outputService.share(
      bytes: bytes,
      filename: filename ?? '${_defaultFilename(request)}.pdf',
    );
  }

  Future<String?> save(PrintRequest request, {String? filename}) async {
    final bytes = await _renderPdf(request);
    return _outputService.save(
      bytes: bytes,
      filename: filename ?? '${_defaultFilename(request)}.pdf',
    );
  }

  String _defaultFilename(PrintRequest request) {
    return switch (request) {
      SaleInvoicePrintRequest(:final id) => 'invoice_$id',
      PurchaseBillPrintRequest(:final id) => 'purchase_bill_$id',
      EstimatePrintRequest(:final id) => 'quotation_$id',
      ProformaInvoicePrintRequest(:final id) => 'proforma_$id',
      DeliveryChallanPrintRequest(:final id) => 'challan_$id',
      CreditNotePrintRequest(:final id) => 'credit_note_$id',
      DebitNotePrintRequest(:final id) => 'debit_note_$id',
      SaleOrderPrintRequest(:final id) => 'sale_order_$id',
      PurchaseOrderPrintRequest(:final id) => 'purchase_order_$id',
      PaymentInPrintRequest(:final id) => 'payment_receipt_$id',
      PaymentOutPrintRequest(:final id) => 'payment_voucher_$id',
      ExpensePrintRequest(:final id) => 'expense_$id',
      FixedAssetPurchasePrintRequest(:final id) => 'fa_purchase_$id',
      JobWorkOrderPrintRequest(:final id) => 'job_work_$id',
    };
  }
}
