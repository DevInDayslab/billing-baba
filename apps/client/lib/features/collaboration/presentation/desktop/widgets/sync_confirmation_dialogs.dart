import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<bool?> showDisableSyncDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _DisableSyncDialog(),
  );
}

Future<bool?> showLogoutSyncDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _LogoutSyncDialog(),
  );
}

class _DisableSyncDialog extends StatelessWidget {
  const _DisableSyncDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      title: const Text(
        'Disable Sync',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: const Text(
        'Cloud sync will be disabled. No uploads or downloads will run until '
        'you enable sync again.',
        style: TextStyle(color: AppColors.textSecondary, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Disable Sync'),
        ),
      ],
    );
  }
}

class _LogoutSyncDialog extends StatelessWidget {
  const _LogoutSyncDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      title: const Text(
        'Logout from Sync',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: const Text(
        'This device will be logged out from cloud sync. Tokens and device '
        'registration will be cleared on the backend once connected.',
        style: TextStyle(color: AppColors.textSecondary, height: 1.5),
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
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
