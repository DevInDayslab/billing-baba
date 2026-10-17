import 'dart:io';

import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/platform/desktop_app_instance.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

/// Overridable in tests to avoid exiting the process.
final shutdownForUpdateProvider = Provider<Future<void> Function(Ref ref)>(
  (ref) => shutdownForUpdate,
);

Future<void> shutdownForUpdate(Ref ref) async {
  try {
    final engine = await ref.read(commandAwareSyncEngineProvider.future);
    await engine.stop();
  } on Object {
    // Continue shutdown even if sync stop fails.
  }

  await DesktopAppInstance.release();
  await Future<void>.delayed(const Duration(milliseconds: 200));

  try {
    await ref.read(appDatabaseProvider).close();
  } on Object {
    // Best-effort before exit.
  }

  if (!kIsWeb && AppPlatform.current.isDesktop) {
    try {
      await windowManager.destroy();
    } on Object {
      // Fall through to exit.
    }
  }

  await Future<void>.delayed(const Duration(milliseconds: 800));
  exit(0);
}
