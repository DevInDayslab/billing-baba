import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:flutter/material.dart';

enum MobileBackupExportAction { saveToDevice, share }

const _saveBackground = Color(0xFFE8F5E9);
const _saveText = Color(0xFF2E7D32);
const _shareBackground = Color(0xFFE3F2FD);
const _shareText = Color(0xFF1565C0);

/// Vyapar-style export picker for mobile backup files.
Future<MobileBackupExportAction?> showMobileBackupExportSheet({
  required BuildContext context,
}) {
  return showMobileBottomSheet<MobileBackupExportAction>(
    context: context,
    scrollBody: false,
    title: 'Save backup',
    builder: (sheetContext) {
      return _BackupExportSheetBody(
        onSaveToDevice: () => Navigator.of(sheetContext).pop(
          MobileBackupExportAction.saveToDevice,
        ),
        onShare: () => Navigator.of(sheetContext).pop(
          MobileBackupExportAction.share,
        ),
      );
    },
  );
}

class _BackupExportSheetBody extends StatelessWidget {
  const _BackupExportSheetBody({
    required this.onSaveToDevice,
    required this.onShare,
  });

  final VoidCallback onSaveToDevice;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose how you want to export your backup file.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _BackupExportButton(
                label: 'Save to Device',
                backgroundColor: _saveBackground,
                labelColor: _saveText,
                icon: const Icon(
                  Icons.save_alt_rounded,
                  color: _saveText,
                  size: 26,
                ),
                onTap: onSaveToDevice,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _BackupExportButton(
                label: 'Share',
                backgroundColor: _shareBackground,
                labelColor: _shareText,
                icon: const Icon(
                  Icons.ios_share_rounded,
                  color: _shareText,
                  size: 26,
                ),
                onTap: onShare,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BackupExportButton extends StatelessWidget {
  const _BackupExportButton({
    required this.label,
    required this.backgroundColor,
    required this.labelColor,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color labelColor;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: icon,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
