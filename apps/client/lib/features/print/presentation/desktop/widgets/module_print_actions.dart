import 'package:billing_baba/core/utils/output_error_mapper.dart';
import 'package:billing_baba/features/export/application/adapters/delivery_challan_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/payment_in_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/payment_out_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/purchase_bill_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/purchase_fa_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/purchase_order_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/purchase_return_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/sale_fa_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/sale_invoice_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/sale_return_export_adapter.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_formatters.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Typed print actions for transaction list modules.
abstract final class ModulePrintActions {
  static Future<void> printSaleInvoices(BuildContext context, WidgetRef ref) {
    return _printSheet(
      context,
      title: 'Sale Invoices',
      loader: () => buildSaleInvoiceExportSheet(ref),
    );
  }

  static Future<void> printPaymentIn(BuildContext context, WidgetRef ref) {
    return _printSheet(
      context,
      title: 'Payment In',
      loader: () => buildPaymentInExportSheet(ref),
    );
  }

  static Future<void> printPaymentOut(BuildContext context, WidgetRef ref) {
    return _printSheet(
      context,
      title: 'Payment Out',
      loader: () => buildPaymentOutExportSheet(ref),
    );
  }

  static Future<void> printDeliveryChallans(BuildContext context, WidgetRef ref) {
    return _printSheet(
      context,
      title: 'Delivery Challans',
      loader: () => buildDeliveryChallanExportSheet(ref),
    );
  }

  static Future<void> printSaleReturns(BuildContext context, WidgetRef ref) {
    return _printSheet(
      context,
      title: 'Sale Return',
      loader: () => buildSaleReturnExportSheet(ref),
    );
  }

  static Future<void> printSaleFa(BuildContext context, WidgetRef ref) {
    return _printSheet(
      context,
      title: 'Sale FA',
      loader: () => buildSaleFaExportSheet(ref),
    );
  }

  static Future<void> printPurchaseBills(BuildContext context, WidgetRef ref) {
    return _printSheet(
      context,
      title: 'Purchase Bills',
      loader: () => buildPurchaseBillExportSheet(ref),
    );
  }

  static Future<void> printPurchaseOrders(BuildContext context, WidgetRef ref) {
    return _printSheet(
      context,
      title: 'Purchase Orders',
      loader: () => buildPurchaseOrderExportSheet(ref),
    );
  }

  static Future<void> printDebitNotes(BuildContext context, WidgetRef ref) {
    return _printSheet(
      context,
      title: 'Purchase Return',
      loader: () => buildPurchaseReturnExportSheet(ref),
    );
  }

  static Future<void> printPurchaseFa(BuildContext context, WidgetRef ref) {
    return _printSheet(
      context,
      title: 'Purchase FA',
      loader: () => buildPurchaseFaExportSheet(ref),
    );
  }

  static Future<void> _printSheet(
    BuildContext context, {
    required String title,
    required Future<ExportSheet> Function() loader,
  }) async {
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    ExportSheet sheet;
    try {
      sheet = await loader();
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(OutputErrorMapper.exportMessage(error))),
        );
      }
      return;
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!context.mounted) return;

    if (sheet.rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to print')),
      );
      return;
    }

    final headers = [
      for (final column in sheet.columns) column.header,
    ];
    final rows = [
      for (final row in sheet.rows) ExportFormatters.formatRow(sheet, row),
    ];

    reportPrintTable(
      context: context,
      title: title,
      headers: headers,
      rows: rows,
    );
  }
}
