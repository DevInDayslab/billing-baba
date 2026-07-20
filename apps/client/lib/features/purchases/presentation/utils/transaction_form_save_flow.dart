import 'package:billing_baba/core/navigation/transaction_detail_navigation.dart';
import 'package:flutter/material.dart';

/// Shows a snackbar when a transaction form save fails.
void showTransactionFormSaveError(BuildContext context, String error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error)),
  );
}

/// Guards against duplicate submissions, runs [save], surfaces errors, then
/// navigates back to the transaction list on success.
Future<void> handleTransactionFormSave({
  required BuildContext context,
  required bool isSaving,
  required Future<String?> Function() save,
  required String listRoute,
}) async {
  if (isSaving) return;

  final error = await save();
  if (!context.mounted) return;

  if (error != null) {
    showTransactionFormSaveError(context, error);
    return;
  }

  returnToTransactionList(context, listRoute);
}

/// Leaves a transaction form, optionally confirming discard of unsaved changes.
///
/// Does nothing while [isSaving] is true so an in-flight save cannot be
/// interrupted by back/cancel navigation.
Future<void> leaveTransactionFormPage({
  required BuildContext context,
  required bool isDirty,
  required bool isSaving,
  required String listRoute,
}) async {
  if (isSaving) return;

  if (isDirty) {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard != true || !context.mounted) return;
  }

  if (!context.mounted) return;
  returnToTransactionList(context, listRoute);
}
