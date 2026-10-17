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

    final args = <String>[
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-WindowStyle',
      'Hidden',
      '-File',
      scriptPath,
    ];

    if (windowsProcessRunner != null) {
      final exitCode = await windowsProcessRunner(
        'powershell.exe',
        args,
        runInShell: false,
      );
      return exitCode == 0
          ? InstallLaunchResult.started
          : InstallLaunchResult.userCancelledOrFailed;
    }

    await Process.start(
      'powershell.exe',
      args,
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
