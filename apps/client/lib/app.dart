import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/platform/desktop_app_menu_bar.dart';
import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/core/routing/app_router.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_opening_overlay.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_imageMemoryHandler);
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

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final content = AppThemeScope(child: child ?? const SizedBox.shrink());
        final menuWrapped = DesktopAppMenuBar(child: content);
        if (!isBlocking) return menuWrapped;

        return Stack(
          children: [
            // Keep the router mounted for data loading, but hide it visually.
            Opacity(opacity: 0, child: IgnorePointer(child: menuWrapped)),
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
        );
      },
    );
  }
}
