import 'package:billing_baba/core/routing/app_route_table.dart';
import 'package:billing_baba/core/shell/mobile_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile GoRouter.
///
/// `/` SplashPage → LoginPage → VerifyOtpPage → (BusinessList when needed)
/// → [MobileShell].
final mobileRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter(
    ref: ref,
    shellBuilder: (context, state, child) => MobileShell(
      key: const ValueKey('mobile-shell'),
      child: child,
    ),
  );
});
