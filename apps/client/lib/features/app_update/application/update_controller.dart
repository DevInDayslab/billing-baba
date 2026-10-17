import 'dart:async';
import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/app_update/application/auto_update_backup_service.dart';
import 'package:billing_baba/features/app_update/application/update_providers.dart';
import 'package:billing_baba/features/app_update/application/update_safety_gate.dart';
import 'package:billing_baba/features/app_update/application/update_shutdown.dart';
import 'package:billing_baba/features/app_update/application/update_state.dart';
import 'package:billing_baba/features/app_update/domain/app_update_info.dart';
import 'package:billing_baba/features/app_update/domain/install_launch_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateControllerProvider =
    NotifierProvider<UpdateController, UpdateState>(UpdateController.new);

class UpdateController extends Notifier<UpdateState> {
  CancelToken? _downloadCancelToken;
  AppUpdateInfo? _activeUpdate;
  bool _optionalDismissedThisSession = false;
  bool _optionalDialogShownThisSession = false;

  @override
  UpdateState build() => const UpdateState();

  bool get optionalDismissedThisSession => _optionalDismissedThisSession;

  bool get optionalDialogShownThisSession => _optionalDialogShownThisSession;

  void markOptionalDialogShown() {
    _optionalDialogShownThisSession = true;
  }

  Future<void> checkAutomatically() async {
    if (!AppConfig.updateManifestConfigured) return;
    if (state.status == UpdateStatus.checking) return;
    await _checkInternal(manual: false);
  }

  Future<void> checkManually() async {
    if (!AppConfig.updateManifestConfigured) return;
    await _checkInternal(manual: true);
  }

  Future<void> _checkInternal({required bool manual}) async {
    state = state.copyWith(
      status: UpdateStatus.checking,
      clearError: true,
      clearProgress: true,
    );

    final service = ref.read(updateServiceProvider);
    final info = await service.checkForUpdate();
    if (!ref.mounted) return;

    if (info == null) {
      state = state.copyWith(
        status: manual ? UpdateStatus.upToDate : UpdateStatus.idle,
        clearUpdateInfo: true,
      );
      return;
    }

    final currentBuild = await service.currentBuildNumber();
    final forced = service.isForced(info, currentBuild);
    _activeUpdate = info;

    if (!manual &&
        !forced &&
        (_optionalDismissedThisSession || _optionalDialogShownThisSession)) {
      state = const UpdateState(status: UpdateStatus.idle);
      return;
    }

    state = state.copyWith(
      status: UpdateStatus.updateAvailable,
      updateInfo: info,
      isForced: forced,
    );
  }

  void dismissOptional() {
    _optionalDismissedThisSession = true;
    state = const UpdateState(status: UpdateStatus.idle);
  }

  Future<void> startUpdate({bool bypassSoftBlocks = false}) async {
    final info = _activeUpdate ?? state.updateInfo;
    if (info == null) return;

    state = state.copyWith(
      status: UpdateStatus.checkingSafety,
      updateInfo: info,
      clearError: true,
      hardBlocks: const [],
      softBlocks: const [],
      awaitingSoftBlockConfirm: false,
    );

    final safety = await ref.read(updateSafetyGateProvider).evaluate();
    if (!ref.mounted) return;

    if (safety.hasHardBlock) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: safety.hardBlocks.join('\n'),
        canRetry: true,
        hardBlocks: safety.hardBlocks,
      );
      return;
    }

    if (safety.hasSoftBlock && !bypassSoftBlocks) {
      state = state.copyWith(
        status: UpdateStatus.updateAvailable,
        softBlocks: safety.softBlocks,
        awaitingSoftBlockConfirm: true,
      );
      return;
    }

    await _runDownloadAndInstall(info);
  }

  Future<void> retry() async {
    final info = _activeUpdate ?? state.updateInfo;
    if (info == null) {
      await checkManually();
      return;
    }
    await startUpdate(bypassSoftBlocks: state.awaitingSoftBlockConfirm);
  }

  Future<void> _runDownloadAndInstall(AppUpdateInfo info) async {
    final service = ref.read(updateServiceProvider);

    state = state.copyWith(status: UpdateStatus.backingUp, clearError: true);
    try {
      await ref.read(autoUpdateBackupServiceProvider).createPreUpdateBackup();
    } on Object catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Backup failed: $e',
        canRetry: true,
      );
      return;
    }

    if (!ref.mounted) return;

    _downloadCancelToken = CancelToken();
    state = state.copyWith(
      status: UpdateStatus.downloading,
      clearProgress: true,
    );

    File installerFile;
    try {
      installerFile = await service.downloadInstaller(
        info,
        cancelToken: _downloadCancelToken,
        onProgress: (received, total) {
          if (!ref.mounted) return;
          final progress = total > 0 ? received / total : null;
          state = state.copyWith(
            status: UpdateStatus.downloading,
            receivedBytes: received,
            totalBytes: total > 0 ? total : null,
            downloadProgress: progress,
          );
        },
      );
    } on Object catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Download failed: $e',
        canRetry: true,
        clearProgress: true,
      );
      return;
    }

    if (!ref.mounted) return;

    state = state.copyWith(status: UpdateStatus.verifying, clearProgress: true);
    final checksumOk = await service.verifyChecksum(installerFile, info.sha256);
    if (!checksumOk) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Installer checksum did not match. Please try again.',
        canRetry: true,
      );
      return;
    }

    await service.verifySignature(installerFile);
    if (!ref.mounted) return;

    state = state.copyWith(status: UpdateStatus.readyToInstall);
    state = state.copyWith(status: UpdateStatus.installing);

    final launchResult = await service.launchInstaller(installerFile);
    if (!ref.mounted) return;

    if (launchResult == InstallLaunchResult.started) {
      await ref.read(shutdownForUpdateProvider)(ref);
      return;
    }

    state = state.copyWith(
      status: UpdateStatus.error,
      errorMessage:
          'Update needs administrator permission. Please try again and click Yes.',
      canRetry: true,
    );
  }

  void cancelDownload() {
    _downloadCancelToken?.cancel();
    _downloadCancelToken = null;
  }
}
