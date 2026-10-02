import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/subscription/application/current_subscription_provider.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mobile placeholder for subscription payment — opens website checkout.
class MobileSubscriptionPaymentPlaceholder extends ConsumerWidget {
  const MobileSubscriptionPaymentPlaceholder({super.key});

  Future<void> _openWebsite(BuildContext context) async {
    final uri = Uri.parse(AppConfig.websiteUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open website')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(currentSubscriptionStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Subscription',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            subscriptionAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(error.toString()),
              data: (subscription) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current plan',
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        subscription.planName,
                        style: AppTypography.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subscription.expiresAt != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Expires ${subscription.expiresAt!.toLocal()}',
                          style: AppTypography.inter(
                            fontSize: AppTypography.captionSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Upgrade or renew your subscription on the Billing Baba website.',
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => _openWebsite(context),
              icon: const Icon(Icons.open_in_browser_rounded, size: 18),
              label: const Text('Open billingbaba.com'),
            ),
          ],
        ),
      ),
    );
  }
}
