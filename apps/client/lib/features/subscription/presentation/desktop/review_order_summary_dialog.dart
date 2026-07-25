import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_flow.dart';
import 'package:billing_baba/features/subscription/application/subscription_error_mapper.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/review_order_summary_input.dart';
import 'package:billing_baba/features/subscription/presentation/providers/create_order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Shows the Vyapar-style Review Order Summary before payment.
Future<void> showReviewOrderSummaryDialog(
  BuildContext context,
  WidgetRef ref, {
  required ReviewOrderSummaryInput input,
  VoidCallback? onBack,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ReviewOrderSummaryDialog(
        input: input,
        onBack: onBack ?? () => Navigator.of(dialogContext).pop(),
        onCompletePurchase: () async {
          final navigator = Navigator.of(dialogContext);
          final rootNavigator = Navigator.of(dialogContext, rootNavigator: true);

          final order = await ref
              .read(createOrderControllerProvider.notifier)
              .createOrder(input.planType);
          if (!dialogContext.mounted) return;

          final error =
              ref.read(createOrderControllerProvider.notifier).errorMessage();
          if (error != null) {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(
                content: Text(error),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          if (order == null) return;

          navigator.pop();
          if (!rootNavigator.mounted) return;

          await SubscriptionCheckoutFlow.startFromOrder(
            rootNavigator.context,
            ref,
            order: order,
            planType: input.planType,
          );
        },
      ),
    ),
  );
}

class ReviewOrderSummaryDialog extends ConsumerStatefulWidget {
  const ReviewOrderSummaryDialog({
    required this.input,
    required this.onBack,
    required this.onCompletePurchase,
    super.key,
  });

  final ReviewOrderSummaryInput input;
  final VoidCallback onBack;
  final Future<void> Function() onCompletePurchase;

  @override
  ConsumerState<ReviewOrderSummaryDialog> createState() =>
      _ReviewOrderSummaryDialogState();
}

class _ReviewOrderSummaryDialogState
    extends ConsumerState<ReviewOrderSummaryDialog> {
  static final _priceFormat = NumberFormat('#,##0.##', 'en_IN');
  var _isPurchasing = false;
  final _gstinController = TextEditingController();

  String _formatPrice(double price) => '₹${_priceFormat.format(price)}';

  @override
  void dispose() {
    _gstinController.dispose();
    super.dispose();
  }

  Future<void> _handleCompletePurchase() async {
    if (_isPurchasing) return;
    setState(() => _isPurchasing = true);
    try {
      await widget.onCompletePurchase();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(SubscriptionErrorMapper.messageFor(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.input;
    final isGold = input.planType == SubscriptionPlanType.gold;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(
              onBack: widget.onBack,
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SelectedPlanCard(input: input, isGold: isGold),
                    const SizedBox(height: AppSpacing.md),
                    _PriceBreakdown(
                      input: input,
                      formatPrice: _formatPrice,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CouponPlaceholder(),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _gstinController,
                      decoration: InputDecoration(
                        labelText: 'GSTIN (optional)',
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.mdBorder,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _formatPrice(input.discountedPrice),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isPurchasing ? null : _handleCompletePurchase,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 4,
                    ),
                  ),
                  child: _isPurchasing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Complete Purchase'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.onBack,
    required this.onClose,
  });

  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              'Review Order Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SelectedPlanCard extends StatelessWidget {
  const _SelectedPlanCard({
    required this.input,
    required this.isGold,
  });

  final ReviewOrderSummaryInput input;
  final bool isGold;

  static const _goldIconBg = Color(0xFFFFF3E0);
  static const _goldIconColor = Color(0xFFE65100);
  static const _platinumBg = Color(0xFFF3F0FF);
  static const _platinumIconBg = Color(0xFFEDE7F6);
  static const _platinumIconColor = Color(0xFF5E35B1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isGold ? AppColors.surface : _platinumBg,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: isGold ? Colors.grey.shade300 : const Color(0xFFB39DDB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isGold ? _goldIconBg : _platinumIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGold ? Icons.change_history : Icons.flag_outlined,
                  color: isGold ? _goldIconColor : _platinumIconColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                input.planName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(label: 'Duration', value: input.platformDurationLabel),
          _DetailRow(label: 'License Type', value: input.licenseType),
          _DetailRow(
            label: 'Device Access',
            value: '${input.deviceLimit} devices',
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
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({
    required this.input,
    required this.formatPrice,
  });

  final ReviewOrderSummaryInput input;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Plan Price',
            value: formatPrice(input.taxableAmount),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'GST (18%)',
            value: formatPrice(input.gstAmount),
          ),
          if (input.discountAmount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              label: 'Discount',
              value: '- ${formatPrice(input.discountAmount)}',
              valueColor: const Color(0xFF2E7D32),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CouponPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Have a coupon code?',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
