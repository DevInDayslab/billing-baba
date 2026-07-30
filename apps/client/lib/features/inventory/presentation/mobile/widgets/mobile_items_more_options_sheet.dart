import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_menu_grid_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/features/reports/application/reports_nav_intent_provider.dart';
import 'package:billing_baba/features/reports/models/item_stock_report_subsection.dart';
import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _itemsMoreOptionsSheetHeightFraction = 0.38;

/// Vyapar-style overflow menu for the mobile Items screen (Show All quick link).
Future<void> showMobileItemsMoreOptionsSheet(
  BuildContext context,
  WidgetRef ref,
) {
  void openItemStockReport(ItemStockReportSubSection sub) {
    ref
        .read(reportsNavIntentProvider.notifier)
        .setIntent(ReportsNavIntent.itemStock(sub));
    context.go(AppRoutes.reports);
  }

  void showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  return showMobileMenuGridSheet(
    context: context,
    title: 'More Options',
    heightFraction: _itemsMoreOptionsSheetHeightFraction,
    items: [
      MobileMenuGridItem(
        label: 'Import Items',
        icon: Icons.download_outlined,
        onTap: () => context.push(AppRoutes.utilitiesImportItems),
      ),
      MobileMenuGridItem(
        label: 'Export Items',
        icon: Icons.upload_outlined,
        onTap: () => showComingSoon('Export Items'),
      ),
      MobileMenuGridItem(
        label: 'Item wise PnL',
        icon: Icons.swap_vert_rounded,
        onTap: () =>
            openItemStockReport(ItemStockReportSubSection.itemWiseProfitLoss),
      ),
      MobileMenuGridItem(
        label: 'Additional Fields',
        icon: Icons.add_circle_outline,
        showPremiumBadge: true,
        onTap: () => showComingSoon('Additional Fields'),
      ),
      MobileMenuGridItem(
        label: 'Item Details',
        icon: Icons.view_list_outlined,
        onTap: () => openItemStockReport(ItemStockReportSubSection.itemDetail),
      ),
      MobileMenuGridItem(
        label: 'Low Stock Summary',
        icon: Icons.arrow_circle_down_outlined,
        onTap: () =>
            openItemStockReport(ItemStockReportSubSection.lowStockSummary),
      ),
    ],
  );
}
