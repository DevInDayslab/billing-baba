import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/app_update/domain/install_launch_result.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds the PowerShell command used to launch the installer elevated on Windows.
String buildWindowsInstallerLaunchCommand(String installerPath) {
  final path = installerPath.replaceAll("'", "''");
  return "Start-Process -FilePath '$path' "
      "-ArgumentList '/SILENT','/SUPPRESSMSGBOXES','/NORESTART','/CLOSEAPPLICATIONS' "
      '-Verb RunAs';
}

typedef WindowsInstallerProcessRunner =
    Future<int> Function(
      String executable,
      List<String> arguments, {
      bool runInShell,
    });

Future<int> _defaultWindowsProcessRunner(
  String executable,
  List<String> arguments, {
  bool runInShell = false,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    runInShell: runInShell,
  );
  return process.exitCode;
}

Future<InstallLaunchResult> launchUpdateInstaller(
  File installerFile, {
  WindowsInstallerProcessRunner? windowsProcessRunner,
}) async {
  if (!kIsWeb && Platform.isWindows) {
    final runner = windowsProcessRunner ?? _defaultWindowsProcessRunner;
    final command = buildWindowsInstallerLaunchCommand(installerFile.path);
    final exitCode = await runner(
      'powershell',
      ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', command],
      runInShell: true,
    );
    if (exitCode == 0) {
      return InstallLaunchResult.started;
    }
    return InstallLaunchResult.userCancelledOrFailed;
  }

  final uri = Uri.parse(AppConfig.websiteUrl);
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  return launched
      ? InstallLaunchResult.started
      : InstallLaunchResult.userCancelledOrFailed;
}
