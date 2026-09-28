import 'dart:async';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/platform/desktop_app_menu_bar.dart';
import 'package:billing_baba/core/platform/desktop_window_config.dart';
import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/core/routing/app_router.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_opening_overlay.dart';
import 'package:billing_baba/features/payments/application/payment_recovery_service.dart';
import 'package:billing_baba/features/payments/presentation/mobile/widgets/payment_recovery_banner.dart';
import 'package:billing_baba/shared/image/image_memory_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BillingBabaApp extends ConsumerStatefulWidget {
  const BillingBabaApp({super.key});

  @override
  ConsumerState<BillingBabaApp> createState() => _BillingBabaAppState();
}

class _BillingBabaAppState extends ConsumerState<BillingBabaApp> {
  final _imageMemoryHandler = ImageMemoryPressureHandler();

  /// Keeps [DesktopAppMenuBar] / [PlatformMenuBar] on a stable Element across
  /// overlay toggles. Relocating the menu under a Stack (previous approach)
  /// created a second PlatformMenuBar before the first disposed, tripping
  /// DefaultPlatformMenuDelegate.debugLockDelegate.
  static final GlobalKey _desktopMenuKey = GlobalKey(
    debugLabel: 'desktopAppMenuBar',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_imageMemoryHandler);
    if (AppPlatform.current.isDesktop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(ensureDesktopWindowMaximized());
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_imageMemoryHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final isOpeningCompany = ref.watch(businessSessionLoadingProvider) != null;
    final isSelectingCompany = ref.watch(businessSelectionTransitionProvider);
    final isBlocking = isOpeningCompany || isSelectingCompany;

    return PaymentRecoveryLifecycle(
      child: MaterialApp.router(
        title: AppConfig.appName,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return DesktopAppMenuBar(
            key: _desktopMenuKey,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppThemeScope(child: child ?? const SizedBox.shrink()),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PaymentRecoveryBanner(),
                ),
                if (isBlocking)
                  Positioned.fill(
                    child: BusinessOpeningOverlay(
                      opaque: true,
                      whiteBackground: true,
                      message: isOpeningCompany
                          ? 'Opening company…'
                          : 'Loading companies…',
                      subtitle: isOpeningCompany
                          ? 'Loading dashboard and company data'
                          : null,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
