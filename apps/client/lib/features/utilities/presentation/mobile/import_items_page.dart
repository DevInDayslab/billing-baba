import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileImportItemsPage extends StatelessWidget {
  const MobileImportItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Import items',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bulk add inventory items using barcode scanning or paste.',
              style: AppTypography.inter(fontSize: AppTypography.bodySize, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.utilitiesAddItemsBarcode),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: const Text('Open barcode import'),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.items),
              icon: const Icon(Icons.inventory_2_outlined, size: 18),
              label: const Text('Browse inventory'),
            ),
          ],
        ),
      ),
    );
  }
}
