import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/router/app_router.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
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

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return AppThemeScope(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
