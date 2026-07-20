import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Blocks interaction and shows progress while a purchase/expense form is busy.
///
/// [isLoading] shows a lightweight loading veil (e.g. while editing data loads).
/// [isSaving] shows a richer save overlay that absorbs all pointer events.
class TransactionFormBusyOverlay extends StatelessWidget {
  const TransactionFormBusyOverlay({
    required this.isLoading,
    required this.isSaving,
    required this.savingLabel,
    this.savingSubtitle = 'Please wait while your changes are saved.',
    super.key,
  });

  final bool isLoading;
  final bool isSaving;
  final String savingLabel;
  final String savingSubtitle;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && !isSaving) {
      return const SizedBox.shrink();
    }

    if (isSaving) {
      return TransactionFormSaveOverlay(
        label: savingLabel,
        subtitle: savingSubtitle,
      );
    }

    return const AbsorbPointer(
      child: ColoredBox(
        color: Color(0x1F000000),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Full-screen veil shown while a transaction form is being saved.
class TransactionFormSaveOverlay extends StatelessWidget {
  const TransactionFormSaveOverlay({
    required this.label,
    this.subtitle = 'Please wait while your changes are saved.',
    super.key,
  });

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: ColoredBox(
        color: Colors.black26,
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.mdBorder,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
