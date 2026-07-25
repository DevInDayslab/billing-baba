import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/application/estimate_quotation_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _menuMinWidth = 220.0;
const _menuItemHeight = 40.0;
const _menuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  side: BorderSide(color: Color(0xFFE0E0E0)),
);

class EstimateQuotationActionsMenuButton extends ConsumerWidget {
  const EstimateQuotationActionsMenuButton({
    required this.estimate,
    super.key,
  });

  final SaleInvoiceModel estimate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (buttonContext) {
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          tooltip: 'More',
          icon: const Icon(
            Icons.more_vert,
            size: 18,
            color: AppColors.textSecondary,
          ),
          onPressed: () => _openMenu(buttonContext, ref),
        );
      },
    );
  }

  Future<void> _openMenu(BuildContext context, WidgetRef ref) async {
    final action = await showMenu<String>(
      context: context,
      useRootNavigator: true,
      position: _menuPosition(context),
      color: AppColors.surface,
      shadowColor: Colors.black26,
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      shape: _menuShape,
      constraints: const BoxConstraints(minWidth: _menuMinWidth),
      items: EstimateQuotationTableActions.buildMenuItems(estimate),
    );

    if (action == null || !context.mounted) return;
    await EstimateQuotationTableActions.handleAction(
      context,
      ref,
      estimate,
      action,
    );
  }

  static RelativeRect _menuPosition(BuildContext context) {
    final buttonBox = context.findRenderObject()! as RenderBox;
    final overlayBox =
        Overlay.of(context, rootOverlay: true).context.findRenderObject()!
            as RenderBox;

    final buttonOrigin = buttonBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final buttonSize = buttonBox.size;

    final menuLeft = (buttonOrigin.dx + buttonSize.width - _menuMinWidth).clamp(
      0.0,
      overlayBox.size.width - _menuMinWidth,
    );
    final menuTop = buttonOrigin.dy + buttonSize.height + 4;

    return RelativeRect.fromLTRB(
      menuLeft,
      menuTop,
      overlayBox.size.width - menuLeft - _menuMinWidth,
      overlayBox.size.height - menuTop,
    );
  }
}

class EstimateQuotationTableActions {
  const EstimateQuotationTableActions._();

  static List<PopupMenuEntry<String>> buildMenuItems(
    SaleInvoiceModel estimate,
  ) {
    final canConvert = estimate.documentStatus == SalesDocumentStatus.finalized;

    return [
      _menuItem('view_edit', 'View/Edit'),
      if (canConvert)
        _menuItem('convert_to_challan', 'Convert to Delivery Challan'),
      _menuItem('duplicate', 'Duplicate'),
      _menuItem('open_pdf', 'Open PDF'),
      _menuItem('preview', 'Preview'),
      _menuItem('print', 'Print'),
      if (!estimate.isDraft && !estimate.isCancelled)
        _menuItem('cancel', 'Cancel'),
      _menuItem('delete', 'Delete'),
      if (estimate.isDraft) _menuItem('finalize', 'Finalize'),
    ];
  }

  static PopupMenuItem<String> _menuItem(String value, String label) {
    return PopupMenuItem<String>(
      value: value,
      height: _menuItemHeight,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  static Future<void> handleAction(
    BuildContext context,
    WidgetRef ref,
    SaleInvoiceModel estimate,
    String action,
  ) async {
    final notifier = ref.read(estimateQuotationsProvider.notifier);
    final filename = DocumentPrintActions.filenameFor(estimate.invoiceNo);

    switch (action) {
      case 'view_edit':
        await context.push('${AppRoutes.editEstimate}/${estimate.id}');
      case 'convert_to_sale':
        await _convert(context, notifier, estimate.id, 'tax_invoice');
      case 'convert_to_order':
        await _convert(context, notifier, estimate.id, 'sale_order');
      case 'convert_to_challan':
        await _convert(context, notifier, estimate.id, 'delivery_challan');
      case 'duplicate':
        await context.push(
          '${AppRoutes.duplicateEstimate}/${estimate.id}',
        );
      case 'cancel':
        await _confirmCancel(context, estimate, notifier);
      case 'delete':
        await _confirmDelete(context, estimate, notifier);
      case 'open_pdf':
      case 'preview':
        await DocumentPrintActions.preview(
          context,
          ref,
          PrintRequest.estimate(estimate.id),
          filename: filename,
        );
      case 'print':
        await DocumentPrintActions.print(
          context,
          ref,
          PrintRequest.estimate(estimate.id),
          filename: filename,
        );
      case 'finalize':
        final error = await notifier.finalizeEstimate(estimate.id);
        if (!context.mounted) return;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
    }
  }

  static Future<void> _convert(
    BuildContext context,
    EstimateQuotations notifier,
    String documentId,
    String targetType,
  ) async {
    final error = await notifier.convertEstimate(
      documentId,
      targetType: targetType,
    );
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    final message = switch (targetType) {
      'tax_invoice' => 'Estimate converted to sale',
      'sale_order' => 'Estimate converted to sale order',
      'delivery_challan' => 'Estimate converted to delivery challan',
      _ => 'Estimate converted successfully',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    final route = switch (targetType) {
      'tax_invoice' => AppRoutes.saleInvoices,
      'sale_order' => AppRoutes.saleOrder,
      'delivery_challan' => AppRoutes.saleDeliveryChallan,
      _ => null,
    };
    if (route != null && context.mounted) {
      context.go(route);
    }
  }

  static Future<void> _confirmCancel(
    BuildContext context,
    SaleInvoiceModel estimate,
    EstimateQuotations notifier,
  ) async {
    if (estimate.isDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only finalized estimates can be cancelled'),
        ),
      );
      return;
    }
    if (estimate.isCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This estimate is already cancelled')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel estimate?'),
        content: Text('Cancel estimate ${estimate.invoiceNo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await notifier.cancelEstimate(estimate.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estimate ${estimate.invoiceNo} cancelled')),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    SaleInvoiceModel estimate,
    EstimateQuotations notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete estimate?'),
        content: Text('Delete estimate ${estimate.invoiceNo}?'),
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

    final error = await notifier.deleteEstimate(estimate.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estimate ${estimate.invoiceNo} deleted')),
    );
  }
}
