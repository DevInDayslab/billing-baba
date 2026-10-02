import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mobile entry for POS terminal — redirects to the main POS route.
class MobilePosTerminalView extends StatelessWidget {
  const MobilePosTerminalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'POS terminal',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.point_of_sale_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Open the POS billing screen to start selling.',
                textAlign: TextAlign.center,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodySize,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.pos),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open POS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
