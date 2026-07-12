import 'package:billing_baba/features/export/application/adapters/job_work_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/payment_in_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/payment_out_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/purchase_bill_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/purchase_document_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/purchase_fa_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/purchase_order_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/purchase_return_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/sale_fa_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/sale_invoice_export_adapter.dart';
import 'package:billing_baba/features/export/application/adapters/sales_document_export_adapter.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/presentation/widgets/export_actions.dart';
import 'package:billing_baba/features/purchases/providers/purchase_documents_list_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_report_options_dialog.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Typed export actions for transaction list modules.
abstract final class ModuleExportActions {
  static Future<void> exportSaleInvoices(BuildContext context, WidgetRef ref) async {
    final options = await showSaleInvoiceReportOptionsDialog(context);
    if (options == null || !context.mounted) return;

    return _exportXlsx(
      context,
      ref,
      filenameBase: 'Sales',
      loader: () => buildSaleInvoiceExportSheet(ref, options: options),
    );
  }

  static Future<void> exportSalesDocuments(
    BuildContext context,
    WidgetRef ref,
    SalesDocumentListScope scope,
  ) {
    return _exportXlsx(
      context,
      ref,
      filenameBase: salesDocumentExportFilenameBase(scope),
      loader: () => buildSalesDocumentExportSheet(
        ref,
        scope,
        sheetName: salesDocumentExportSheetName(scope),
        filenameBase: salesDocumentExportFilenameBase(scope),
      ),
    );
  }

  static Future<void> exportCreditNotes(BuildContext context, WidgetRef ref) {
    return exportSalesDocuments(context, ref, salesReturnListScope());
  }

  static Future<void> exportPurchaseBills(BuildContext context, WidgetRef ref) {
    return _exportXlsx(
      context,
      ref,
      filenameBase: 'Purchase_Bills',
      loader: () => buildPurchaseBillExportSheet(ref),
    );
  }

  static Future<void> exportPurchaseDocuments(
    BuildContext context,
    WidgetRef ref,
    PurchaseDocumentListScope scope,
  ) {
    return _exportXlsx(
      context,
      ref,
      filenameBase: purchaseDocumentExportFilenameBase(scope),
      loader: () => buildPurchaseDocumentExportSheet(
        ref,
        scope,
        sheetName: purchaseDocumentExportFilenameBase(scope).replaceAll('_', ' '),
      ),
    );
  }

  static Future<void> exportDebitNotes(BuildContext context, WidgetRef ref) {
    return _exportXlsx(
      context,
      ref,
      filenameBase: 'Debit_Notes',
      loader: () => buildPurchaseReturnExportSheet(ref),
    );
  }

  static Future<void> exportPurchaseOrders(
    BuildContext context,
    WidgetRef ref,
  ) {
    return _exportXlsx(
      context,
      ref,
      filenameBase: 'Purchase_Orders',
      loader: () => buildPurchaseOrderExportSheet(ref),
    );
  }

  static Future<void> exportPaymentIn(BuildContext context, WidgetRef ref) {
    return _exportXlsx(
      context,
      ref,
      filenameBase: 'Payment_In',
      loader: () => buildPaymentInExportSheet(ref),
    );
  }

  static Future<void> exportPaymentOut(BuildContext context, WidgetRef ref) {
    return _exportXlsx(
      context,
      ref,
      filenameBase: 'Payment_Out',
      loader: () => buildPaymentOutExportSheet(ref),
    );
  }

  static Future<void> exportFixedAssets(BuildContext context, WidgetRef ref) {
    return _exportXlsx(
      context,
      ref,
      filenameBase: 'Fixed_Asset_Purchases',
      loader: () => buildPurchaseFaExportSheet(ref),
    );
  }

  static Future<void> exportSaleFa(BuildContext context, WidgetRef ref) {
    return _exportXlsx(
      context,
      ref,
      filenameBase: 'Sale_FA',
      loader: () => buildSaleFaExportSheet(ref),
    );
  }

  static Future<void> exportJobWork(BuildContext context, WidgetRef ref) {
    return _exportXlsx(
      context,
      ref,
      filenameBase: 'Job_Work',
      loader: () => buildJobWorkExportSheet(ref),
    );
  }

  static Future<void> _exportXlsx(
    BuildContext context,
    WidgetRef ref, {
    required String filenameBase,
    required Future<ExportSheet> Function() loader,
  }) async {
    final sheet = await loader();
    if (!context.mounted) return;
    await ExportActions.exportXlsx(
      context,
      sheet: sheet,
      filenameBase: filenameBase,
    );
  }
}
