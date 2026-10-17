import 'dart:convert';
import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/features/app_update/data/update_http_client.dart';
import 'package:billing_baba/features/app_update/data/update_installer_launcher.dart';
import 'package:billing_baba/features/app_update/domain/app_update_info.dart';
import 'package:billing_baba/features/app_update/domain/update_version_policy.dart';
import 'package:billing_baba/features/app_update/domain/install_launch_result.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class UpdateService {
  UpdateService({
    Dio? dio,
    PackageInfo? packageInfo,
    Future<Directory> Function()? resolveUpdatesDirectory,
    Future<InstallLaunchResult> Function(File file)? launchInstallerFn,
    WindowsInstallerProcessRunner? windowsProcessRunner,
  }) : _dio = dio ?? createUpdateHttpClient(),
       _packageInfo = packageInfo,
       _resolveUpdatesDirectory = resolveUpdatesDirectory,
       _launchInstallerFn = launchInstallerFn,
       _windowsProcessRunner = windowsProcessRunner;

  final Dio _dio;
  PackageInfo? _packageInfo;
  final Future<Directory> Function()? _resolveUpdatesDirectory;
  final Future<InstallLaunchResult> Function(File file)? _launchInstallerFn;
  final WindowsInstallerProcessRunner? _windowsProcessRunner;

  Future<PackageInfo> _resolvePackageInfo() async {
    return _packageInfo ??= await PackageInfo.fromPlatform();
  }

  bool isUrlAllowed(String url, {required bool isInstaller}) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return false;
    if (uri.scheme == 'https') return true;
    if (!isInstaller &&
        uri.scheme == 'http' &&
        AppConfig.updateManifestAllowInsecureHttp) {
      return true;
    }
    return false;
  }

  bool isForced(AppUpdateInfo info, int currentBuild) {
    return info.forceUpdate || currentBuild < info.minSupportedBuild;
  }

  Future<AppUpdateInfo?> checkForUpdate() async {
    if (!AppConfig.updateManifestConfigured) return null;

    try {
      final manifestUrl = AppConfig.updateManifestUrl;
      if (!isUrlAllowed(manifestUrl, isInstaller: false)) {
        LoggingService.instance.warn(
          '[UPDATE] Manifest URL must use HTTPS',
        );
        return null;
      }

      final response = await _dio.get<String>(
        manifestUrl,
        options: Options(responseType: ResponseType.plain),
      );
      final body = response.data;
      if (body == null || body.trim().isEmpty) return null;

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Manifest root must be an object');
      }

      final info = AppUpdateInfo.fromJson(decoded);
      if (!isUrlAllowed(info.installerUrl, isInstaller: true)) {
        LoggingService.instance.warn(
          '[UPDATE] Installer URL must use HTTPS',
        );
        return null;
      }

      final manifestHost = Uri.parse(manifestUrl).host;
      final installerHost = Uri.parse(info.installerUrl).host;
      if (manifestHost != installerHost) {
        LoggingService.instance.warn(
          '[UPDATE] Installer host ($installerHost) does not match manifest '
          'host ($manifestHost); ignoring update',
        );
        return null;
      }

      final packageInfo = await _resolvePackageInfo();
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
      final hasNewerRelease = isRemoteReleaseNewer(
        remoteVersion: info.latestVersion,
        remoteBuild: info.latestBuild,
        currentVersion: packageInfo.version,
        currentBuild: currentBuild,
      );
      if (!hasNewerRelease) return null;

      return info;
    } on Object catch (e, st) {
      LoggingService.instance.error('[UPDATE] checkForUpdate failed', e, st);
      return null;
    }
  }

  Future<Directory> _updatesDirectory() async {
    if (_resolveUpdatesDirectory != null) {
      return _resolveUpdatesDirectory();
    }
    final temp = await getTemporaryDirectory();
    final dir = Directory(p.join(temp.path, 'billing_baba_updates'));
    await dir.create(recursive: true);
    return dir;
  }

  Future<void> _cleanDownloadsDirectory(Directory dir) async {
    if (!await dir.exists()) return;
    await for (final entity in dir.list()) {
      if (entity is File) {
        final name = p.basename(entity.path).toLowerCase();
        if (name.endsWith('.part') || name.endsWith('.exe')) {
          try {
            await entity.delete();
          } on Object {
            // Best-effort cleanup.
          }
        }
      }
    }
  }

  Future<File> downloadInstaller(
    AppUpdateInfo info, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (!isUrlAllowed(info.installerUrl, isInstaller: true)) {
      throw StateError('Installer URL must use HTTPS');
    }

    final dir = await _updatesDirectory();
    await _cleanDownloadsDirectory(dir);

    final fileName = 'BillingBabaSetup-v${info.latestVersion}.exe';
    final targetPath = p.join(dir.path, fileName);
    final partPath = '$targetPath.part';

    final partFile = File(partPath);
    if (await partFile.exists()) {
      await partFile.delete();
    }

    try {
      await _dio.download(
        info.installerUrl,
        partPath,
        cancelToken: cancelToken,
        onReceiveProgress: onProgress,
      );
      final targetFile = File(targetPath);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await partFile.rename(targetPath);
      return File(targetPath);
    } on Object {
      if (await partFile.exists()) {
        await partFile.delete();
      }
      rethrow;
    }
  }

  Future<bool> verifyChecksum(File file, String expectedSha256) async {
    final digest = await sha256.bind(file.openRead()).first;
    final actual = digest.toString();
    final matches = actual.toLowerCase() == expectedSha256.toLowerCase();
    if (!matches) {
      try {
        await file.delete();
      } on Object {
        // Ignore delete errors after checksum failure.
      }
    }
    return matches;
  }

  Future<void> verifySignature(File file) async {
    // TODO(code-signing): verify Authenticode signature once code signing is enabled.
  }

  Future<InstallLaunchResult> launchInstaller(File installerFile) {
    if (_launchInstallerFn != null) {
      return _launchInstallerFn(installerFile);
    }
    return launchUpdateInstaller(
      installerFile,
      windowsProcessRunner: _windowsProcessRunner,
    );
  }

  Future<int> currentBuildNumber() async {
    final packageInfo = await _resolvePackageInfo();
    return int.tryParse(packageInfo.buildNumber) ?? 0;
  }

  Future<String> currentVersionLabel() async {
    final packageInfo = await _resolvePackageInfo();
    return packageInfo.version;
  }
}
