import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/barcode_import_provider.dart';
import 'package:flutter/material.dart';

const _errorRed = Color(0xFFC62828);
const _errorBackground = Color(0xFFFFEBEE);
const _cardBorder = Color(0xFFE0E0E0);

/// Shown when barcode import rows are missing required fields before save.
class BarcodeSaveErrorDialog extends StatelessWidget {
  const BarcodeSaveErrorDialog({
    required this.errorRows,
    super.key,
  });

  final List<BarcodeImportRow> errorRows;

  @override
  Widget build(BuildContext context) {
    final count = errorRows.length;

    return AlertDialog(
      title: const Text(
        'Items with Error',
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$count item(s) are missing an Item Name and will be skipped.',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyMediumSize,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: errorRows.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final row = errorRows[index];
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: _errorBackground,
                      border: const Border(
                        left: BorderSide(color: _errorRed, width: 3),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Row ${row.index + 1}',
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: AppTypography.bodySmallSize,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              row.barcode.isNotEmpty
                                  ? row.barcode
                                  : '(no barcode)',
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: AppTypography.bodySmallSize,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: _cardBorder),
          ),
          child: const Text(
            'Check for Errors Again',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: _errorRed,
          ),
          child: const Text(
            'Ignore Errors & Save',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
