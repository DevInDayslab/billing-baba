import 'package:billing_baba/core/network/offline_utils.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Compact banner shown when a section is displaying cached or local data.
class OfflineStatusBanner extends StatelessWidget {
  const OfflineStatusBanner({
    this.message = OfflineMessages.showingCachedData,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 16, color: Colors.orange.shade900),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-area empty state when offline and no cached data is available.
class OfflineConnectPrompt extends StatelessWidget {
  const OfflineConnectPrompt({this.onRetry, super.key});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              OfflineMessages.connectToInternet,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wraps [child] with an offline banner when [showBanner] is true.
class OfflineBannerScope extends StatelessWidget {
  const OfflineBannerScope({
    required this.showBanner,
    required this.child,
    this.message = OfflineMessages.showingCachedData,
    super.key,
  });

  final bool showBanner;
  final Widget child;
  final String message;

  @override
  Widget build(BuildContext context) {
    if (!showBanner) return child;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OfflineStatusBanner(message: message),
        Expanded(child: child),
      ],
    );
  }
}
