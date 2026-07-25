import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/sale_invoice_print_actions.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/clone_alternatives_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_invoice_cancel_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_invoice_delete_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';

class SaleInvoiceMenuEntry {
  const SaleInvoiceMenuEntry({
    required this.action,
    required this.label,
  });

  final String action;
  final String label;
}

class SaleInvoiceActionsMenuButton extends ConsumerWidget {
  const SaleInvoiceActionsMenuButton({
    required this.invoice,
    super.key,
  });

  final SaleInvoiceModel invoice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SalesActionMenuButton(
      items: [
        for (final item in SaleInvoiceTableActions.menuItems(invoice))
          SalesActionMenuItem(
            label: item.label,
            onSelected: () => SaleInvoiceTableActions.handleAction(
              context,
              ref,
              invoice,
              item.action,
            ),
          ),
      ],
    );
  }
}

class SaleInvoiceTableActions {
  const SaleInvoiceTableActions._();

  static List<SaleInvoiceMenuEntry> menuItems(SaleInvoiceModel invoice) {
    return [
      const SaleInvoiceMenuEntry(action: 'view_edit', label: 'View/Edit'),
      const SaleInvoiceMenuEntry(
        action: 'generate_e_invoice',
        label: 'Generate e-Invoice',
      ),
      const SaleInvoiceMenuEntry(
        action: 'convert_to_return',
        label: 'Convert To Return',
      ),
      const SaleInvoiceMenuEntry(
        action: 'preview_delivery_challan',
        label: 'Preview Delivery Challan',
      ),
      const SaleInvoiceMenuEntry(
        action: 'payment_history',
        label: 'Payment History',
      ),
      if (!invoice.isDraft && !invoice.isCancelled)
        const SaleInvoiceMenuEntry(
          action: 'cancel_transaction',
          label: 'Cancel Transaction',
        ),
      const SaleInvoiceMenuEntry(action: 'delete', label: 'Delete'),
      const SaleInvoiceMenuEntry(action: 'duplicate', label: 'Duplicate'),
      const SaleInvoiceMenuEntry(
        action: 'clone_with_alternatives',
        label: 'Clone with Alternatives',
      ),
      const SaleInvoiceMenuEntry(action: 'open_pdf', label: 'Open PDF'),
      const SaleInvoiceMenuEntry(action: 'preview', label: 'Preview'),
      const SaleInvoiceMenuEntry(action: 'print', label: 'Print'),
      const SaleInvoiceMenuEntry(
        action: 'view_history',
        label: 'View History',
      ),
      if (invoice.isDraft)
        const SaleInvoiceMenuEntry(action: 'finalize', label: 'Finalize'),
    ];
  }

