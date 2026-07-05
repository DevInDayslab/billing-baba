import 'package:billing_baba/features/print/application/print_service.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/providers/print_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sales invoice print/share actions via [PrintService].
abstract final class SaleInvoicePrintActions {
  static String filenameFor(String invoiceNo) {
    final safe = invoiceNo.replaceAll(RegExp(r'[^\w\-]+'), '_');
    return safe.isEmpty ? 'invoice' : safe;
  }

  static Future<void> preview(
    BuildContext context,
    WidgetRef ref,
    String invoiceId, {
    String? filename,
  }) {
    return _run(
      context,
      ref,
      (service) => service.preview(
        context: context,
        request: PrintRequest.saleInvoice(invoiceId),
        name: filename,
      ),
    );
  }

  static Future<void> print(
    BuildContext context,
    WidgetRef ref,
    String invoiceId, {
    String? filename,
  }) {
    return _run(
      context,
      ref,
      (service) => service.print(
        PrintRequest.saleInvoice(invoiceId),
        name: filename,
      ),
    );
  }

  static Future<void> share(
    BuildContext context,
    WidgetRef ref,
    String invoiceId, {
    required String filename,
  }) {
    return _run(
      context,
      ref,
      (service) => service.share(
        PrintRequest.saleInvoice(invoiceId),
        filename: '$filename.pdf',
      ),
    );
  }

  static Future<void> save(
    BuildContext context,
    WidgetRef ref,
    String invoiceId, {
    required String filename,
  }) {
    return _run(
      context,
      ref,
      (service) async {
        final path = await service.save(
          PrintRequest.saleInvoice(invoiceId),
          filename: '$filename.pdf',
        );
        if (!context.mounted) return;
        final message = path != null
            ? 'PDF saved to $path'
            : 'PDF ready to share';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  static Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(PrintService service) action,
  ) async {
    try {
      final service = await ref.read(printServiceProvider.future);
      if (!context.mounted) return;
      await action(service);
    } on PrintException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print failed: $error')),
      );
    }
  }
}
