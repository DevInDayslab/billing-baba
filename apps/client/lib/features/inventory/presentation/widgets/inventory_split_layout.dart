import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

class InventorySplitLayout extends StatelessWidget {
  const InventorySplitLayout({
    required this.listPanel,
    required this.detailPanel,
    this.listWidthFactor = 0.22,
    this.listWidth,
    super.key,
  });

  final Widget listPanel;
  final Widget detailPanel;
  final double listWidthFactor;

  /// When set, uses a fixed left-panel width instead of [listWidthFactor].
  final double? listWidth;

  static const _minListWidth = 260.0;
  static const _maxListWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedListWidth = listWidth ??
            (constraints.maxWidth * listWidthFactor)
                .clamp(_minListWidth, _maxListWidth);

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
                SizedBox(width: resolvedListWidth, child: listPanel),
                const VerticalDivider(width: 1, color: inventoryCardBorder),
                Expanded(child: detailPanel),
              ],
            ),
          ),
        );
      },
    );
  }
}

class InventoryDetailPlaceholder extends StatelessWidget {
  const InventoryDetailPlaceholder({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: InventoryStyles.emptyStateStyle),
          ],
        ),
      ),
    );
  }
}