  static Future<void> handleAction(
    BuildContext context,
    WidgetRef ref,
    SaleInvoiceModel invoice,
    String action,
  ) async {
    final notifier = ref.read(saleInvoicesProvider.notifier);
    final filename = SaleInvoicePrintActions.filenameFor(invoice.invoiceNo);

    switch (action) {
      case 'view_edit':
        await context.push('${AppRoutes.editSale}/${invoice.id}');
      case 'convert_to_return':
        await context.push(
          '${AppRoutes.addCreditNote}?fromInvoice=${invoice.id}',
        );
      case 'payment_history':
        if (invoice.partyId != null) {
          ref
              .read(paymentInFiltersProvider.notifier)
              .setPartyFilter(partyId: invoice.partyId);
          await context.push(AppRoutes.salePaymentIn);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No party linked to this invoice')),
          );
        }
      case 'duplicate':
        await context.push('${AppRoutes.duplicateSale}/${invoice.id}');
      case 'clone_with_alternatives':
        await _handleCloneWithAlternatives(context, ref, invoice);
      case 'generate_e_invoice':
      case 'preview_delivery_challan':
      case 'view_history':
        _showComingSoon(context, action);
      case 'cancel_transaction':
        await _confirmCancel(context, invoice, notifier);
      case 'delete':
        await _handleDelete(context, ref, invoice, notifier);
      case 'open_pdf':
      case 'preview':
        await SaleInvoicePrintActions.preview(
          context,
          ref,
          invoice.id,
          filename: filename,
        );
      case 'print':
        await SaleInvoicePrintActions.preview(
          context,
          ref,
          invoice.id,
          filename: filename,
        );
      case 'finalize':
        final error = await notifier.finalizeInvoice(invoice.id);
        if (!context.mounted) return;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
    }
  }

  static void _showComingSoon(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_labelForAction(action)} coming soon')),
    );
  }

  static String _labelForAction(String action) => switch (action) {
    'generate_e_invoice' => 'Generate e-Invoice',
    'convert_to_return' => 'Convert To Return',
    'preview_delivery_challan' => 'Preview Delivery Challan',
    'payment_history' => 'Payment History',
    'duplicate' => 'Duplicate',
    'view_history' => 'View History',
    _ => 'This action',
  };

  static Future<void> _confirmCancel(
    BuildContext context,
    SaleInvoiceModel invoice,
    SaleInvoices notifier,
  ) async {
    if (invoice.isDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only finalized invoices can be cancelled'),
        ),
      );
      return;
    }
    if (invoice.isCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This invoice is already cancelled')),
      );
      return;
    }

    final result = await showSaleInvoiceCancelDialog(context);
    if (result != SaleInvoiceCancelDialogResult.confirm || !context.mounted) {
      return;
    }

    final error = await notifier.cancelInvoice(invoice.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invoice ${invoice.invoiceNo} cancelled')),
    );
  }

  static Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    SaleInvoiceModel invoice,
    SaleInvoices notifier,
  ) async {
    if (invoice.isDraft) {
      await _confirmDeleteDraft(context, invoice, notifier);
      return;
    }

    final skipWarning = await readSaleInvoiceSkipDeleteWarning(ref);
    if (!context.mounted) return;

    if (!skipWarning) {
      final result = await showSaleInvoiceDeleteDialog(context);
      if (!context.mounted) return;

      switch (result) {
        case SaleInvoiceDeleteDialogResult.cancelInvoice:
          await _confirmCancel(context, invoice, notifier);
        case SaleInvoiceDeleteDialogResult.continueDeleting:
          await _performDelete(context, invoice, notifier);
        case null:
          break;
      }
      return;
    }

    await _performDelete(context, invoice, notifier);
  }

  static Future<void> _confirmDeleteDraft(
    BuildContext context,
    SaleInvoiceModel invoice,
    SaleInvoices notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete draft?'),
        content: Text('Delete draft ${invoice.invoiceNo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await _performDelete(context, invoice, notifier);
  }

  static Future<void> _performDelete(
    BuildContext context,
    SaleInvoiceModel invoice,
    SaleInvoices notifier,
  ) async {
    final error = await notifier.deleteInvoice(invoice.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invoice ${invoice.invoiceNo} deleted')),
    );
  }

  static Future<void> _handleCloneWithAlternatives(
    BuildContext context,
    WidgetRef ref,
    SaleInvoiceModel invoice,
  ) async {
    try {
      final salesService = await ref.read(salesServiceProvider.future);

      final invoiceDto = await salesService.repository.getDocument(invoice.id);
      
      if (invoiceDto.lines.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice has no line items')),
        );
        return;
      }

      if (!context.mounted) return;

      final newInvoiceId = await showDialog<String>(
        context: context,
        builder: (context) => CloneAlternativesDialog(
          invoiceId: invoice.id,
          outOfStockItems: invoiceDto.lines
              .map(
                (line) => OutOfStockItem(
                  itemId: line.itemId,
                  itemName: '',
                ),
              )
              .toList(),
          repository: salesService.repository,
        ),
      );

      if (newInvoiceId != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice cloned successfully'),
          ),
        );
        ref.read(saleInvoicesProvider.notifier).refresh();
        await context.push('${AppRoutes.editSale}/$newInvoiceId');
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clone invoice: $error')),
      );
    }
  }
}
