import 'dart:io';

import 'package:billing_baba/features/app_update/data/update_installer_launcher.dart';
import 'package:billing_baba/features/app_update/domain/install_launch_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('windowsUpdateHelperCmdStartArgs', () {
    test('breaks away via cmd start before powershell', () {
      final args = windowsUpdateHelperCmdStartArgs(
        windowsUpdateHelperPowerShellArgs(r'C:\tmp\apply.ps1'),
      );
      expect(args.take(5), ['/c', 'start', '/min', '', 'powershell.exe']);
      expect(args, contains('-File'));
      expect(args.last, r'C:\tmp\apply.ps1');
    });
  });

  group('buildWindowsUpdateApplyScript', () {
    test('escapes apostrophes and waits for app exit before silent install', () {
      const path = r"C:\Apps\Billing Baba's\setup.exe";
      final script = buildWindowsUpdateApplyScript(path);
      expect(script, contains("Billing Baba''s"));
      expect(script, contains('billing_baba'));
      expect(script, contains('/SILENT'));
      expect(script, contains('/SUPPRESSMSGBOXES'));
      expect(script, contains('/NORESTART'));
      expect(script, contains('/CLOSEAPPLICATIONS'));
      expect(script, contains('-Wait'));
      expect(script, contains('-Verb RunAs'));
    });
  });

  group('launchUpdateInstaller', () {
    test('maps exit code 0 to started', () async {
      final dir = await Directory.systemTemp.createTemp('launcher-test');
      final file = File('${dir.path}/setup.exe');
      await file.writeAsBytes(const [1, 2, 3]);

      List<String>? capturedArgs;
      final result = await launchUpdateInstaller(
        file,
        windowsProcessRunner: (executable, arguments, {runInShell = false}) async {
          expect(executable, 'powershell.exe');
          expect(runInShell, isFalse);
          capturedArgs = arguments;
          return 0;
        },
      );

      expect(result, InstallLaunchResult.started);
      expect(capturedArgs, isNotNull);
      expect(capturedArgs!.join(' '), contains('-File'));
      final scriptPath = capturedArgs!.last;
      final script = await File(scriptPath).readAsString();
      expect(script, contains('/SILENT'));
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
