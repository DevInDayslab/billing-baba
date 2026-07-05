import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Print/share actions for payment and voucher documents.
abstract final class VoucherPrintActions {
  static String filenameFor(String documentNumber) =>
      DocumentPrintActions.filenameFor(documentNumber);

  static Future<void> previewPaymentIn(
    BuildContext context,
    WidgetRef ref,
    String paymentId, {
    String? filename,
  }) {
    return DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.paymentIn(paymentId),
      filename: filename,
    );
  }

  static Future<void> printPaymentIn(
    BuildContext context,
    WidgetRef ref,
    String paymentId, {
    String? filename,
  }) {
    return DocumentPrintActions.print(
      context,
      ref,
      PrintRequest.paymentIn(paymentId),
      filename: filename,
    );
  }

  static Future<void> sharePaymentIn(
    BuildContext context,
    WidgetRef ref,
    String paymentId, {
    required String filename,
  }) {
    return DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.paymentIn(paymentId),
      filename: filename,
    );
  }

  static Future<void> previewPaymentOut(
    BuildContext context,
    WidgetRef ref,
    String paymentId, {
    String? filename,
  }) {
    return DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.paymentOut(paymentId),
      filename: filename,
    );
  }

  static Future<void> printPaymentOut(
    BuildContext context,
    WidgetRef ref,
    String paymentId, {
    String? filename,
  }) {
    return DocumentPrintActions.print(
      context,
      ref,
      PrintRequest.paymentOut(paymentId),
      filename: filename,
    );
  }

  static Future<void> sharePaymentOut(
    BuildContext context,
    WidgetRef ref,
    String paymentId, {
    required String filename,
  }) {
    return DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.paymentOut(paymentId),
      filename: filename,
    );
  }

  static Future<void> previewExpense(
    BuildContext context,
    WidgetRef ref,
    String expenseId, {
    String? filename,
  }) {
    return DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.expense(expenseId),
      filename: filename,
    );
  }

  static Future<void> shareExpense(
    BuildContext context,
    WidgetRef ref,
    String expenseId, {
    required String filename,
  }) {
    return DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.expense(expenseId),
      filename: filename,
    );
  }

  static Future<void> previewFixedAssetPurchase(
    BuildContext context,
    WidgetRef ref,
    String batchId, {
    String? filename,
  }) {
    return DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.fixedAssetPurchase(batchId),
      filename: filename,
    );
  }

  static Future<void> shareFixedAssetPurchase(
    BuildContext context,
    WidgetRef ref,
    String batchId, {
    required String filename,
  }) {
    return DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.fixedAssetPurchase(batchId),
      filename: filename,
    );
  }

  static Future<void> previewJobWorkOrder(
    BuildContext context,
    WidgetRef ref,
    String orderId, {
    String? filename,
  }) {
    return DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.jobWorkOrder(orderId),
      filename: filename,
    );
  }

  static Future<void> shareJobWorkOrder(
    BuildContext context,
    WidgetRef ref,
    String orderId, {
    required String filename,
  }) {
    return DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.jobWorkOrder(orderId),
      filename: filename,
    );
  }

  static void showSaveBeforePrinting(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Save before printing')),
    );
  }
}
