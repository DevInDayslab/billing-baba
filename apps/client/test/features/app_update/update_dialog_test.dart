import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/routing/app_navigator_key.dart';
import 'package:billing_baba/features/app_update/application/update_controller.dart';
import 'package:billing_baba/features/app_update/application/update_state.dart';
import 'package:billing_baba/features/app_update/presentation/update_dialog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/about_settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'update_test_helpers.dart';

class _TrackingUpdateController extends UpdateController {
  _TrackingUpdateController(this.initial);

  final UpdateState initial;
  int startUpdateCalls = 0;

  @override
  UpdateState build() => initial;

  @override
  Future<void> startUpdate({bool bypassSoftBlocks = false}) async {
    startUpdateCalls++;
    await super.startUpdate(bypassSoftBlocks: bypassSoftBlocks);
  }
}

void _mockPackageInfo() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/package_info'),
    (call) async {
      if (call.method == 'getAll') {
        return {
          'appName': 'Billing Baba',
          'packageName': 'com.billingbaba.app',
          'version': '1.0.0',
          'buildNumber': '1',
          'buildSignature': '',
        };
      }
      return null;
    },
  );
}

Future<void> _openDialog(
  WidgetTester tester,
  ProviderContainer container, {
  required UpdateState state,
  required bool barrierDismissible,
}) async {
  container.read(updateControllerProvider.notifier).state = state;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: barrierDismissible,
                  builder: (_) => const UpdateDialog(),
                );
              },
              child: const Text('Open dialog'),
            );
          },
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open dialog'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _mockPackageInfo();
    dotenv.loadFromString(
      envString:
          'API_BASE_URL=http://127.0.0.1:3000\nWEBSITE_URL=http://127.0.0.1\n',
    );
  });

  tearDown(() {
    AppConfig.resetUpdateManifestOverridesForTest();
  });

  group('UpdateDialog', () {
    testWidgets('optional update shows Update now and Later; dismisses on barrier and back', (
      tester,
    ) async {
      final container = ProviderContainer();
      await _openDialog(
        tester,
        container,
        barrierDismissible: true,
        state: UpdateState(
          status: UpdateStatus.updateAvailable,
          updateInfo: sampleUpdateInfo(),
          isForced: false,
        ),
      );

      expect(find.text('Update now'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.byType(UpdateDialog), findsNothing);

      await _openDialog(
        tester,
        container,
        barrierDismissible: true,
        state: UpdateState(
          status: UpdateStatus.updateAvailable,
          updateInfo: sampleUpdateInfo(),
          isForced: false,
        ),
      );
      final scope = tester.element(find.byType(UpdateDialog));
      Navigator.of(scope).pop();
      await tester.pumpAndSettle();
      expect(find.byType(UpdateDialog), findsNothing);
      container.dispose();
    });

    testWidgets('forced update hides Later; barrier, Esc, and back do not dismiss', (
      tester,
    ) async {
      final container = ProviderContainer();
      await _openDialog(
        tester,
        container,
        barrierDismissible: false,
        state: UpdateState(
          status: UpdateStatus.updateAvailable,
          updateInfo: sampleUpdateInfo(forceUpdate: true),
          isForced: true,
        ),
      );

      expect(find.text('Later'), findsNothing);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.byType(UpdateDialog), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(UpdateDialog), findsOneWidget);
      container.dispose();
    });

    testWidgets('release notes are visible and scrollable with long text', (
      tester,
    ) async {
      final container = ProviderContainer();
      final longNotes = List.filled(40, 'Line of release notes.').join('\n');
      await _openDialog(
        tester,
        container,
        barrierDismissible: true,
        state: UpdateState(
          status: UpdateStatus.updateAvailable,
          updateInfo: sampleUpdateInfo(releaseNotes: longNotes),
        ),
      );

      expect(find.text('Release notes'), findsOneWidget);
      expect(find.textContaining('Line of release notes'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);

      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      container.dispose();
    });

    testWidgets('downloading shows percentage and megabytes', (tester) async {
      final container = ProviderContainer();
      await _openDialog(
        tester,
        container,
        barrierDismissible: true,
        state: UpdateState(
          status: UpdateStatus.downloading,
          updateInfo: sampleUpdateInfo(),
          downloadProgress: 0.5,
          receivedBytes: 5 * 1024 * 1024,
          totalBytes: 10 * 1024 * 1024,
        ),
      );

      expect(find.textContaining('50%'), findsOneWidget);
      expect(find.textContaining('MB'), findsOneWidget);
      container.dispose();
    });

    testWidgets('error shows Retry; UAC message; Close hidden when forced', (
      tester,
    ) async {
      final container = ProviderContainer();
      await _openDialog(
        tester,
        container,
        barrierDismissible: true,
        state: const UpdateState(
          status: UpdateStatus.error,
          errorMessage:
              'Update needs administrator permission. Please try again and click Yes.',
          canRetry: true,
          isForced: false,
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(
        find.textContaining('administrator permission'),
        findsOneWidget,
      );

      container.read(updateControllerProvider.notifier).state = const UpdateState(
        status: UpdateStatus.error,
        errorMessage:
            'Update needs administrator permission. Please try again and click Yes.',
        canRetry: true,
        isForced: true,
      );
      await tester.pumpAndSettle();
      expect(find.text('Close'), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      container.dispose();
    });

    testWidgets('hard safety blocks show reasons without Update now', (tester) async {
      final container = ProviderContainer(
        overrides: [
          updateControllerProvider.overrideWith(
            () => _TrackingUpdateController(
              UpdateState(
                status: UpdateStatus.error,
                updateInfo: sampleUpdateInfo(),
                hardBlocks: const ['Finish or hold the bill in tab 1'],
                errorMessage: 'Finish or hold the bill in tab 1',
                canRetry: true,
              ),
            ),
          ),
        ],
      );

      await _openDialog(
        tester,
        container,
        barrierDismissible: true,
        state: UpdateState(
          status: UpdateStatus.error,
          updateInfo: sampleUpdateInfo(),
          hardBlocks: const ['Finish or hold the bill in tab 1'],
          errorMessage: 'Finish or hold the bill in tab 1',
          canRetry: true,
        ),
      );

      expect(find.text('Cannot update yet'), findsOneWidget);
      expect(find.textContaining('tab 1'), findsWidgets);
      expect(find.text('Update now'), findsNothing);
      final tracking = container.read(updateControllerProvider.notifier)
          as _TrackingUpdateController;
      expect(tracking.startUpdateCalls, 0);
      container.dispose();
    });
  });

  group('AboutSettingsTab', () {
    testWidgets('shows not configured when manifest URL is empty', (tester) async {
      loadUpdateEnv(manifestUrl: '');
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: AboutSettingsTab())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Updates are not configured'), findsOneWidget);
      expect(find.text('Check for updates'), findsNothing);
    });

    testWidgets('optional update via showUpdateDialog dismisses on barrier tap', (
      tester,
    ) async {
      loadUpdateEnv(manifestUrl: 'https://updates.example.com/version.json');
      final container = ProviderContainer(
        overrides: [
          updateControllerProvider.overrideWith(
            () => _AboutOptionalUpdateController(),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: rootNavigatorKey,
            home: const Scaffold(body: AboutSettingsTab()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check for updates'));
      await tester.pumpAndSettle();
      expect(find.byType(UpdateDialog), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.byType(UpdateDialog), findsNothing);
      container.dispose();
    });

    testWidgets(
      'forced update via showUpdateDialog does not dismiss on barrier, Esc, or back',
      (tester) async {
        loadUpdateEnv(manifestUrl: 'https://updates.example.com/version.json');
        final container = ProviderContainer(
          overrides: [
            updateControllerProvider.overrideWith(
              () => _AboutForcedUpdateController(),
            ),
          ],
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              navigatorKey: rootNavigatorKey,
              home: const Scaffold(body: AboutSettingsTab()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Check for updates'));
        await tester.pumpAndSettle();
        expect(find.byType(UpdateDialog), findsOneWidget);
        expect(find.text('Later'), findsNothing);

        await tester.tapAt(const Offset(8, 8));
        await tester.pumpAndSettle();
        expect(find.byType(UpdateDialog), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(UpdateDialog), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(UpdateDialog), findsOneWidget);
        container.dispose();
      },
    );

    testWidgets('Check for updates snackbar when up to date', (tester) async {
      loadUpdateEnv(manifestUrl: 'https://updates.example.com/version.json');
      final container = ProviderContainer(
        overrides: [
          updateControllerProvider.overrideWith(
            () => _StubAboutUpdateController(),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: AboutSettingsTab()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check for updates'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text("You're up to date (v1.0.0)"), findsOneWidget);
      container.dispose();
    });
  });
}

class _StubAboutUpdateController extends UpdateController {
  @override
  UpdateState build() => const UpdateState(status: UpdateStatus.idle);

  @override
  Future<void> checkManually() async {
    state = const UpdateState(status: UpdateStatus.upToDate);
  }
}

class _AboutOptionalUpdateController extends UpdateController {
  @override
  UpdateState build() => const UpdateState(status: UpdateStatus.idle);

  @override
  Future<void> checkManually() async {
    state = UpdateState(
      status: UpdateStatus.updateAvailable,
      updateInfo: sampleUpdateInfo(),
      isForced: false,
    );
  }
}

class _AboutForcedUpdateController extends UpdateController {
  @override
  UpdateState build() => const UpdateState(status: UpdateStatus.idle);

  @override
  Future<void> checkManually() async {
    state = UpdateState(
      status: UpdateStatus.updateAvailable,
      updateInfo: sampleUpdateInfo(forceUpdate: true),
      isForced: true,
    );
  }
}
