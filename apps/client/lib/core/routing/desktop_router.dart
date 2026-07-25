import 'package:billing_baba/core/routing/app_route_table.dart';
import 'package:billing_baba/core/shell/desktop_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Desktop GoRouter — uses [DesktopShell], public Adaptive feature pages only.
final desktopRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter(
    ref: ref,
    shellBuilder: (context, state, child) => DesktopShell(
      key: const ValueKey('desktop-shell'),
      child: child,
    ),
  );
});
