import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';

/// Placeholder for stock transfer until a dedicated mobile flow ships.
class MobileStockTransferPlaceholderPage extends StatelessWidget {
  const MobileStockTransferPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Stock transfer',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Stock transfers between godowns are available on desktop. '
              'Use inventory godowns to review locations until mobile transfer ships.',
              style: AppTypography.inter(fontSize: AppTypography.bodySize, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
