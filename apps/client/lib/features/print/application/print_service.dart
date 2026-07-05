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

  Future<Uint8List> generatePdf(PrintRequest request) async {
    final document = await _dataService.load(request);
    final template = _templateRegistry.resolve(document.kind);
    return template.render(document);
  }

  Future<void> preview({
    required BuildContext context,
    required PrintRequest request,
    String? name,
  }) async {
    final bytes = await generatePdf(request);
    if (!context.mounted) return;
    await _outputService.preview(
      context: context,
      bytes: bytes,
      name: name ?? _defaultFilename(request),
    );
  }

  Future<void> print(PrintRequest request, {String? name}) async {
    final bytes = await generatePdf(request);
    await _outputService.print(
      bytes: bytes,
      name: name ?? _defaultFilename(request),
    );
  }

  Future<void> share(PrintRequest request, {String? filename}) async {
    final bytes = await generatePdf(request);
    await _outputService.share(
      bytes: bytes,
      filename: filename ?? '${_defaultFilename(request)}.pdf',
    );
  }

  Future<String?> save(PrintRequest request, {String? filename}) async {
    final bytes = await generatePdf(request);
    return _outputService.save(
      bytes: bytes,
      filename: filename ?? '${_defaultFilename(request)}.pdf',
    );
  }

  String _defaultFilename(PrintRequest request) {
    return switch (request) {
      SaleInvoicePrintRequest() => 'invoice_${request.id}',
      _ => '${request.kind.name}_${request.id}',
    };
  }
}
