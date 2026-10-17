import 'dart:async';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/routing/app_router.dart';
import 'package:billing_baba/core/routing/app_navigator_key.dart';
import 'package:billing_baba/features/app_update/application/update_controller.dart';
import 'package:billing_baba/features/app_update/application/update_state.dart';
import 'package:billing_baba/features/app_update/application/update_ui_policy.dart';
import 'package:billing_baba/features/app_update/presentation/update_dialog.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Schedules update checks and shows [UpdateDialog] when appropriate.
class AppUpdateCoordinator extends ConsumerStatefulWidget {
  const AppUpdateCoordinator({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppUpdateCoordinator> createState() =>
      _AppUpdateCoordinatorState();
}

class _AppUpdateCoordinatorState extends ConsumerState<AppUpdateCoordinator> {
  Timer? _initialTimer;
  Timer? _periodicTimer;
  bool _dialogOpen = false;
  bool _uiEligible = false;

  @override
  void dispose() {
    _initialTimer?.cancel();
    _periodicTimer?.cancel();
    super.dispose();
  }

  void _scheduleChecksIfNeeded() {
    if (!AppConfig.updateManifestConfigured) return;
    if (!_uiEligible) return;
    if (_initialTimer != null) return;

    _initialTimer = Timer(const Duration(seconds: 10), () {
      unawaited(
        ref.read(updateControllerProvider.notifier).checkAutomatically(),
      );
      _periodicTimer?.cancel();
      _periodicTimer = Timer.periodic(const Duration(hours: 6), (_) {
        unawaited(
          ref.read(updateControllerProvider.notifier).checkAutomatically(),
        );
      });
    });
  }

  void _maybeShowDialog(UpdateState state) {
    if (_dialogOpen) return;
    if (state.status != UpdateStatus.updateAvailable) return;

    final controller = ref.read(updateControllerProvider.notifier);
    if (!state.isForced) {
      if (controller.optionalDismissedThisSession) return;
      if (controller.optionalDialogShownThisSession) return;
      controller.markOptionalDialogShown();
    }

    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    _dialogOpen = true;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: !state.isForced,
        builder: (_) => const UpdateDialog(),
      ).whenComplete(() {
        _dialogOpen = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final auth = ref.watch(authProvider);

    ref.listen(updateControllerProvider, (previous, next) {
      if (!_uiEligible) return;
      if (next.status == UpdateStatus.updateAvailable) {
        _maybeShowDialog(next);
      }
    });

    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) {
        final location = router.routerDelegate.currentConfiguration.uri.path;
        final eligible = canShowUpdateUi(
          location: location,
          authStatus: auth.status,
        );

        if (eligible && !_uiEligible) {
          _uiEligible = true;
          _scheduleChecksIfNeeded();
        } else if (!eligible) {
          _uiEligible = false;
        }

        return widget.child;
      },
    );
  }
}
