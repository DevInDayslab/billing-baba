import 'dart:io';
import 'dart:typed_data';

import 'package:billing_baba/features/app_update/application/auto_update_backup_service.dart';
import 'package:billing_baba/features/app_update/application/update_controller.dart';
import 'package:billing_baba/features/app_update/application/update_providers.dart';
import 'package:billing_baba/features/app_update/application/update_shutdown.dart';
import 'package:billing_baba/features/app_update/application/update_state.dart';
import 'package:billing_baba/features/app_update/data/update_service.dart';
import 'package:billing_baba/features/app_update/domain/install_launch_result.dart';
import 'package:billing_baba/features/backup/data/backup_exporter.dart';
import 'package:billing_baba/features/backup/models/backup_manifest.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'update_test_helpers.dart';

void _initTestEnv() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.loadFromString(
    envString:
        'API_BASE_URL=http://127.0.0.1:3000\nWEBSITE_URL=http://127.0.0.1\n',
  );
}

BackupExportResult _fakeBackup() => BackupExportResult(
  bytes: Uint8List.fromList([9]),
  manifest: BillingBabaBackupManifest(
    version: 1,
    createdAt: '2026-01-01T00:00:00Z',
    schemaVersion: 1,
    businessId: 'biz',
    appVersion: '1.0.0',
    checksums: const {},
  ),
  suggestedFilename: 'x.biba',
);

