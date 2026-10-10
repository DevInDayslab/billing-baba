import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Sale invoices workspace frame width (inventory items use 9px).
const saleInvoicesWorkspaceBorderWidth = 5.0;

/// Matches the inner clip, which only rounds the right edge.
const saleInvoicesWorkspaceOuterRadius = BorderRadius.only(
  topRight: Radius.circular(AppRadius.lg),
  bottomRight: Radius.circular(AppRadius.lg),
);

BorderRadius _saleInvoicesWorkspaceInnerRadius() {
  final inner = AppRadius.lg - saleInvoicesWorkspaceBorderWidth;
  if (inner <= 0) return BorderRadius.zero;
  return BorderRadius.only(
    topRight: Radius.circular(inner),
    bottomRight: Radius.circular(inner),
  );
}

/// Full-bleed workspace chrome from below the page title through the bottom edge.
class SaleInvoicesWorkspaceFrame extends StatelessWidget {
  const SaleInvoicesWorkspaceFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.workspacePanelBorder,
        borderRadius: saleInvoicesWorkspaceOuterRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(saleInvoicesWorkspaceBorderWidth),
        child: ClipRRect(
          borderRadius: _saleInvoicesWorkspaceInnerRadius(),
          child: ColoredBox(
            color: AppColors.surface,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Horizontal rule inside the sale invoices workspace.
class SaleInvoicesWorkspaceGutter extends StatelessWidget {
  const SaleInvoicesWorkspaceGutter({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.workspacePanelBorder,
      child: const SizedBox(
        height: saleInvoicesWorkspaceBorderWidth,
        width: double.infinity,
      ),
    );
  }
}
