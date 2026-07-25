import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/delete_status_response.dart';
import 'package:flutter/material.dart';

Future<bool?> showPartyDeleteDialog(
  BuildContext context, {
  required String partyName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Party'),
      content: Text(
        'Delete "$partyName"?\n\nThis action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

Future<bool?> showPartyInactiveDialog(
  BuildContext context, {
  required PartyDeleteReferences references,
}) {
  final lines = references.visibleLines;

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Mark Party as Inactive'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This party has existing transactions.\n\n'
              'To preserve invoices, payments, GST reports and accounting '
              'history, the party will be marked as inactive instead of being '
              'permanently deleted.',
            ),
            if (lines.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Linked records',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('• ${line.count} ${line.label}'),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              'Inactive parties',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text('• do not appear in normal searches'),
            const Text('• can be restored later'),
            const Text('• preserve all transaction history'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Mark Inactive'),
        ),
      ],
    ),
  );
}

Future<bool?> showPartyDeleteErrorDialog(
  BuildContext context, {
  required String message,
  bool showRetry = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Unable to Delete'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(showRetry ? 'Cancel' : 'OK'),
        ),
        if (showRetry)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Retry'),
          ),
      ],
    ),
  );
}
