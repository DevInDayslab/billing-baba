import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

class InventorySplitLayout extends StatelessWidget {
  const InventorySplitLayout({
    required this.listPanel,
    required this.detailPanel,
    this.listWidth = 360,
    super.key,
  });

  final Widget listPanel;
  final Widget detailPanel;
  final double listWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: inventoryCardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lgBorder,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: listWidth, child: listPanel),
            const VerticalDivider(width: 1, color: inventoryCardBorder),
            Expanded(child: detailPanel),
          ],
        ),
      ),
    );
  }
}

class InventoryDetailPlaceholder extends StatelessWidget {
  const InventoryDetailPlaceholder({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: InventoryStyles.emptyStateStyle),
    );
  }
}
