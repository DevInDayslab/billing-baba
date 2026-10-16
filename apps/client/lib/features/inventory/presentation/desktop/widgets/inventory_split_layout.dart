import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

/// Reference split for Products/Services list vs detail (responsive flex).
const inventoryListPanelFlex = 573;
const inventoryDetailPanelFlex = 1986;

/// Parties list pane (same flex ratio as inventory list/detail split).
const partyListPanelFlex = inventoryListPanelFlex;
const partyDetailPanelFlex = inventoryDetailPanelFlex;

class InventorySplitLayout extends StatelessWidget {
  const InventorySplitLayout({
    required this.listPanel,
    required this.detailPanel,
    this.listFlex = inventoryListPanelFlex,
    this.detailFlex = inventoryDetailPanelFlex,
    super.key,
  });

  final Widget listPanel;
  final Widget detailPanel;
  final int listFlex;
  final int detailFlex;

  @override
  Widget build(BuildContext context) {
    final border = inventoryWorkspacePanelBorderWidth;
    final innerRadius = inventoryWorkspacePanelInnerRadius();

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.workspacePanelBorder,
          borderRadius: inventoryWorkspacePanelOuterRadius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(border),
        child: ClipRRect(
          borderRadius: innerRadius,
          child: ColoredBox(
            color: AppColors.surface,
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: listFlex,
                child: _SplitPaneChrome(
                  borderOnRight: true,
                  child: listPanel,
                ),
              ),
              Expanded(flex: detailFlex, child: detailPanel),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a split edge in the gutter color without shrinking the pane’s flex size.
class _SplitPaneChrome extends StatelessWidget {
  const _SplitPaneChrome({
    required this.child,
    this.borderOnRight = false,
    this.borderOnTop = false,
  });

  final Widget child;
  final bool borderOnRight;
  final bool borderOnTop;

  @override
  Widget build(BuildContext context) {
    final border = inventoryWorkspacePanelBorderWidth;
    final edge = AppColors.workspacePanelBorder;

    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: borderOnRight ? border : 0,
            top: borderOnTop ? border : 0,
          ),
          child: child,
        ),
        if (borderOnRight)
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: border,
            child: ColoredBox(color: edge),
          ),
        if (borderOnTop)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: border,
            child: ColoredBox(color: edge),
          ),
      ],
    );
  }
}

/// Horizontal split between detail summary and transactions (inset, no overlap).
class InventoryWorkspaceDetailSplit extends StatelessWidget {
  const InventoryWorkspaceDetailSplit({
    required this.header,
    required this.body,
    super.key,
  });

  final Widget header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: _SplitPaneChrome(borderOnTop: true, child: body),
        ),
      ],
    );
  }
}

class InventoryDetailPlaceholder extends StatelessWidget {
  const InventoryDetailPlaceholder({
    required this.message,
    this.icon = Icons.inventory_2_outlined,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
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
