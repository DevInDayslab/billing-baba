import 'dart:convert';
import 'dart:io';

import 'package:billing_baba/features/app_update/data/update_http_client.dart';
import 'package:billing_baba/features/app_update/data/update_service.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'update_test_helpers.dart';

void main() {
  group('UpdateService.isForced', () {
    final service = UpdateService(packageInfo: testPackageInfo());
    final info = sampleUpdateInfo();

    test('forceUpdate true', () {
      expect(
        service.isForced(sampleUpdateInfo(forceUpdate: true), 5),
        isTrue,
      );
    });

    test('currentBuild < minSupportedBuild', () {
      expect(
        service.isForced(
          sampleUpdateInfo(minSupportedBuild: 10),
          5,
        ),
        isTrue,
      );
    });

    test('neither forced', () {
      expect(service.isForced(info, 5), isFalse);
    });
  });

  group('UpdateService.isUrlAllowed', () {
    final service = UpdateService(packageInfo: testPackageInfo());

    test('rejects http manifest when allow flag is off', () {
      loadUpdateEnv(manifestUrl: 'http://localhost/v.json', allowInsecureHttp: false);
      expect(service.isUrlAllowed('http://localhost/v.json', isInstaller: false), isFalse);
    });

    test('accepts http manifest when debug allow flag is on', () {
      loadUpdateEnv(manifestUrl: 'http://localhost/v.json', allowInsecureHttp: true);
      expect(
        kDebugMode,
        isTrue,
        reason: 'Tests run in debug mode',
      );
      expect(service.isUrlAllowed('http://localhost/v.json', isInstaller: false), isTrue);
    });

    test('installer http always rejected', () {
      loadUpdateEnv(allowInsecureHttp: true);
      expect(
        service.isUrlAllowed('http://localhost/setup.exe', isInstaller: true),
        isFalse,
      );
    });
  });

  group('UpdateService.checkForUpdate', () {
    test('returns null when manifest URL not configured', () async {
      loadUpdateEnv(manifestUrl: '', allowInsecureHttp: false);
      final service = UpdateService(packageInfo: testPackageInfo());
      expect(await service.checkForUpdate(), isNull);
    });

    test('returns info when latestBuild is greater', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final host = '127.0.0.1';
      final baseHttp = 'http://$host:${server.port}';
      server.listen((request) async {
        request.response.write(
          jsonEncode(
            manifestJson(
              latestBuild: 5,
              installerUrl: 'https://$host:${server.port}/installer.exe',
            ),
          ),
        );
        await request.response.close();
      });
      loadUpdateEnv(
        manifestUrl: '$baseHttp/version.json',
        allowInsecureHttp: true,
      );
      final service = UpdateService(
        packageInfo: testPackageInfo(buildNumber: '1'),
      );
      final info = await service.checkForUpdate();
      await server.close(force: true);
      expect(info, isNotNull);
      expect(info!.latestBuild, 5);
    });

    test('returns info when semver is newer with lower build', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      final installerUrl =
          'https://127.0.0.1:$port/BillingBabaSetup-v1.0.1.exe';
      server.listen((request) async {
        if (request.uri.path == '/version.json') {
          request.response.write(
            jsonEncode(manifestJson(
              version: '1.0.1',
              latestBuild: 1,
              installerUrl: installerUrl,
            )),
          );
        } else {
          request.response.statusCode = HttpStatus.notFound;
        }
        await request.response.close();
      });
      loadUpdateEnv(
        manifestUrl: 'http://127.0.0.1:$port/version.json',
        allowInsecureHttp: true,
      );
      final service = UpdateService(
        packageInfo: testPackageInfo(version: '1.0.0', buildNumber: '2'),
      );
      final info = await service.checkForUpdate();
      await server.close(force: true);
      expect(info, isNotNull);
      expect(info!.latestVersion, '1.0.1');
    });

    test('returns null when build is equal or lower', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      final installerUrl =
          'https://127.0.0.1:$port/BillingBabaSetup-v1.0.1.exe';
      server.listen((request) async {
        if (request.uri.path == '/version.json') {
          request.response.write(
            jsonEncode(manifestJson(
              version: '1.0.0',
              latestBuild: 1,
              installerUrl: installerUrl,
            )),
          );
        } else {
          request.response.statusCode = HttpStatus.notFound;
        }
        await request.response.close();
      });
      loadUpdateEnv(
        manifestUrl: 'http://127.0.0.1:$port/version.json',
        allowInsecureHttp: true,
      );
      final service = UpdateService(
        packageInfo: testPackageInfo(buildNumber: '1'),
      );
      expect(await service.checkForUpdate(), isNull);
      await server.close(force: true);
    });

    test('returns null on network errors without throwing', () async {
      loadUpdateEnv(
        manifestUrl: 'http://127.0.0.1:1/version.json',
        allowInsecureHttp: true,
      );
      final dio = createUpdateHttpClient();
      dio.options.connectTimeout = const Duration(milliseconds: 200);
      dio.options.receiveTimeout = const Duration(milliseconds: 200);
      final service = UpdateService(
        dio: dio,
        packageInfo: testPackageInfo(),
      );
      expect(await service.checkForUpdate(), isNull);
    });

    test('returns null on 404 and 500', () async {
      for (final code in [404, 500]) {
        final server = await serveJson({}, statusCode: code);
        final port = server.port;
        loadUpdateEnv(
          manifestUrl: 'http://127.0.0.1:$port/version.json',
          allowInsecureHttp: true,
        );
        final service = UpdateService(packageInfo: testPackageInfo());
        expect(await service.checkForUpdate(), isNull);
        await server.close(force: true);
      }
    });

    test('returns null on invalid JSON', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        request.response.write('not-json');
        await request.response.close();
      });
      loadUpdateEnv(
        manifestUrl: 'http://127.0.0.1:${server.port}/version.json',
        allowInsecureHttp: true,
      );
      final service = UpdateService(packageInfo: testPackageInfo());
      expect(await service.checkForUpdate(), isNull);
      await server.close(force: true);
    });

    test('rejects installer host mismatch', () async {
      final manifest = manifestJson(
        installerUrl: 'https://evil.example.com/installer.exe',
      );
      final server = await serveJson(manifest);
      loadUpdateEnv(
        manifestUrl: 'http://127.0.0.1:${server.port}/version.json',
        allowInsecureHttp: true,
      );
      final service = UpdateService(
        packageInfo: testPackageInfo(buildNumber: '0'),
      );
      expect(await service.checkForUpdate(), isNull);
      await server.close(force: true);
    });
  });

  group('UpdateService.verifyChecksum', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('checksum-test');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('accepts correct hash case-insensitively', () async {
      final file = File('${tempDir.path}/f.bin');
      const bytes = [1, 2, 3];
      await file.writeAsBytes(bytes);
      final hash = sha256.convert(bytes).toString();
      final service = UpdateService();
      expect(await service.verifyChecksum(file, hash.toLowerCase()), isTrue);
      expect(await file.exists(), isTrue);
      expect(await service.verifyChecksum(file, hash.toUpperCase()), isTrue);
    });

    test('wrong hash deletes file', () async {
      final file = File('${tempDir.path}/f.bin');
      await file.writeAsBytes(const [9]);
      final service = UpdateService();
      expect(await service.verifyChecksum(file, '00'), isFalse);
      expect(await file.exists(), isFalse);
    });

    test('empty file', () async {
      final file = File('${tempDir.path}/empty.bin');
      await file.writeAsBytes(const []);
      final service = UpdateService();
      expect(
        await service.verifyChecksum(
          file,
          'E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855',
        ),
        isTrue,
      );
    });

    test('streams large file without loading all bytes into a single buffer', () async {
      final file = File('${tempDir.path}/large.bin');
      final sink = file.openWrite();
      const chunk = 1024 * 1024;
      for (var i = 0; i < 50; i++) {
        sink.add(List<int>.filled(chunk, i % 255));
      }
      await sink.close();
      final service = UpdateService();
      final wrong = await service.verifyChecksum(file, '00');
      expect(wrong, isFalse);
      expect(await file.exists(), isFalse);
    });
  });

  group('UpdateService.verifySignature', () {
    test('placeholder does not throw', () async {
      final dir = await Directory.systemTemp.createTemp('sig');
      final file = File('${dir.path}/a.exe');
      await file.writeAsBytes(const [1]);
      await UpdateService().verifySignature(file);
      await dir.delete(recursive: true);
    });
  });

  group('UpdateService.downloadInstaller', () {
    late Directory updatesDir;

    setUp(() async {
      updatesDir = await Directory.systemTemp.createTemp('bb-updates');
    });

    tearDown(() async {
      await updatesDir.delete(recursive: true);
    });

    test('writes final file and removes .part on success', () async {
      final bytes = List<int>.generate(4096, (i) => i % 255);
      final info = sampleUpdateInfo(
        installerUrl: 'https://updates.example.com/installer.exe',
      );
      final service = UpdateService(
        dio: dioWithInstallerBytes(bytes),
        packageInfo: testPackageInfo(),
        resolveUpdatesDirectory: () async => updatesDir,
      );
      final file = await service.downloadInstaller(info);
      expect(await file.exists(), isTrue);
      expect(file.path.endsWith('.exe'), isTrue);
      expect(
        updatesDir.listSync().where((e) => e.path.endsWith('.part')),
        isEmpty,
      );
    });

    test('progress increases monotonically to 1.0', () async {
      final bytes = List<int>.generate(8000, (i) => i % 10);
      final info = sampleUpdateInfo();
      final progresses = <double>[];
      final service = UpdateService(
        dio: dioWithInstallerBytes(bytes),
        resolveUpdatesDirectory: () async => updatesDir,
      );
      await service.downloadInstaller(
        info,
        onProgress: (received, total) {
          if (total > 0) progresses.add(received / total);
        },
      );
      expect(progresses, isNotEmpty);
      for (var i = 1; i < progresses.length; i++) {
        expect(progresses[i], greaterThanOrEqualTo(progresses[i - 1]));
      }
      expect(progresses.last, closeTo(1.0, 0.001));
    });

    test('cancel removes partial file', () async {
      final info = sampleUpdateInfo();
      final token = CancelToken();
      final service = UpdateService(
        dio: dioWithInstallerBytes(
          [1, 2, 3],
          delayBeforeRespond: const Duration(seconds: 2),
        ),
        resolveUpdatesDirectory: () async => updatesDir,
      );
      final future = service.downloadInstaller(info, cancelToken: token);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      token.cancel('test');
      await expectLater(future, throwsA(isA<DioException>()));
      final parts = updatesDir
          .listSync()
          .where((e) => e.path.toLowerCase().endsWith('.part'));
      expect(parts, isEmpty);
    });

    test('connection drop removes partial file', () async {
      final info = sampleUpdateInfo();
      final service = UpdateService(
        dio: dioWithInstallerBytes(const [], throwConnectionError: true),
        resolveUpdatesDirectory: () async => updatesDir,
      );
      await expectLater(
        service.downloadInstaller(info),
        throwsA(isA<DioException>()),
      );
      final parts = updatesDir
          .listSync()
          .where((e) => e.path.toLowerCase().endsWith('.part'));
      expect(parts, isEmpty);
    });

    test('cleans old exe and part files before download', () async {
      final staleExe = File('${updatesDir.path}/old.exe');
      final stalePart = File('${updatesDir.path}/old.part');
      await staleExe.writeAsString('old');
      await stalePart.writeAsString('part');
      final info = sampleUpdateInfo();
      final service = UpdateService(
        dio: dioWithInstallerBytes([1, 2]),
        resolveUpdatesDirectory: () async => updatesDir,
      );
      await service.downloadInstaller(info);
      expect(await staleExe.exists(), isFalse);
      expect(await stalePart.exists(), isFalse);
    });
  });
}
