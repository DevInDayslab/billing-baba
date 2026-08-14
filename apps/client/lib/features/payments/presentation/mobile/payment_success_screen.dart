import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    required this.amountPaise,
    this.paymentId,
    this.onPrint,
    this.onShare,
    super.key,
  });

  final int amountPaise;
  final String? paymentId;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final amount = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(amountPaise / 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Payment successful',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.check_circle_rounded, size: 72, color: AppColors.success),
            const SizedBox(height: AppSpacing.lg),
            Text(
              amount,
              textAlign: TextAlign.center,
              style: AppTypography.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (paymentId != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Payment ID: $paymentId',
                textAlign: TextAlign.center,
                style: AppTypography.inter(
                  fontSize: AppTypography.captionSize,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const Spacer(),
            if (onPrint != null)
              FilledButton.icon(
                onPressed: onPrint,
                icon: const Icon(Icons.print_rounded),
                label: const Text('Print receipt'),
              ),
            if (onShare != null) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share receipt'),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
