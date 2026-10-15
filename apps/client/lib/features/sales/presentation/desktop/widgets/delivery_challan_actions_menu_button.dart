import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/application/delivery_challan_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/delivery_challan_goods_return_convert_dialog.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/features/settings/application/general_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _menuMinWidth = 220.0;
const _menuItemHeight = 40.0;
const _menuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  side: BorderSide(color: Color(0xFFE0E0E0)),
);

class DeliveryChallanActionsMenuButton extends ConsumerWidget {
  const DeliveryChallanActionsMenuButton({
    required this.challan,
    super.key,
  });

  final SaleInvoiceModel challan;

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
      items: DeliveryChallanTableActions.buildMenuItems(challan),
    );

    if (action == null || !context.mounted) return;
    await DeliveryChallanTableActions.handleAction(
      context,
      ref,
      challan,
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

class DeliveryChallanTableActions {
  const DeliveryChallanTableActions._();

  static List<PopupMenuEntry<String>> buildMenuItems(
    SaleInvoiceModel challan,
  ) {
    final canConvert = challan.documentStatus == SalesDocumentStatus.finalized;

    return [
      _menuItem('view_edit', 'View/Edit'),
      if (canConvert) _menuItem('convert_to_sale', 'Convert to Sale'),
      _menuItem('open_pdf', 'Open PDF'),
      _menuItem('preview', 'Preview'),
      _menuItem('print', 'Print'),
      if (!challan.isDraft && !challan.isCancelled)
        _menuItem('cancel', 'Cancel'),
      _menuItem('delete', 'Delete'),
      if (challan.isDraft) _menuItem('finalize', 'Finalize'),
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
    SaleInvoiceModel challan,
    String action,
  ) async {
    final notifier = ref.read(deliveryChallansProvider.notifier);
    final filename = DocumentPrintActions.filenameFor(challan.invoiceNo);

    switch (action) {
      case 'view_edit':
        await context.push('${AppRoutes.editDeliveryChallan}/${challan.id}');
      case 'convert_to_sale':
        await _convert(context, ref, notifier, challan.id);
      case 'cancel':
        await _confirmCancel(context, challan, notifier);
      case 'delete':
        await _confirmDelete(context, challan, notifier);
      case 'open_pdf':
      case 'preview':
        await DocumentPrintActions.preview(
          context,
          ref,
          PrintRequest.deliveryChallan(challan.id),
          filename: filename,
        );
      case 'print':
        await DocumentPrintActions.print(
          context,
          ref,
          PrintRequest.deliveryChallan(challan.id),
          filename: filename,
        );
      case 'finalize':
        final error = await notifier.finalizeChallan(challan.id);
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
    WidgetRef ref,
    DeliveryChallans notifier,
    String documentId,
  ) async {
    final goodsReturn =
        ref.read(deliveryChallanGoodsReturnEnabledProvider);
    ChallanBillQtyByItemId? billQtyByItemId;
    if (goodsReturn) {
      billQtyByItemId = await showDeliveryChallanGoodsReturnConvertDialog(
        context: context,
        ref: ref,
        challanDocumentId: documentId,
      );
      if (billQtyByItemId == null || !context.mounted) return;
    }

    final result = await notifier.convertChallanToSale(
      documentId,
      billQtyByItemId: billQtyByItemId,
    );
    if (!context.mounted) return;
    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delivery challan converted to sale')),
    );
    if (!context.mounted) return;
    final saleId = result.saleDocumentId;
    if (goodsReturn && saleId != null) {
      context.push('${AppRoutes.editSale}/$saleId');
    } else {
      context.go(AppRoutes.saleInvoices);
    }
  }

  static Future<void> _confirmCancel(
    BuildContext context,
    SaleInvoiceModel challan,
    DeliveryChallans notifier,
  ) async {
    if (challan.isDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only finalized challans can be cancelled'),
        ),
      );
      return;
    }
    if (challan.isCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This challan is already cancelled')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel delivery challan?'),
        content: Text('Cancel challan ${challan.invoiceNo}?'),
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

    final error = await notifier.cancelChallan(challan.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Challan ${challan.invoiceNo} cancelled')),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    SaleInvoiceModel challan,
    DeliveryChallans notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete delivery challan?'),
        content: Text('Delete challan ${challan.invoiceNo}?'),
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

    final error = await notifier.deleteChallan(challan.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Challan ${challan.invoiceNo} deleted')),
    );
  }
}
