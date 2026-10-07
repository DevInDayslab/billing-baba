import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/adjust_stock_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showAdjustStockDialog(
  BuildContext context, {
  required InventoryItem item,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: AdjustStockDialog(item: item),
    ),
  );
}

class AdjustStockDialog extends ConsumerWidget {
  const AdjustStockDialog({required this.item, super.key});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = MediaQuery.of(context);
    final maxDialogHeight = (media.size.height - media.viewInsets.bottom) * 0.9;
    final maxDialogWidth = math.min<double>(media.size.width * 0.92, 1080);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxDialogWidth,
        maxHeight: maxDialogHeight,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: AdjustStockForm(
          item: item,
          variant: AdjustStockFormVariant.desktop,
          onClose: () => Navigator.of(context).pop(),
          onSuccess: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Stock updated. Changes will sync when online.',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