void main() {
  setUpAll(_initTestEnv);

  late MemorySyncQueueFixture syncFixture;

  setUp(() {
    syncFixture = MemorySyncQueueFixture();
  });

  tearDown(() async {
    await syncFixture.dispose();
  });

  group('UpdateController', () {
    test('happy path states in order', () async {
      final statuses = <UpdateStatus>[];
      var shutdownCalls = 0;
      final info = sampleUpdateInfo(sha256: 'E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855');
      final container = ProviderContainer(
        overrides: [
          ...updateSafetyGateTestOverrides(queue: syncFixture.queue),
          updateServiceProvider.overrideWithValue(
            UpdateService(
              packageInfo: testPackageInfo(buildNumber: '1'),
              dio: dioWithInstallerBytes(const []),
              resolveUpdatesDirectory: () async =>
                  Directory.systemTemp.createTempSync('ctrl-dl'),
              launchInstallerFn: (_) async => InstallLaunchResult.started,
            ),
          ),
          autoUpdateBackupServiceProvider.overrideWithValue(
            AutoUpdateBackupService(
              null,
              exportBackupFn: () async => _fakeBackup(),
              packageInfoOverride: testPackageInfo(buildNumber: '1'),
              backupDirectoryOverride:
                  Directory.systemTemp.createTempSync('ctrl-bk'),
            ),
          ),
          shutdownForUpdateProvider.overrideWithValue((ref) async {
            shutdownCalls++;
          }),
        ],
      );

      container.listen(
        updateControllerProvider,
        (_, next) => statuses.add(next.status),
        fireImmediately: true,
      );

      final notifier = container.read(updateControllerProvider.notifier);
      notifier.state = UpdateState(
        status: UpdateStatus.updateAvailable,
        updateInfo: info,
      );
      await notifier.startUpdate();

      expect(
        statuses,
        containsAllInOrder([
          UpdateStatus.updateAvailable,
          UpdateStatus.checkingSafety,
          UpdateStatus.backingUp,
          UpdateStatus.downloading,
          UpdateStatus.verifying,
          UpdateStatus.readyToInstall,
          UpdateStatus.installing,
        ]),
      );
      expect(shutdownCalls, 1);
      container.dispose();
    });

    test('checksum failure => error with canRetry', () async {
      final info = sampleUpdateInfo(sha256: 'badhash');
      final container = ProviderContainer(
        overrides: [
          ...updateSafetyGateTestOverrides(queue: syncFixture.queue),
          updateServiceProvider.overrideWithValue(
            UpdateService(
              packageInfo: testPackageInfo(),
              dio: dioWithInstallerBytes(const []),
              resolveUpdatesDirectory: () async =>
                  Directory.systemTemp.createTempSync('ctrl-dl2'),
              launchInstallerFn: (_) async => InstallLaunchResult.started,
            ),
          ),
          autoUpdateBackupServiceProvider.overrideWithValue(
            AutoUpdateBackupService(
              null,
              exportBackupFn: () async => _fakeBackup(),
              packageInfoOverride: testPackageInfo(),
              backupDirectoryOverride:
                  Directory.systemTemp.createTempSync('ctrl-bk2'),
            ),
          ),
          shutdownForUpdateProvider.overrideWithValue((_) async {}),
        ],
      );
      final notifier = container.read(updateControllerProvider.notifier);
      notifier.state = UpdateState(
        status: UpdateStatus.updateAvailable,
        updateInfo: info,
      );
      await notifier.startUpdate();
      final state = container.read(updateControllerProvider);
      expect(state.status, UpdateStatus.error);
      expect(state.canRetry, isTrue);
      expect(state.errorMessage, contains('checksum'));
      container.dispose();
    });

    test('UAC declined => error and shutdown not called', () async {
      var shutdownCalls = 0;
      final info = sampleUpdateInfo(
        sha256: 'E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855',
      );
      final container = ProviderContainer(
        overrides: [
          ...updateSafetyGateTestOverrides(queue: syncFixture.queue),
          updateServiceProvider.overrideWithValue(
            UpdateService(
              packageInfo: testPackageInfo(),
              dio: dioWithInstallerBytes(const []),
              resolveUpdatesDirectory: () async =>
                  Directory.systemTemp.createTempSync('ctrl-dl3'),
              launchInstallerFn: (_) async =>
                  InstallLaunchResult.userCancelledOrFailed,
            ),
          ),
          autoUpdateBackupServiceProvider.overrideWithValue(
            AutoUpdateBackupService(
              null,
              exportBackupFn: () async => _fakeBackup(),
              packageInfoOverride: testPackageInfo(),
              backupDirectoryOverride:
                  Directory.systemTemp.createTempSync('ctrl-bk3'),
            ),
          ),
          shutdownForUpdateProvider.overrideWithValue((_) async {
            shutdownCalls++;
          }),
        ],
      );
      final notifier = container.read(updateControllerProvider.notifier);
      notifier.state = UpdateState(
        status: UpdateStatus.updateAvailable,
        updateInfo: info,
      );
      await notifier.startUpdate();
      final state = container.read(updateControllerProvider);
      expect(state.status, UpdateStatus.error);
      expect(state.errorMessage, contains('administrator permission'));
      expect(shutdownCalls, 0);
      container.dispose();
    });

    test('backup failure => error without download', () async {
      var downloadStarted = false;
      final info = sampleUpdateInfo();
      final container = ProviderContainer(
        overrides: [
          ...updateSafetyGateTestOverrides(queue: syncFixture.queue),
          updateServiceProvider.overrideWithValue(
            UpdateService(
              packageInfo: testPackageInfo(),
              launchInstallerFn: (_) async {
                downloadStarted = true;
                return InstallLaunchResult.started;
              },
            ),
          ),
          autoUpdateBackupServiceProvider.overrideWithValue(
            AutoUpdateBackupService(
              null,
              exportBackupFn: () async => throw StateError('backup failed'),
              packageInfoOverride: testPackageInfo(),
            ),
          ),
        ],
      );
      final notifier = container.read(updateControllerProvider.notifier);
      notifier.state = UpdateState(
        status: UpdateStatus.updateAvailable,
        updateInfo: info,
      );
      await notifier.startUpdate();
      final state = container.read(updateControllerProvider);
      expect(state.status, UpdateStatus.error);
      expect(state.errorMessage, contains('Backup failed'));
      expect(downloadStarted, isFalse);
      container.dispose();
    });
  });
}
