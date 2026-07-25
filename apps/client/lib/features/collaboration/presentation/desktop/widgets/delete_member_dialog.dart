import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<bool?> showDeleteMemberDialog(
  BuildContext context, {
  required String memberName,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _DeleteMemberDialog(memberName: memberName),
  );
}

Future<bool?> showCancelInvitationDialog(
  BuildContext context, {
  required String memberName,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _CancelInvitationDialog(memberName: memberName),
  );
}

class _DeleteMemberDialog extends StatelessWidget {
  const _DeleteMemberDialog({required this.memberName});

  final String memberName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      title: const Text(
        'Remove Access',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: Text(
        'Are you sure you want to remove $memberName? '
        'This user will lose access to this company and will not be able '
        'to view or edit company data.',
        style: const TextStyle(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Remove Access'),
        ),
      ],
    );
  }
}

class _CancelInvitationDialog extends StatelessWidget {
  const _CancelInvitationDialog({required this.memberName});

  final String memberName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      title: const Text(
        'Cancel Invitation',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: Text(
        'Cancel the pending invitation for $memberName? '
        'They will not be able to join until a new invitation is sent.',
        style: const TextStyle(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep Invitation'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cancel Invitation'),
        ),
      ],
    );
  }
}
