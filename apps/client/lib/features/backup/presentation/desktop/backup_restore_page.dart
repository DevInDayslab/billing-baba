import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/backup/application/backup_service.dart';
import 'package:billing_baba/features/backup/data/backup_importer.dart';
import 'package:billing_baba/features/backup/presentation/mobile/mobile_backup_export_sheet.dart';
import 'package:billing_baba/shared/utils/platform_file_output.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class BackupRestorePage extends ConsumerStatefulWidget {
  const BackupRestorePage({this.embedded = false, super.key});

  final bool embedded;

  @override
  ConsumerState<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends ConsumerState<BackupRestorePage> {
  bool _busy = false;
  String? _statusMessage;

  Future<void> _exportBackup() async {
    setState(() {
      _busy = true;
      _statusMessage = null;
    });
    try {
      final service = await ref.read(backupServiceProvider.future);
      final result = await service.exportBackup();
      if (PlatformFileOutput.isMobile) {
        if (!mounted) return;
        setState(() => _busy = false);

        final action = await showMobileBackupExportSheet(context: context);
        if (!mounted || action == null) {
          setState(() => _statusMessage = 'Export cancelled');
          return;
        }

        setState(() => _busy = true);
        switch (action) {
          case MobileBackupExportAction.saveToDevice:
            final path = await PlatformFileOutput.saveToDevice(
              filename: result.suggestedFilename,
              bytes: result.bytes,
              extension: 'biba',
            );
            if (!mounted) return;
            setState(() {
              _statusMessage = path == null
                  ? 'Export cancelled'
                  : 'Backup saved to $path';
            });
          case MobileBackupExportAction.share:
            await PlatformFileOutput.shareFromTemp(
              filename: result.suggestedFilename,
              bytes: result.bytes,
              mimeType: 'application/zip',
              extension: 'biba',
            );
            if (!mounted) return;
            setState(() => _statusMessage = 'Backup ready to share');
        }
        return;
      }
      final path = await PlatformFileOutput.saveViaDialog(
        filename: result.suggestedFilename,
        bytes: result.bytes,
        extension: 'biba',
      );
      if (!mounted) return;
      setState(() {
        _statusMessage = path == null
            ? 'Export cancelled'
            : 'Backup saved to $path';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Export failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['biba'],
    );
    if (picked.isEmpty) return;

    final bytes = await picked.single.readAsBytes();
    if (bytes.isEmpty) {
      setState(() => _statusMessage = 'Could not read backup file');
      return;
    }

    setState(() {
      _busy = true;
      _statusMessage = null;
    });

    try {
      final service = await ref.read(backupServiceProvider.future);
      final result = await service.restoreBackup(bytes);
      if (!mounted) return;
      setState(() {
        _statusMessage =
            'Restore complete for business ${result.manifest.businessId} '
            '(${result.restoredQueueJobs} queue jobs, cursor preserved)';
      });
    } on BackupRestoreException catch (error) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Restore failed: $error');
    } catch (error) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Restore failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local backup (.biba)',
            style: theme.textTheme.titleLarge,
          ),
          const Gap(8),
          Text(
            PlatformFileOutput.isMobile
                ? 'Create a local backup (.biba) or restore from a backup file. '
                      'When exporting, choose to save on this device or share.'
                : 'Create a backup file on this computer, or restore from a '
                      '.biba file. Choose the save location when you create a backup.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Gap(24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : _exportBackup,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Create Backup'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _restoreBackup,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Restore Backup'),
              ),
            ],
          ),
          if (_busy) ...[
            const Gap(24),
            const LinearProgressIndicator(),
          ],
          if (_statusMessage != null) ...[
            const Gap(16),
            Text(_statusMessage!),
          ],
        ],
      ),
    );

    if (widget.embedded) {
      return ColoredBox(
        color: AppColors.surface,
        child: body,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: body,
    );
  }
}
