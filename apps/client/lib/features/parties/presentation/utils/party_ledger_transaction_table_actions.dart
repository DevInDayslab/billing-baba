import 'dart:async' show unawaited;

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_ledger_transaction_resolver.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_transaction_navigation.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/sale_invoice_print_actions.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_bill_actions.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_order_actions.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_return_actions.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/delivery_challan_actions_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/estimate_quotation_actions_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/payment_in_actions_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_document_actions_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_invoice_actions_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Ledger row category derived only from fields already present in the table row.
/// No network, SQLite, or provider access — safe to call synchronously on click.
enum PartyLedgerTransactionKind {
  saleInvoice,
  saleReturn,
  estimate,
  proforma,
  saleOrder,
  deliveryChallan,
  saleFa,
  purchaseBill,
  purchaseReturn,
  purchaseOrder,
  purchaseFa,
  jobWork,
  paymentIn,
  paymentOut,
  expense,
  unknown,
}

class PartyLedgerMenuEntry {
  const PartyLedgerMenuEntry({
    required this.action,
    required this.label,
    this.dividerBefore = false,
  });

  final String action;
  final String label;
  final bool dividerBefore;
}

abstract final class PartyLedgerTransactionTableActions {
  const PartyLedgerTransactionTableActions._();

  static PartyLedgerTransactionKind kindFor(
    PartyLedgerTransactionModel transaction,
  ) {
    final source = transaction.source.isNotEmpty
        ? transaction.source
        : (transaction.referenceType ?? '');

    return switch (source) {
      'payments' =>
        transaction.direction == 'paid'
            ? PartyLedgerTransactionKind.paymentOut
            : PartyLedgerTransactionKind.paymentIn,
      'expenses' => PartyLedgerTransactionKind.expense,
      'sale_fa_batches' => PartyLedgerTransactionKind.saleFa,
      'purchase_fa_batches' => PartyLedgerTransactionKind.purchaseFa,
      'job_work_orders' => PartyLedgerTransactionKind.jobWork,
      'purchase_documents' => switch (transaction.sourceType) {
        'purchase_return' => PartyLedgerTransactionKind.purchaseReturn,
        'purchase_order' => PartyLedgerTransactionKind.purchaseOrder,
        _ => PartyLedgerTransactionKind.purchaseBill,
      },
      'sales_documents' => switch (transaction.sourceType) {
        'sales_return' => PartyLedgerTransactionKind.saleReturn,
        'estimate' =>
          transaction.type.toLowerCase().contains('proforma')
              ? PartyLedgerTransactionKind.proforma
              : PartyLedgerTransactionKind.estimate,
        'sale_order' => PartyLedgerTransactionKind.saleOrder,
        'delivery_challan' => PartyLedgerTransactionKind.deliveryChallan,
        _ => PartyLedgerTransactionKind.saleInvoice,
      },
      _ => PartyLedgerTransactionKind.unknown,
    };
  }

