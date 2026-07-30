import 'dart:async';

import 'package:billing_baba/features/generated_documents/application/generated_document_service.dart';
import 'package:billing_baba/features/print/application/print_data_service.dart';
import 'package:billing_baba/features/print/application/print_output_service.dart';
import 'package:billing_baba/features/print/models/pdf_page_profile.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_pdf.dart';
import 'package:billing_baba/features/print/templates/template_registry.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/features/settings/repositories/print_settings_repository.dart';
import 'package:billing_baba/features/settings/services/invoice_print_document_service.dart';
import 'package:billing_baba/features/settings/utils/thermal_pdf_page_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'package:billing_baba/features/print/application/print_exception.dart'
    show PrintException;
export 'package:billing_baba/features/print/models/pdf_page_profile.dart'
    show PdfPageProfile, PdfProfileKind;
export 'package:billing_baba/features/print/models/printable_pdf.dart'
    show PrintablePdf;

/// Orchestrates data loading, template rendering, and PDF output.
class PrintService {
  PrintService({
    required this._dataService,
    required this._outputService,
    required this._templateRegistry,
    required this._printSettingsRepository,
    this._generatedDocumentService,
  });

  final PrintDataService _dataService;
  final PrintOutputService _outputService;
  final TemplateRegistry _templateRegistry;
  final PrintSettingsRepository _printSettingsRepository;
  final GeneratedDocumentService? _generatedDocumentService;

  Future<PrintSettings> _loadSettings() => _printSettingsRepository.load();

  Future<Uint8List> generatePdf(PrintRequest request) async {
    final settings = await _loadSettings();
    return _renderPdf(request, settings: settings);
  }

  Future<PrintablePdf> prepare(PrintRequest request, {String? name}) async {
    final settings = await _loadSettings();
    final bytes = await _renderPdf(request, settings: settings);
    return PrintablePdf(
      bytes: bytes,
      name: name ?? _defaultFilename(request),
      profile: PdfPageProfile.forPrintSettings(settings),
    );
  }

  Future<Uint8List> _renderPdf(
    PrintRequest request, {
    required PrintSettings settings,
  }) async {
    final document = await _dataService.load(request);

    final Uint8List bytes;
    if (_usesPrintSettings(document)) {
      bytes = await InvoicePrintDocumentService.buildBytesFromPrintableDocument(
        settings: settings,
        document: document,
      );
    } else {
      final template = _templateRegistry.resolve(document.kind);
      bytes = await template.render(document);
    }

    _cacheCloudPdf(request, bytes);
    return bytes;
  }

  /// Best-effort upload so Railway/storage matches in-app print/preview.
  void _cacheCloudPdf(PrintRequest request, Uint8List bytes) {
    final service = _generatedDocumentService;
    if (service == null) return;

    unawaited(() async {
      try {
        await service.cacheForPrintRequest(
          request,
          bytes,
          fileName: '${_defaultFilename(request)}.pdf',
        );
      } on Object catch (error, stackTrace) {
        debugPrint('Generated document cache failed: $error\n$stackTrace');
      }
    }());
  }

  bool _usesPrintSettings(PrintableDocument document) =>
      document.kind.isCommercial && document.hasLineItems;

  Future<void> preview({
    required BuildContext context,
    required PrintRequest request,
    String? name,
  }) async {
    final settings = await _loadSettings();
    final bytes = await _renderPdf(request, settings: settings);
    if (!context.mounted) return;
    await _outputService.previewDocument(
      context,
      _documentFromBytes(
        bytes: bytes,
        name: name ?? _defaultFilename(request),
        settings: settings,
      ),
      format: layoutPdfFormatFor(settings),
    );
  }

  PrintablePdf _documentFromBytes({
    required Uint8List bytes,
    required String name,
    required PrintSettings settings,
  }) {
    return PrintablePdf(
      bytes: bytes,
      name: name,
      profile: PdfPageProfile.forPrintSettings(settings),
    );
  }

  Future<void> print({
    required BuildContext context,
    required PrintRequest request,
    String? name,
  }) async {
    final settings = await _loadSettings();
    final bytes = await _renderPdf(request, settings: settings);
    if (!context.mounted) return;
    await _outputService.printDocument(
      context: context,
      document: _documentFromBytes(
        bytes: bytes,
        name: name ?? _defaultFilename(request),
        settings: settings,
      ),
      format: layoutPdfFormatFor(settings),
      copies: settings.numberOfCopies,
    );
  }

  Future<void> share(PrintRequest request, {String? filename}) async {
    final settings = await _loadSettings();
    final bytes = await _renderPdf(request, settings: settings);
    await _outputService.share(
      bytes: bytes,
      filename: filename ?? '${_defaultFilename(request)}.pdf',
    );
  }

  Future<String?> save(PrintRequest request, {String? filename}) async {
    final settings = await _loadSettings();
    final bytes = await _renderPdf(request, settings: settings);
    return saveBytes(
      bytes,
      filename: filename ?? '${_defaultFilename(request)}.pdf',
    );
  }

  Future<String?> saveBytes(
    Uint8List bytes, {
    required String filename,
  }) => _outputService.save(bytes: bytes, filename: filename);

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
      SaleFaPrintRequest(:final id) => 'sale_fa_$id',
      JobWorkOrderPrintRequest(:final id) => 'job_work_$id',
    };
  }
}
