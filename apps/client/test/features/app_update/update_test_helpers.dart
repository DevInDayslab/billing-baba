import 'dart:convert';
import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:billing_baba/features/app_update/data/update_http_client.dart';
import 'package:billing_baba/features/app_update/domain/app_update_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

PackageInfo testPackageInfo({
  String version = '1.0.0',
  String buildNumber = '1',
}) {
  return PackageInfo(
    appName: 'Billing Baba',
    packageName: 'com.billingbaba.app',
    version: version,
    buildNumber: buildNumber,
    buildSignature: '',
  );
}

AppUpdateInfo sampleUpdateInfo({
  String version = '1.0.1',
  int latestBuild = 2,
  String? installerUrl,
  String? sha256,
  bool forceUpdate = false,
  int minSupportedBuild = 1,
  String releaseNotes = 'Test release',
}) {
  return AppUpdateInfo(
    latestVersion: version,
    latestBuild: latestBuild,
    minSupportedBuild: minSupportedBuild,
    installerUrl: installerUrl ?? 'https://updates.example.com/BillingBabaSetup-v$version.exe',
    sha256: sha256 ?? 'abc123',
    releaseNotes: releaseNotes,
    forceUpdate: forceUpdate,
  );
}

Map<String, dynamic> manifestJson({
  String version = '1.0.1',
  int latestBuild = 2,
  String? installerUrl,
  String? sha256,
  bool forceUpdate = false,
  int minSupportedBuild = 1,
}) {
  final base = installerUrl ?? 'https://updates.example.com/BillingBabaSetup-v$version.exe';
  return {
    'latest_version': version,
    'latest_build': latestBuild,
    'min_supported_build': minSupportedBuild,
    'installer_url': base,
    'sha256': sha256 ?? 'deadbeef',
    'release_notes': 'Notes',
    'force_update': forceUpdate,
    'published_at': '2026-10-17T10:00:00Z',
  };
}

/// In-memory sync queue so [UpdateSafetyGate] does not open a file-backed DB.
class MemorySyncQueueFixture {
  MemorySyncQueueFixture() {
    db = AppDatabase(NativeDatabase.memory());
    queue = SyncQueue(db);
  }

  late final AppDatabase db;
  late final SyncQueue queue;

  Future<void> dispose() => db.close();
}

List<Override> updateSafetyGateTestOverrides({
  required SyncQueue queue,
}) {
  return [
    authProvider.overrideWithValue(
      const AuthState(status: AuthStatus.unauthenticated),
    ),
    syncQueueProvider.overrideWithValue(queue),
  ];
}

void loadUpdateEnv({
  String? manifestUrl,
  bool allowInsecureHttp = true,
}) {
  AppConfig.resetUpdateManifestOverridesForTest();
  AppConfig.updateManifestUrlOverride = manifestUrl ?? '';
  AppConfig.updateManifestAllowInsecureHttpOverride = allowInsecureHttp;
}

Dio dioWithInstallerBytes(
  List<int> bytes, {
  Duration? delayBeforeRespond,
  bool throwConnectionError = false,
}) {
  final dio = createUpdateHttpClient();
  dio.httpClientAdapter = _InstallerBytesAdapter(
    bytes: bytes,
    delayBeforeRespond: delayBeforeRespond,
    throwConnectionError: throwConnectionError,
  );
  return dio;
}

class _InstallerBytesAdapter implements HttpClientAdapter {
  _InstallerBytesAdapter({
    required this.bytes,
    this.delayBeforeRespond,
    this.throwConnectionError = false,
  });

  final List<int> bytes;
  final Duration? delayBeforeRespond;
  final bool throwConnectionError;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (throwConnectionError) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    if (delayBeforeRespond != null) {
      await Future<void>.delayed(delayBeforeRespond!);
    }
    cancelFuture?.then((_) => throw DioException(
      requestOptions: options,
      type: DioExceptionType.cancel,
    ));
    return ResponseBody.fromBytes(
      Uint8List.fromList(bytes),
      200,
      headers: {
        Headers.contentLengthHeader: [bytes.length.toString()],
      },
    );
  }
}

Future<HttpServer> serveJson(
  Map<String, dynamic> body, {
  int statusCode = 200,
  String path = '/version.json',
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    if (request.uri.path != path) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    request.response.statusCode = statusCode;
    request.response.headers.set('Cache-Control', 'no-cache');
    if (statusCode == 200) {
      request.response.write(jsonEncode(body));
    }
    await request.response.close();
  });
  return server;
}
