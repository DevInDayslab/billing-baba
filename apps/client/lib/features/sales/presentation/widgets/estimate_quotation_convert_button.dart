import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/estimate_quotation_actions_menu_button.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _convertColor = Color(0xFF1565C0);
const _menuMinWidth = 200.0;
const _menuItemHeight = 40.0;
const _menuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  side: BorderSide(color: Color(0xFFE0E0E0)),
);

class EstimateQuotationConvertButton extends ConsumerWidget {
  const EstimateQuotationConvertButton({
    required this.estimate,
    super.key,
  });

  final SaleInvoiceModel estimate;

  bool get _canConvert =>
      estimate.documentStatus == SalesDocumentStatus.finalized;

  bool get _isConverted =>
      estimate.documentStatus == SalesDocumentStatus.converted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isConverted)
          const Text(
            'Converted',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D32),
            ),
          )
        else if (_canConvert)
          _ConvertMenuButton(estimate: estimate),
        if (_canConvert) const SizedBox(width: 2),
        EstimateQuotationActionsMenuButton(estimate: estimate),
      ],
    );
  }
}

class _ConvertMenuButton extends ConsumerWidget {
  const _ConvertMenuButton({required this.estimate});

  final SaleInvoiceModel estimate;

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
          value: 'convert_to_order',
          height: _menuItemHeight,
          child: Text(
            'Convert to Sale Order',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );

    if (action == null || !context.mounted) return;
    await EstimateQuotationTableActions.handleAction(
      context,
      ref,
      estimate,
      action,
    );
  }

  RelativeRect _menuPosition(BuildContext context) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (buttonContext) {
        return Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => _openMenu(buttonContext, ref),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            hoverColor: const Color(0xFFE3F2FD),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Convert',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _convertColor,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: _convertColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
