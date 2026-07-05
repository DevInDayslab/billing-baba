import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sales invoice print/share actions via [DocumentPrintActions].
abstract final class SaleInvoicePrintActions {
  static String filenameFor(String invoiceNo) =>
      DocumentPrintActions.filenameFor(invoiceNo);

  static Future<void> preview(
    BuildContext context,
    WidgetRef ref,
    String invoiceId, {
    String? filename,
  }) {
    return DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.saleInvoice(invoiceId),
      filename: filename,
    );
  }

  static Future<void> print(
    BuildContext context,
    WidgetRef ref,
    String invoiceId, {
    String? filename,
  }) {
    return DocumentPrintActions.print(
      context,
      ref,
      PrintRequest.saleInvoice(invoiceId),
      filename: filename,
    );
  }

  static Future<void> share(
    BuildContext context,
    WidgetRef ref,
    String invoiceId, {
    required String filename,
  }) {
    return DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.saleInvoice(invoiceId),
      filename: filename,
    );
  }

  static Future<void> save(
    BuildContext context,
    WidgetRef ref,
    String invoiceId, {
    required String filename,
  }) {
    return DocumentPrintActions.save(
      context,
      ref,
      PrintRequest.saleInvoice(invoiceId),
      filename: filename,
    );
  }
}
