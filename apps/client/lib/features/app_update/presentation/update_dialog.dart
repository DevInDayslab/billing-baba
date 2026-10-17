import 'dart:async';
import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/routing/app_navigator_key.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/app_update/application/update_controller.dart';
import 'package:billing_baba/features/app_update/application/update_state.dart';
import 'package:billing_baba/features/app_update/domain/app_update_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends ConsumerStatefulWidget {
  const UpdateDialog({super.key});

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    unawaited(
      PackageInfo.fromPlatform().then((info) {
        if (mounted) setState(() => _packageInfo = info);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateControllerProvider);
    final isForced = state.isForced;
    final info = state.updateInfo;

    ref.listen(updateControllerProvider, (previous, next) {
      if (next.status == UpdateStatus.idle &&
          previous?.status != UpdateStatus.installing) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });

    return PopScope(
      canPop: !isForced,
      child: AlertDialog(
        title: Text(_titleFor(state)),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (info != null) ...[
                  _VersionRow(
                    current:
                        '${_packageInfo?.version ?? '—'} (${_packageInfo?.buildNumber ?? '—'})',
                    latest: '${info.latestVersion} (${info.latestBuild})',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Release notes',
                    style: AppTypography.inter(
                      fontSize: AppTypography.bodyMediumSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    info.releaseNotes,
                    style: AppTypography.inter(
                      fontSize: AppTypography.bodySmallSize,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
                if (state.hardBlocks.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _WarningList(
                    title: 'Cannot update yet',
                    items: state.hardBlocks,
                  ),
                ],
                if (state.awaitingSoftBlockConfirm &&
                    state.softBlocks.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _WarningList(
                    title: 'Warning',
                    items: state.softBlocks,
                  ),
                ],
                if (state.status == UpdateStatus.downloading) ...[
                  const SizedBox(height: AppSpacing.lg),
                  LinearProgressIndicator(
                    value: state.downloadProgress,
                    backgroundColor: AppColors.background,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _downloadLabel(state),
                    style: AppTypography.inter(
                      fontSize: AppTypography.bodySmallSize,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (_statusMessage(state) != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _statusMessage(state)!,
                    style: AppTypography.inter(
                      fontSize: AppTypography.bodySmallSize,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (state.status == UpdateStatus.error &&
                    state.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    state.errorMessage!,
                    style: AppTypography.inter(
                      fontSize: AppTypography.bodySmallSize,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: _buildActions(context, state, info),
      ),
    );
  }

  String _titleFor(UpdateState state) {
    return switch (state.status) {
      UpdateStatus.checking => 'Checking for updates…',
      UpdateStatus.upToDate => 'You\'re up to date',
      UpdateStatus.updateAvailable => 'Update available',
      UpdateStatus.checkingSafety => 'Checking it\'s safe to update…',
      UpdateStatus.backingUp => 'Backing up your data…',
      UpdateStatus.downloading => 'Downloading update…',
      UpdateStatus.verifying => 'Verifying installer…',
      UpdateStatus.readyToInstall => 'Ready to install',
      UpdateStatus.installing => 'Installing update…',
      UpdateStatus.error => 'Update failed',
      UpdateStatus.idle => 'Updates',
    };
  }

  String? _statusMessage(UpdateState state) {
    return switch (state.status) {
      UpdateStatus.checkingSafety => 'Making sure billing is not in progress.',
      UpdateStatus.backingUp =>
        'Creating a local backup before installing (required).',
      UpdateStatus.verifying => 'Verifying download integrity.',
      UpdateStatus.installing =>
        'Follow the Windows prompt if administrator access is required.',
      _ => null,
    };
  }

  String _downloadLabel(UpdateState state) {
    final received = state.receivedBytes ?? 0;
    final total = state.totalBytes;
    final receivedMb = received / (1024 * 1024);
    if (total != null && total > 0) {
      final totalMb = total / (1024 * 1024);
      final pct = ((state.downloadProgress ?? 0) * 100).clamp(0, 100);
      return '${pct.toStringAsFixed(0)}% · '
          '${receivedMb.toStringAsFixed(1)} / ${totalMb.toStringAsFixed(1)} MB';
    }
    return '${receivedMb.toStringAsFixed(1)} MB downloaded';
  }

  List<Widget> _buildActions(
    BuildContext context,
    UpdateState state,
    AppUpdateInfo? info,
  ) {
    final isWindowsDesktop =
        !kIsWeb && AppPlatform.current.isDesktop && Platform.isWindows;
    final controller = ref.read(updateControllerProvider.notifier);
    final busy =
        state.status == UpdateStatus.checking ||
        state.status == UpdateStatus.checkingSafety ||
        state.status == UpdateStatus.backingUp ||
        state.status == UpdateStatus.downloading ||
        state.status == UpdateStatus.verifying ||
        state.status == UpdateStatus.installing;

    if (state.status == UpdateStatus.error) {
      return [
        if (!state.isForced)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        if (state.canRetry)
          FilledButton(
            onPressed: busy ? null : () => controller.retry(),
            child: const Text('Retry'),
          ),
      ];
    }

    if (state.awaitingSoftBlockConfirm) {
      return [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: busy
              ? null
              : () => controller.startUpdate(bypassSoftBlocks: true),
          child: const Text('Install anyway'),
        ),
      ];
    }

    if (state.status == UpdateStatus.updateAvailable && info != null) {
      if (!isWindowsDesktop) {
        return [
          if (!state.isForced)
            TextButton(
              onPressed: () {
                controller.dismissOptional();
                Navigator.of(context).pop();
              },
              child: const Text('Later'),
            ),
          FilledButton(
            onPressed: () async {
              final uri = Uri.parse(AppConfig.websiteUrl);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: const Text('Download'),
          ),
        ];
      }

      return [
        if (!state.isForced)
          TextButton(
            onPressed: busy
                ? null
                : () {
                    controller.dismissOptional();
                    Navigator.of(context).pop();
                  },
            child: const Text('Later'),
          ),
        FilledButton(
          onPressed: busy ? null : () => controller.startUpdate(),
          child: const Text('Update now'),
        ),
      ];
    }

    if (!state.isForced && state.status != UpdateStatus.installing) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }

    return const [];
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({required this.current, required this.latest});

  final String current;
  final String latest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(label: 'Current', value: current),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _Chip(label: 'New', value: latest),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.inter(
                fontSize: AppTypography.bodySmallSize,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.inter(
                fontSize: AppTypography.bodyMediumSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningList extends StatelessWidget {
  const _WarningList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.inter(
            fontSize: AppTypography.bodyMediumSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $item',
              style: AppTypography.inter(
                fontSize: AppTypography.bodySmallSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

void showUpdateDialog({required bool isForced}) {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: !isForced,
      builder: (_) => const UpdateDialog(),
    ),
  );
}
