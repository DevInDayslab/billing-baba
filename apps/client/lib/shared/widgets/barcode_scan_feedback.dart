import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared snackbars for barcode scan outcomes on POS / invoice surfaces.
void showBarcodeNotFoundSnackBar(BuildContext context, [String? barcode]) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final suffix = (barcode != null && barcode.isNotEmpty) ? ' ($barcode)' : '';
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('No item found for this barcode$suffix'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
}

void showBarcodeAddedSnackBar(BuildContext context, String itemName) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Added $itemName'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
}
