import 'dart:io';

import 'package:billing_baba/features/app_update/data/update_installer_launcher.dart';
import 'package:billing_baba/features/app_update/domain/install_launch_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildWindowsInstallerLaunchCommand', () {
    test('escapes apostrophes and includes silent flags and RunAs', () {
      const path = r"C:\Apps\Billing Baba's\setup.exe";
      final command = buildWindowsInstallerLaunchCommand(path);
      expect(command, contains("Billing Baba''s"));
      expect(command, contains('/SILENT'));
      expect(command, contains('/SUPPRESSMSGBOXES'));
      expect(command, contains('/NORESTART'));
      expect(command, contains('/CLOSEAPPLICATIONS'));
      expect(command, contains('-Verb RunAs'));
    });
  });

  group('launchUpdateInstaller', () {
    test('maps exit code 0 to started', () async {
      final dir = await Directory.systemTemp.createTemp('launcher-test');
      final file = File('${dir.path}/setup.exe');
      await file.writeAsBytes(const [1, 2, 3]);

      String? capturedCommand;
      final result = await launchUpdateInstaller(
        file,
        windowsProcessRunner: (executable, arguments, {runInShell = false}) async {
          expect(executable, 'powershell');
          expect(runInShell, isTrue);
          capturedCommand = arguments.last;
          return 0;
        },
      );

      expect(result, InstallLaunchResult.started);
      expect(capturedCommand, contains('/SILENT'));
      await dir.delete(recursive: true);
    });

    test('maps non-zero exit code to userCancelledOrFailed', () async {
      final dir = await Directory.systemTemp.createTemp('launcher-test');
      final file = File('${dir.path}/setup.exe');
      await file.writeAsBytes(const [1]);

      final result = await launchUpdateInstaller(
        file,
        windowsProcessRunner: (_, _, {runInShell = false}) async => 1,
      );

      expect(result, InstallLaunchResult.userCancelledOrFailed);
      await dir.delete(recursive: true);
    });
  });
}
