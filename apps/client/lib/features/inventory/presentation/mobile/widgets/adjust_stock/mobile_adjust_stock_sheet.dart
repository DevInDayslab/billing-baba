import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/adjust_stock_form.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Mobile bottom sheet for adjusting product stock.
Future<void> showMobileAdjustStockSheet(
  BuildContext context, {
  required InventoryItem item,
}) {
  return showMobileBottomSheet<void>(
    context: context,
    maxHeightFraction: 0.92,
    titleWidget: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adjust Stock',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          item.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
    builder: (sheetContext) {
      return SingleChildScrollView(
        child: AdjustStockForm(
          item: item,
          onSuccess: () {
            Navigator.of(sheetContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stock updated. Changes will sync when online.'),
              ),
            );
          },
        ),
      );
    },
  );
}
