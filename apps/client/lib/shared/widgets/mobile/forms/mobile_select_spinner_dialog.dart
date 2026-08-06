import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shows a compact, dropdown/spinner-style dialog for searchable selection.
Future<T?> showMobileSelectSpinnerDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxHeightFraction = 0.72,
  double maxWidth = 420,
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      final media = MediaQuery.of(dialogContext);
      final maxHeight = media.size.height * maxHeightFraction;
      final width = media.size.width < maxWidth + 48
          ? media.size.width - 48
          : maxWidth;

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: width,
          height: maxHeight,
          child: Material(
            color: AppColors.surface,
            child: builder(dialogContext),
          ),
        ),
      );
    },
  );
}

/// Shared title row for select-spinner dialogs.
class MobileSelectSpinnerHeader extends StatelessWidget {
  const MobileSelectSpinnerHeader({
    required this.title,
    required this.onClose,
    super.key,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.inter(
                fontSize: AppTypography.titleSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
