import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/settings_nav_panel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Desktop settings shell — left nav (like Reports) + section content.
class DesktopSettingsLayout extends StatelessWidget {
  const DesktopSettingsLayout({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final navWidth = (constraints.maxWidth * 0.2).clamp(200.0, 280.0);

              return DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lgBorder,
                  border: Border.all(color: listPanelCardBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.lgBorder,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: navWidth,
                        child: SettingsNavPanel(
                          selectedRoute: currentRoute,
                          onRouteSelected: (route) => context.go(route),
                        ),
                      ),
                      const VerticalDivider(
                        width: 1,
                        color: listPanelCardBorder,
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