  /// Builds menu items synchronously from the ledger row. Opens instantly via
  /// [SalesActionMenuButton] — no awaits before the popup is shown.
  static List<SalesActionMenuItem> buildMenuItems({
    required PartyLedgerTransactionModel transaction,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final entries = menuEntriesFor(transaction);
    return [
      for (final entry in entries)
        SalesActionMenuItem(
          label: entry.label,
          dividerBefore: entry.dividerBefore,
          onSelected: () => handleAction(
            context: context,
            ref: ref,
            transaction: transaction,
            action: entry.action,
          ),
        ),
    ];
  }

  static List<PartyLedgerMenuEntry> menuEntriesFor(
    PartyLedgerTransactionModel transaction,
  ) {
    return switch (kindFor(transaction)) {
      PartyLedgerTransactionKind.saleInvoice => const [
        PartyLedgerMenuEntry(action: 'view_edit', label: 'View/Edit'),
        PartyLedgerMenuEntry(
          action: 'cancel_transaction',
          label: 'Cancel Invoice',
        ),
        PartyLedgerMenuEntry(action: 'delete', label: 'Delete'),
        PartyLedgerMenuEntry(action: 'duplicate', label: 'Duplicate'),
        PartyLedgerMenuEntry(action: 'open_pdf', label: 'Open PDF'),
        PartyLedgerMenuEntry(action: 'preview', label: 'Preview'),
        PartyLedgerMenuEntry(action: 'print', label: 'Print'),
        PartyLedgerMenuEntry(
          action: 'preview_delivery_challan',
          label: 'Preview as Delivery Challan',
        ),
        PartyLedgerMenuEntry(
          action: 'convert_to_return',
          label: 'Convert to Return',
        ),
        PartyLedgerMenuEntry(
          action: 'receive_payment',
          label: 'Receive Payment',
        ),
        PartyLedgerMenuEntry(
          action: 'view_history',
          label: 'View History',
          dividerBefore: true,
        ),
      ],
      PartyLedgerTransactionKind.saleReturn => const [
        PartyLedgerMenuEntry(action: 'view_edit', label: 'View/Edit'),
        PartyLedgerMenuEntry(action: 'delete', label: 'Delete'),
        PartyLedgerMenuEntry(action: 'print', label: 'Print'),
        PartyLedgerMenuEntry(action: 'open_pdf', label: 'PDF'),
        PartyLedgerMenuEntry(
          action: 'view_history',
          label: 'View History',
          dividerBefore: true,
        ),
      ],
      PartyLedgerTransactionKind.purchaseBill => const [
        PartyLedgerMenuEntry(action: 'view_edit', label: 'View/Edit'),
        PartyLedgerMenuEntry(action: 'delete', label: 'Delete'),
        PartyLedgerMenuEntry(action: 'duplicate', label: 'Duplicate'),
        PartyLedgerMenuEntry(action: 'print', label: 'Print'),
        PartyLedgerMenuEntry(action: 'open_pdf', label: 'PDF'),
        PartyLedgerMenuEntry(action: 'payment', label: 'Payment'),
        PartyLedgerMenuEntry(
          action: 'view_history',
          label: 'View History',
          dividerBefore: true,
        ),
      ],
      PartyLedgerTransactionKind.purchaseReturn => const [
        PartyLedgerMenuEntry(action: 'view_edit', label: 'View/Edit'),
        PartyLedgerMenuEntry(action: 'delete', label: 'Delete'),
        PartyLedgerMenuEntry(action: 'print', label: 'Print'),
        PartyLedgerMenuEntry(action: 'open_pdf', label: 'PDF'),
        PartyLedgerMenuEntry(
          action: 'view_history',
          label: 'View History',
          dividerBefore: true,
        ),
      ],
      PartyLedgerTransactionKind.paymentIn => const [
        PartyLedgerMenuEntry(action: 'view_edit', label: 'View/Edit'),
        PartyLedgerMenuEntry(action: 'delete', label: 'Delete'),
        PartyLedgerMenuEntry(action: 'print', label: 'Print'),
        PartyLedgerMenuEntry(
          action: 'view_history',
          label: 'View History',
          dividerBefore: true,
        ),
      ],
      PartyLedgerTransactionKind.paymentOut => const [
        PartyLedgerMenuEntry(action: 'view_edit', label: 'View/Edit'),
        PartyLedgerMenuEntry(action: 'delete', label: 'Delete'),
        PartyLedgerMenuEntry(action: 'print', label: 'Print'),
        PartyLedgerMenuEntry(
          action: 'view_history',
          label: 'View History',
          dividerBefore: true,
        ),
      ],
      PartyLedgerTransactionKind.expense => const [
        PartyLedgerMenuEntry(action: 'view_edit', label: 'View/Edit'),
      ],
      PartyLedgerTransactionKind.estimate ||
      PartyLedgerTransactionKind.proforma ||
      PartyLedgerTransactionKind.saleOrder ||
      PartyLedgerTransactionKind.deliveryChallan ||
      PartyLedgerTransactionKind.saleFa ||
      PartyLedgerTransactionKind.purchaseOrder ||
      PartyLedgerTransactionKind.purchaseFa ||
      PartyLedgerTransactionKind.jobWork => const [
        PartyLedgerMenuEntry(action: 'view_edit', label: 'View/Edit'),
        PartyLedgerMenuEntry(action: 'print', label: 'Print'),
      ],
      PartyLedgerTransactionKind.unknown => const [
        PartyLedgerMenuEntry(action: 'view_edit', label: 'View/Edit'),
      ],
    };
  }

  /// Runs only after the user picks a menu item — never before the popup opens.
  static Future<void> handleAction({
    required BuildContext context,
    required WidgetRef ref,
    required PartyLedgerTransactionModel transaction,
    required String action,
  }) async {
    final referenceId = transaction.referenceId?.trim();
    if (referenceId == null || referenceId.isEmpty) return;

    if (await _tryFastPath(
      context: context,
      ref: ref,
      transaction: transaction,
      action: action,
      referenceId: referenceId,
    )) {
      return;
    }

    final target = await PartyLedgerTransactionResolver.resolve(
      ref,
      transaction,
    );
    if (!context.mounted) return;
    await _dispatchResolvedAction(
      context: context,
      ref: ref,
      target: target,
      action: action,
      transaction: transaction,
    );
  }

  static Future<bool> _tryFastPath({
    required BuildContext context,
    required WidgetRef ref,
    required PartyLedgerTransactionModel transaction,
    required String action,
    required String referenceId,
  }) async {
    switch (action) {
      case 'view_edit':
        navigateToPartyLedgerTransaction(context, transaction);
        return true;
      case 'open_pdf':
      case 'preview':
      case 'print':
        await _handlePrintAction(
          context,
          ref,
          transaction,
          action,
        );
        return true;
      case 'duplicate':
        return _handleDuplicateFastPath(context, transaction, referenceId);
      case 'convert_to_return':
        if (transaction.referenceType == 'sales_documents' &&
            transaction.entryType != 'return') {
          await context.push(
            '${AppRoutes.addCreditNote}?fromInvoice=$referenceId',
          );
          return true;
        }
        return false;
      case 'receive_payment':
      case 'payment':
        await context.push(AppRoutes.salePaymentIn);
        return true;
      case 'preview_delivery_challan':
      case 'view_history':
        return false;
      case 'delete':
      case 'cancel_transaction':
        return false;
      default:
        return false;
    }
  }

  static bool _handleDuplicateFastPath(
    BuildContext context,
    PartyLedgerTransactionModel transaction,
    String referenceId,
  ) {
    if (transaction.referenceType == 'sales_documents' &&
        transaction.entryType != 'return') {
      unawaited(context.push('${AppRoutes.duplicateSale}/$referenceId'));
      return true;
    }
    return false;
  }

  static Future<void> _handlePrintAction(
    BuildContext context,
    WidgetRef ref,
    PartyLedgerTransactionModel transaction,
    String action,
  ) async {
    final referenceId = transaction.referenceId!.trim();
    final filename = _filenameFor(transaction);

    switch (kindFor(transaction)) {
      case PartyLedgerTransactionKind.saleInvoice:
        await SaleInvoicePrintActions.preview(
          context,
          ref,
          referenceId,
          filename: filename,
        );
      case PartyLedgerTransactionKind.saleReturn:
        final request = PrintRequest.creditNote(referenceId);
        await DocumentPrintActions.preview(
          context,
          ref,
          request,
          filename: filename,
        );
      case PartyLedgerTransactionKind.purchaseBill:
        final request = PrintRequest.purchaseBill(referenceId);
        await DocumentPrintActions.preview(
          context,
          ref,
          request,
          filename: filename,
        );
      case PartyLedgerTransactionKind.purchaseReturn:
        final request = PrintRequest.debitNote(referenceId);
        await DocumentPrintActions.preview(
          context,
          ref,
          request,
          filename: filename,
        );
      case PartyLedgerTransactionKind.paymentIn:
        await VoucherPrintActions.previewPaymentIn(
          context,
          ref,
          referenceId,
          filename: filename,
        );
      case PartyLedgerTransactionKind.paymentOut:
        await VoucherPrintActions.previewPaymentOut(
          context,
          ref,
          referenceId,
          filename: filename,
        );
      case PartyLedgerTransactionKind.estimate:
      case PartyLedgerTransactionKind.proforma:
      case PartyLedgerTransactionKind.saleOrder:
      case PartyLedgerTransactionKind.deliveryChallan:
      case PartyLedgerTransactionKind.saleFa:
      case PartyLedgerTransactionKind.purchaseOrder:
      case PartyLedgerTransactionKind.purchaseFa:
      case PartyLedgerTransactionKind.jobWork:
      case PartyLedgerTransactionKind.expense:
      case PartyLedgerTransactionKind.unknown:
        _showActionUnavailable(context, action);
    }
  }

  static String _filenameFor(PartyLedgerTransactionModel transaction) {
    final number = transaction.referenceNumber?.trim();
    if (number != null && number.isNotEmpty) {
      return VoucherPrintActions.filenameFor(number);
    }
    return 'document';
  }

  static Future<void> _dispatchResolvedAction({
    required BuildContext context,
    required WidgetRef ref,
    required PartyLedgerActionTarget target,
    required String action,
    required PartyLedgerTransactionModel transaction,
  }) async {
    switch (target) {
      case PartyLedgerSaleInvoiceTarget(:final invoice):
        final mapped = _mapSaleInvoiceAction(action);
        if (mapped != null) {
          await SaleInvoiceTableActions.handleAction(
            context,
            ref,
            invoice,
            mapped,
          );
        }
      case PartyLedgerSalesDocumentTarget(
        :final document,
        :final documentType,
      ):
        await _handleSalesDocumentTarget(
          context: context,
          ref: ref,
          document: document,
          documentType: documentType,
          action: action,
        );
      case PartyLedgerPaymentInTarget(:final record):
        final mapped = _mapPaymentInAction(action);
        if (mapped != null) {
          await PaymentInTableActions.handleAction(
            context,
            ref,
            record,
            mapped,
          );
        }
      case PartyLedgerPaymentOutTarget(:final record):
        await _handlePaymentOutAction(context, ref, record, action);
      case PartyLedgerPurchaseBillTarget(:final bill):
        final mapped = _mapPurchaseBillAction(action);
        if (mapped != null) {
          await handlePurchaseBillMenuAction(
            context: context,
            ref: ref,
            action: mapped,
            bill: bill,
          );
        }
      case PartyLedgerPurchaseOrderTarget(:final order):
        final mapped = _mapPurchaseOrderAction(action);
        if (mapped != null) {
          await handlePurchaseOrderMenuAction(
            context: context,
            ref: ref,
            action: mapped,
            order: order,
          );
        }
      case PartyLedgerPurchaseReturnTarget(:final item):
        final mapped = _mapPurchaseReturnAction(action);
        if (mapped != null) {
          await handlePurchaseReturnMenuAction(
            context: context,
            ref: ref,
            action: mapped,
            item: item,
          );
        }
    }
  }

  static Future<void> _handleSalesDocumentTarget({
    required BuildContext context,
    required WidgetRef ref,
    required SaleInvoiceModel document,
    required SalesDocumentType documentType,
    required String action,
  }) async {
    switch (documentType) {
      case SalesDocumentType.salesReturn:
        final mapped = _mapSaleDocumentAction(action);
        if (mapped != null) {
          await SaleDocumentTableActions.handleAction(
            context,
            ref,
            document,
            SaleDocumentActionsConfig.salesReturn(),
            mapped,
          );
        }
      case SalesDocumentType.saleOrder:
        final mapped = _mapSaleDocumentAction(action);
        if (mapped != null) {
          await SaleDocumentTableActions.handleAction(
            context,
            ref,
            document,
            SaleDocumentActionsConfig.saleOrder(
              onEdit: (menuContext, _, id) async {
                await menuContext.push('${AppRoutes.editSaleOrder}/$id');
              },
            ),
            mapped,
          );
        }
      case SalesDocumentType.deliveryChallan:
        await DeliveryChallanTableActions.handleAction(
          context,
          ref,
          document,
          _mapSaleDocumentAction(action) ?? action,
        );
      case SalesDocumentType.estimate
          when document.documentSeries == SalesConstants.proformaSeries:
        final mapped = _mapSaleDocumentAction(action);
        if (mapped != null) {
          await SaleDocumentTableActions.handleAction(
            context,
            ref,
            document,
            SaleDocumentActionsConfig.proforma(
              onEdit: (menuContext, _, id) async {
                await menuContext.push('${AppRoutes.editEstimate}/$id');
              },
            ),
            mapped,
          );
        }
      case SalesDocumentType.estimate:
        await EstimateQuotationTableActions.handleAction(
          context,
          ref,
          document,
          _mapEstimateAction(action) ?? action,
        );
      case SalesDocumentType.taxInvoice:
      case SalesDocumentType.billOfSupply:
      case SalesDocumentType.normalInvoice:
      case SalesDocumentType.pos:
        final mapped = _mapSaleInvoiceAction(action);
        if (mapped != null) {
          await SaleInvoiceTableActions.handleAction(
            context,
            ref,
            document,
            mapped,
          );
        }
    }
  }

  static Future<void> _handlePaymentOutAction(
    BuildContext context,
    WidgetRef ref,
    PaymentOutModel record,
    String action,
  ) async {
    switch (action) {
      case 'delete':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delete is not available yet')),
        );
      case 'view_history':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History is not available yet')),
        );
      default:
        _showActionUnavailable(context, action);
    }
  }

  static String? _mapSaleInvoiceAction(String action) => switch (action) {
    'view_edit' => 'view_edit',
    'cancel_transaction' => 'cancel_transaction',
    'delete' => 'delete',
    'duplicate' => 'duplicate',
    'open_pdf' => 'open_pdf',
    'preview' => 'preview',
    'print' => 'print',
    'preview_delivery_challan' => 'preview_delivery_challan',
    'convert_to_return' => 'convert_to_return',
    'receive_payment' => 'payment_history',
    'view_history' => 'view_history',
    _ => null,
  };

  static String? _mapSaleDocumentAction(String action) => switch (action) {
    'view_edit' => 'view_edit',
    'delete' => 'delete',
    'open_pdf' => 'open_pdf',
    'preview' => 'preview',
    'print' => 'print',
    'cancel_transaction' => 'cancel',
    _ => null,
  };

  static String? _mapEstimateAction(String action) => switch (action) {
    'view_edit' => 'view_edit',
    'delete' => 'delete',
    'duplicate' => 'duplicate',
    'open_pdf' => 'open_pdf',
    'preview' => 'preview',
    'print' => 'print',
    'cancel_transaction' => 'cancel',
    _ => null,
  };

  static String? _mapPaymentInAction(String action) => switch (action) {
    'view_edit' => 'view_edit',
    'delete' => 'delete',
    'print' => 'print',
    'open_pdf' => 'open_pdf',
    'view_history' => 'view_history',
    _ => null,
  };

  static PurchaseBillMenuAction? _mapPurchaseBillAction(String action) =>
      switch (action) {
        'view_edit' => PurchaseBillMenuAction.viewEdit,
        'delete' => PurchaseBillMenuAction.delete,
        'duplicate' => PurchaseBillMenuAction.duplicate,
        'print' => PurchaseBillMenuAction.previewPrint,
        'open_pdf' => PurchaseBillMenuAction.openPdf,
        'payment' => PurchaseBillMenuAction.paymentHistory,
        'view_history' => PurchaseBillMenuAction.viewHistory,
        _ => null,
      };

  static PurchaseOrderMenuAction? _mapPurchaseOrderAction(String action) =>
      switch (action) {
        'view_edit' => PurchaseOrderMenuAction.viewEdit,
        'delete' => PurchaseOrderMenuAction.delete,
        'duplicate' => PurchaseOrderMenuAction.duplicate,
        'print' => PurchaseOrderMenuAction.previewPrint,
        'open_pdf' => PurchaseOrderMenuAction.openPdf,
        'payment' => PurchaseOrderMenuAction.paymentHistory,
        'view_history' => PurchaseOrderMenuAction.viewHistory,
        _ => null,
      };

  static PurchaseReturnMenuAction? _mapPurchaseReturnAction(String action) =>
      switch (action) {
        'view_edit' => PurchaseReturnMenuAction.viewEdit,
        'delete' => PurchaseReturnMenuAction.delete,
        'print' => PurchaseReturnMenuAction.previewPrint,
        'open_pdf' => PurchaseReturnMenuAction.openPdf,
        'view_history' => PurchaseReturnMenuAction.viewHistory,
        _ => null,
      };

  static void _showActionUnavailable(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action is not available for this transaction')),
    );
  }
}
