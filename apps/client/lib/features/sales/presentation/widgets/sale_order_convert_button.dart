import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_document_actions_menu_button.dart';
import 'package:billing_baba/features/sales/providers/sale_orders_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _convertColor = Color(0xFF1565C0);
const _convertButtonBg = Color(0xFFF5F5F5);
const _convertButtonBorder = Color(0xFFE0E0E0);
const _menuMinWidth = 200.0;
const _menuItemHeight = 40.0;
const _menuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  side: BorderSide(color: Color(0xFFE0E0E0)),
);

class SaleOrderConvertButton extends ConsumerWidget {
  const SaleOrderConvertButton({
    required this.order,
    super.key,
  });

  final SaleInvoiceModel order;

  bool get _canConvert =>
      order.documentStatus == SalesDocumentStatus.finalized;

  bool get _isCompleted =>
      order.documentStatus == SalesDocumentStatus.converted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isCompleted)
          const Flexible(
            child: Text(
              'Converted To Invoice',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _convertColor,
                decoration: TextDecoration.underline,
                decorationColor: _convertColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
        else if (_canConvert)
          _ConvertMenuButton(order: order),
        SaleDocumentActionsMenuButton(
          document: order,
          config: SaleDocumentActionsConfig.saleOrder(
            onEdit: (ctx, _, id) async {
              await ctx.push('${AppRoutes.editSaleOrder}/$id');
            },
          ),
        ),
      ],
    );
  }
}

class _ConvertMenuButton extends ConsumerWidget {
  const _ConvertMenuButton({required this.order});

  final SaleInvoiceModel order;

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
      items: const [
        PopupMenuItem<String>(
          value: 'convert_to_sale',
          height: _menuItemHeight,
          child: Text(
            'Convert to Sale',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
        PopupMenuItem<String>(
          value: 'convert_to_challan',
          height: _menuItemHeight,
          child: Text(
            'Convert to Delivery Challan',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );

    if (action == null || !context.mounted) return;
    await SaleOrderTableActions.handleAction(context, ref, order, action);
  }

  RelativeRect _menuPosition(BuildContext context) {
    final buttonBox = context.findRenderObject()! as RenderBox;
    final overlayBox =
        Overlay.of(context, rootOverlay: true).context.findRenderObject()!
            as RenderBox;

    final buttonOrigin =
        buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final buttonSize = buttonBox.size;

    final menuLeft = (buttonOrigin.dx + buttonSize.width - _menuMinWidth)
        .clamp(0.0, overlayBox.size.width - _menuMinWidth);
    final menuTop = buttonOrigin.dy + buttonSize.height + 4;

    return RelativeRect.fromLTRB(
      menuLeft,
      menuTop,
      overlayBox.size.width - menuLeft - _menuMinWidth,
      overlayBox.size.height - menuTop,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (buttonContext) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openMenu(buttonContext, ref),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _convertButtonBg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: _convertButtonBorder),
              ),
              child: const Text(
                'CONVERT TO SALE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _convertColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SaleOrderTableActions {
  const SaleOrderTableActions._();

  static Future<void> handleAction(
    BuildContext context,
    WidgetRef ref,
    SaleInvoiceModel order,
    String action,
  ) async {
    final notifier = ref.read(saleOrdersProvider.notifier);
    String? error;

    switch (action) {
      case 'convert_to_sale':
        error = await notifier.convertOrder(
          order.id,
          targetType: 'tax_invoice',
        );
        if (error == null && context.mounted) {
          context.go(AppRoutes.saleInvoices);
        }
      case 'convert_to_challan':
        error = await notifier.convertOrder(
          order.id,
          targetType: 'delivery_challan',
        );
        if (error == null && context.mounted) {
          context.go(AppRoutes.saleDeliveryChallan);
        }
    }

    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}
