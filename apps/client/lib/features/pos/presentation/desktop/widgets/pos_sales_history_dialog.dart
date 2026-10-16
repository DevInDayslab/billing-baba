import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_sales_history_panel.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal sales history on the sale screen (POS stays visible underneath).
class PosSalesHistoryDialog extends ConsumerWidget {
  const PosSalesHistoryDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PosSalesHistoryDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
        side: const BorderSide(color: posCardBorder),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          minWidth: 520,
          maxHeight: maxHeight,
          minHeight: 360,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.history,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Sales history',
                    style: PosStyles.panelTitleStyle,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Expanded(child: PosSalesHistoryPanel()),
          ],
        ),
      ),
    );
  }
}
