import 'package:billing_baba/core/routing/app_route_table.dart';
import 'package:billing_baba/core/shell/desktop_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Desktop GoRouter — isolated from the mobile router provider.
///
/// Uses [DesktopShell] only; mobile builds never load this provider.
final desktopRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter(
    ref: ref,
    shellBuilder: (context, state, child) => DesktopShell(
      key: const ValueKey('desktop-shell'),
      child: child,
    ),
  );
});
