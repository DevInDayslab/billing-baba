import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/app_update/domain/install_launch_result.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

/// PowerShell script: wait for the app to exit, then run the installer elevated.
String buildWindowsUpdateApplyScript(String installerPath) {
  final escaped = installerPath.replaceAll("'", "''");
  return r"$ErrorActionPreference = 'Stop'" '\n'
      r"while (Get-Process -Name billing_baba -ErrorAction SilentlyContinue) {" '\n'
      r"  Start-Sleep -Milliseconds 500" '\n'
      r"}" '\n'
      "Start-Process -FilePath '$escaped' "
      r"-ArgumentList '/SILENT','/SUPPRESSMSGBOXES','/NORESTART','/CLOSEAPPLICATIONS' "
      r"-Verb RunAs -Wait";
}

typedef WindowsInstallerProcessRunner =
    Future<int> Function(
      String executable,
      List<String> arguments, {
      bool runInShell,
    });

/// PowerShell args for the post-exit elevated installer helper.
List<String> windowsUpdateHelperPowerShellArgs(String scriptPath) => [
  '-NoProfile',
  '-ExecutionPolicy',
  'Bypass',
  '-WindowStyle',
  'Hidden',
  '-File',
  scriptPath,
];

/// Spawns the helper via `cmd start` so it is not tied to the app's Windows job
/// object (a detached child of `billing_baba.exe` is killed on `exit(0)`).
List<String> windowsUpdateHelperCmdStartArgs(List<String> powerShellArgs) => [
  '/c',
  'start',
  '/min',
  '',
  'powershell.exe',
  ...powerShellArgs,
];

Future<InstallLaunchResult> launchUpdateInstaller(
  File installerFile, {
  WindowsInstallerProcessRunner? windowsProcessRunner,
}) async {
  if (!kIsWeb && Platform.isWindows) {
    final scriptPath = p.join(
      Directory.systemTemp.path,
      'billing_baba_apply_update.ps1',
    );
    await File(scriptPath).writeAsString(
      buildWindowsUpdateApplyScript(installerFile.path),
    );

    final psArgs = windowsUpdateHelperPowerShellArgs(scriptPath);

    if (windowsProcessRunner != null) {
      final exitCode = await windowsProcessRunner(
        'powershell.exe',
        psArgs,
        runInShell: false,
      );
      return exitCode == 0
          ? InstallLaunchResult.started
          : InstallLaunchResult.userCancelledOrFailed;
    }

    await Process.start(
      'cmd.exe',
      windowsUpdateHelperCmdStartArgs(psArgs),
      mode: ProcessStartMode.detached,
    );
    return InstallLaunchResult.started;
  }

  final uri = Uri.parse(AppConfig.websiteUrl);
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  return launched
      ? InstallLaunchResult.started
      : InstallLaunchResult.userCancelledOrFailed;
}
