import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _secondaryButtonBg = Color(0xFFF2F2F2);

enum SaleInvoiceCancelDialogResult { confirm, dismissed }

/// Shows the cancel-invoice confirmation modal.
Future<SaleInvoiceCancelDialogResult?> showSaleInvoiceCancelDialog(
  BuildContext context,
) {
  return showDialog<SaleInvoiceCancelDialogResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SaleInvoiceCancelDialog(),
    ),
  );
}

class SaleInvoiceCancelDialog extends StatelessWidget {
  const SaleInvoiceCancelDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Text(
                    'Cancel Invoice',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(
                      SaleInvoiceCancelDialogResult.dismissed,
                    ),
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Close',
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: _cardBorder),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Text(
                'Are you sure you want to cancel the invoice? '
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1, color: _cardBorder),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _DialogActionButton(
                    label: 'Cancel Invoice',
                    backgroundColor: _secondaryButtonBg,
                    foregroundColor: AppColors.textPrimary,
                    onPressed: () => Navigator.of(context).pop(
                      SaleInvoiceCancelDialogResult.confirm,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _DialogActionButton(
                    label: 'Close',
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    onPressed: () => Navigator.of(context).pop(
                      SaleInvoiceCancelDialogResult.dismissed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
