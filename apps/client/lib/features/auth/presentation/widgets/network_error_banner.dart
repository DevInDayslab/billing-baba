import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/network/network_error_details.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Displays classified network errors with optional diagnostics details.
class NetworkErrorBanner extends StatelessWidget {
  const NetworkErrorBanner({
    required this.errorMessage,
    this.networkError,
    super.key,
  });

  final String? errorMessage;
  final NetworkErrorDetails? networkError;

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null && networkError == null) {
      return const SizedBox.shrink();
    }

    final details = networkError;
    final showDetails = AppConfig.showDiagnosticsDetails && details != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            details?.title ?? errorMessage!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (details != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(label: 'Reason', value: details.reason),
            if (details.host != null && details.host!.isNotEmpty)
              _DetailRow(label: 'Host', value: details.host!),
            _DetailRow(label: 'Details', value: details.details),
          ] else if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              errorMessage!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (showDetails) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => _showDetailsDialog(context, details),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View Details',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, NetworkErrorDetails details) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Error'),
        content: SingleChildScrollView(
          child: Text(
            details.summaryLines,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (AppConfig.showDeveloperMenu)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.developerDiagnostics);
              },
              child: const Text('Open Diagnostics'),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, height: 1.4),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
