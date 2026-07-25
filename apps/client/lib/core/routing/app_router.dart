import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/routing/desktop_router.dart';
import 'package:billing_baba/core/routing/mobile_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Selects [desktopRouterProvider] or [mobileRouterProvider] via [AppPlatform].
final appRouterProvider = Provider<GoRouter>((ref) {
  if (AppPlatform.current.isDesktop) {
    return ref.watch(desktopRouterProvider);
  }
  return ref.watch(mobileRouterProvider);
});
