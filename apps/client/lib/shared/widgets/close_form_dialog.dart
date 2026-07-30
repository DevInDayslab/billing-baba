import 'package:flutter/material.dart';

/// Shows a confirmation dialog before closing an unsaved form.
///
/// Returns `true` if the user confirms they want to discard changes.
Future<bool> showCloseFormDialog(
  BuildContext context, {
  required String title,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: const Text(
        'Current changes will be discarded. Do you wish to continue?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('OK'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
