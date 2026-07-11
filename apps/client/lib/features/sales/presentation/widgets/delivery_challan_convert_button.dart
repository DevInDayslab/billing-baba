import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/delivery_challan_actions_menu_button.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _convertColor = Color(0xFF1565C0);
const _convertButtonBg = Color(0xFFF5F5F5);
const _convertButtonBorder = Color(0xFFE0E0E0);

class DeliveryChallanConvertButton extends ConsumerWidget {
  const DeliveryChallanConvertButton({
    required this.challan,
    super.key,
  });

  final SaleInvoiceModel challan;

  bool get _canConvert =>
      challan.documentStatus == SalesDocumentStatus.finalized;

  bool get _isConverted =>
      challan.documentStatus == SalesDocumentStatus.converted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isConverted)
          Flexible(
            child: Text(
              'Converted To Sale',
              style: const TextStyle(
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => DeliveryChallanTableActions.handleAction(
                context,
                ref,
                challan,
                'convert_to_sale',
              ),
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
          ),
        DeliveryChallanActionsMenuButton(challan: challan),
      ],
    );
  }
}
